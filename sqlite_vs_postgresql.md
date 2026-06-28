# SQLite vs PostgreSQL：差异对比

> 两者都是优秀的关系型数据库，SQL 语法大部分相同，但在 **数据类型、约束、函数、并发、特性** 等方面有不少差异。
> 本文聚焦**不一样的地方**，方便你从 SQLite 切换到 PostgreSQL（或反过来）时快速避坑。

---

## 1. 定位差异（先理解各自设计哲学）

| | SQLite | PostgreSQL |
|--|--------|------------|
| **定位** | 嵌入式、轻量、文件型数据库 | 企业级、功能完整的 RDBMS |
| **架构** | 单文件，无服务进程（serverless） | 客户端-服务器架构（C/S） |
| **适用场景** | 本地应用、移动端、小工具、原型 | Web 后端、生产系统、复杂业务 |
| **并发** | 写操作串行（一次只能一个写） | 高并发（MVCC，多写同时进行） |
| **大小限制** | 最大数据库 ~140TB（实际受文件系统限制） | 无实际限制 |

> **你当前的场景**：用 SQLite 做单机练习完全够用；如果要部署到服务器、多人访问，再考虑 PostgreSQL。

---

## 2. 数据类型差异 ⚠️ 最常见踩坑点

### 2.1 核心区别

| 类别 | SQLite | PostgreSQL |
|------|--------|------------|
| **类型系统** | **弱类型 / 灵活** — `ANY` 值可存入 `ANY` 列 | **强类型** — 类型不匹配直接报错 |
| **存储方式** | 5 个存储类：`NULL`, `INTEGER`, `REAL`, `TEXT`, `BLOB` | 丰富类型系统：int, numeric, text, jsonb, array, enum… |

### 2.2 具体类型对比

```sql
-- ========== SQLite ==========
-- 只有 INTEGER / REAL / TEXT / BLOB / NULL
CREATE TABLE test (
    id    INTEGER PRIMARY KEY,      -- 自增主键
    name  TEXT,                      -- 字符串
    age   INTEGER,                   -- 整数
    price REAL,                      -- 浮点数
    data  BLOB,                      -- 二进制
    note  TEXT DEFAULT 'hello'       -- 默认值
);

-- SQLite 允许你把 TEXT 塞进 INTEGER 列（不会报错！）
INSERT INTO test(age) VALUES ('十八');  -- ⚠️ 合法但危险

-- ========== PostgreSQL ==========
-- 严格类型，种类丰富
CREATE TABLE test (
    id      SERIAL PRIMARY KEY,         -- 自增（底层是 sequence）
    name    VARCHAR(100),               -- 变长字符串
    age     INTEGER,                    -- 整数，只能存整数
    price   NUMERIC(10,2),              -- 精确小数（货币用这个）
    created TIMESTAMPTZ DEFAULT NOW(),  -- 带时区时间戳
    tags    TEXT[],                     -- 数组（SQLite 不支持）
    config  JSONB,                      -- 二进制 JSON（SQLite 无）
    budget  NUMRANGE                    -- 范围类型（SQLite 无）
);

INSERT INTO test(age) VALUES ('十八');  -- ❌ ERROR: invalid input syntax for type integer
```

### 2.3 布尔值

```sql
-- SQLite
-- 没有 BOOLEAN 类型！存为 0/1（INTEGER）
CREATE TABLE items (is_active INTEGER);  -- 0=false, 1=true
INSERT INTO items VALUES (TRUE);  -- TRUE 会被转为 1

-- PostgreSQL
-- 有真正的 BOOLEAN 类型
CREATE TABLE items (is_active BOOLEAN);
INSERT INTO items VALUES (TRUE);  -- 真正的布尔值
```

### 2.4 日期时间

```sql
-- SQLite
-- 没有 DATE/TIME/DATETIME 类型！用 TEXT 或 INTEGER 存
CREATE TABLE events (
    ts1 TEXT,     -- '2024-01-15 13:30:00'
    ts2 INTEGER   -- Unix 时间戳（秒）
);
-- 日期函数有限
SELECT DATE('now');               -- 今天
SELECT DATETIME('now');           -- 当前时间
SELECT STRFTIME('%Y-%m', ts1);   -- 格式化

-- PostgreSQL
-- 原生日期时间类型
CREATE TABLE events (
    ts1 TIMESTAMPTZ DEFAULT NOW(),  -- 推荐：带时区
    ts2 DATE,                       -- 仅日期
    ts3 INTERVAL                    -- 时间间隔
);
-- 丰富的日期函数
SELECT NOW();
SELECT CURRENT_TIMESTAMP;
SELECT TO_CHAR(NOW(), 'YYYY-MM');
SELECT NOW() + INTERVAL '1 day';
SELECT DATE_TRUNC('month', NOW());
```

---

## 3. 自增主键差异

```sql
-- ========== SQLite ==========
-- 用 INTEGER PRIMARY KEY 实现自增
CREATE TABLE users (
    id INTEGER PRIMARY KEY,  -- ⚠️ 必须加 AUTOINCREMENT 才会严格递增
    name TEXT
);
INSERT INTO users(name) VALUES ('Alice');  -- id 自动设为 1
-- 注意：INTEGER PRIMARY KEY 会自动变为 rowid 的别名
-- 删除最大 id 的行后，新行可能复用该 id（除非声明 AUTOINCREMENT）

-- 显式要求不重用 id（但会降低性能）
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT
);

-- ========== PostgreSQL ==========
-- 方式一：SERIAL（底层是 sequence）
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT
);

-- 方式二：IDENTITY（SQL 标准，推荐）
CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT
);

-- sequence 不会回退，即使事务回滚也不复用 id
```

---

## 4. 约束差异

```sql
-- ========== SQLite ==========
-- 🟢 支持：PRIMARY KEY, UNIQUE, NOT NULL, DEFAULT, CHECK, FOREIGN KEY
-- 🔴 限制：
--   - FOREIGN KEY 默认不启用！需要 PRAGMA foreign_keys = ON;
--   - CHECK 约束创建时解析但不强制执行（除非版本够新）
--   - ALTER TABLE 功能极弱（只能 ADD COLUMN 和 RENAME）
--   - 不支持 DROP COLUMN（需要重建表）

PRAGMA foreign_keys = ON;  -- 每次连接都要执行！

CREATE TABLE orders (
    id      INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),  -- 外键
    total   REAL CHECK(total > 0)
);

-- ❌ 无法直接删除列
-- ALTER TABLE orders DROP COLUMN total;  -- SQLite < 3.35.0 不支持

-- ========== PostgreSQL ==========
-- 🟢 完整支持所有标准约束
-- 🟢 ALTER TABLE 功能强大

CREATE TABLE orders (
    id      SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    total   NUMERIC(10,2) CHECK(total > 0),
    status  TEXT DEFAULT 'pending'
);

-- ✅ 可以添加/删除/修改列
ALTER TABLE orders DROP COLUMN total;
ALTER TABLE orders ALTER COLUMN status SET DEFAULT 'new';
ALTER TABLE orders RENAME COLUMN status TO order_status;
```

---

## 5. 字符串与大小写

```sql
-- ========== SQLite ==========
-- 🟢 大小写不敏感（默认）
SELECT 'Hello' = 'hello';  -- 1 (true)

-- 🔴 只有 LIKE 默认不区分大小写，= 运算符区分
-- 🔴 没有 ILIKE 关键字
SELECT * FROM users WHERE name LIKE '%alice%';  -- 不区分大小写

-- ========== PostgreSQL ==========
-- 🟢 大小写敏感
SELECT 'Hello' = 'hello';  -- false

-- 🟢 有 ILIKE（不区分大小写）
SELECT * FROM users WHERE name ILIKE '%alice%';
SELECT * FROM users WHERE name ~* 'alice';  -- 正则不区分大小写
```

---

## 6. 常用函数差异表

| 功能 | SQLite | PostgreSQL |
|------|--------|------------|
| 当前时间 | `DATETIME('now')` | `NOW()` / `CURRENT_TIMESTAMP` |
| 日期格式化 | `STRFTIME('%Y-%m', d)` | `TO_CHAR(d, 'YYYY-MM')` |
| 字符串拼接 | `a \|\| b` | `a \|\| b` 或 `CONCAT(a, b)` |
| 子串 | `SUBSTR(s, 1, 3)` | `SUBSTRING(s FROM 1 FOR 3)` / `SUBSTR(s, 1, 3)` |
| 长度 | `LENGTH(s)` | `LENGTH(s)` / `CHAR_LENGTH(s)` |
| 替换 | `REPLACE(s, 'a', 'b')` | `REPLACE(s, 'a', 'b')` ✅ 相同 |
| 去重拼接 | `GROUP_CONCAT(col)` | `STRING_AGG(col, ',')` |
| 随机数 | `RANDOM()`（返回 -2^63~2^63-1） | `RANDOM()`（同） |
| 随机 0-1 | `ABS(RANDOM() % 1)`（取模） | `RANDOM()`（直接返回 0.0~1.0） |
| 类型转换 | `CAST(x AS TEXT)` | `x::TEXT` 或 `CAST(x AS TEXT)` |
| IFNULL | `IFNULL(a, b)` | `COALESCE(a, b)` |
| 取当前行号 | 无（ROWID 隐含） | 无标准，用窗口函数 |
| 正则 | ❌ 无内置（需扩展） | ✅ 内置 `~` / `~*` / `REGEXP_LIKE()` |
| 数学 PI | 无 | ✅ `PI()` |
| 字符串聚合 | `GROUP_CONCAT(col, ',')` | `STRING_AGG(col, ',')` |
| 分组求和 | `SUM()` ✅ | `SUM()` ✅ |

---

## 7. SQL 语法差异

### 7.1 LIMIT / OFFSET

```sql
-- 两者都支持，语法相同
SELECT * FROM products LIMIT 10 OFFSET 5;

-- SQLite 额外支持
SELECT * FROM products LIMIT 5, 10;  -- 跳过5行取10行（MySQL 风格）
```

### 7.2 INSERT 特殊语法

```sql
-- ========== SQLite ==========
-- UPSERT（PostgreSQL 的 ON CONFLICT 类似）
INSERT INTO users(id, name) VALUES (1, 'Alice')
ON CONFLICT(id) DO UPDATE SET name = excluded.name;

-- INSERT OR REPLACE（先删后插）
INSERT OR REPLACE INTO users(id, name) VALUES (1, 'Alice');

-- ========== PostgreSQL ==========
-- UPSERT（标准写法）
INSERT INTO users(id, name) VALUES (1, 'Alice')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- RETURNING（SQLite 不支持！）
INSERT INTO users(name) VALUES ('Bob') RETURNING id, name;
UPDATE users SET name = 'Bob2' WHERE id = 1 RETURNING *;
DELETE FROM users WHERE id = 1 RETURNING *;
```

### 7.3 窗口函数

```sql
-- PostgreSQL 支持完整窗口函数
SELECT name, price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS rank
FROM products;

-- SQLite 3.25+ 也支持窗口函数（语法相同）
-- 但 SQLite 不支持某些高级帧选项
```

### 7.4 CTE / WITH

```sql
-- 两者都支持 WITH 和 WITH RECURSIVE，语法完全相同
WITH RECURSIVE nums(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 10
)
SELECT * FROM nums;
```

---

## 8. 特有功能对比

### SQLite 特有（PostgreSQL 没有）

| 功能 | 说明 |
|------|------|
| `rowid` / `_rowid_` | 每行隐含的整数主键（即使没声明 PRIMARY KEY） |
| `VACUUM` | 回收空间、缩小文件 |
| `ATTACH DATABASE` | 一次连接多个数据库文件 |
| `PRAGMA` | 大量运行时配置（`PRAGMA journal_mode=WAL;` 等） |
| `AUTOINCREMENT` | 控制自增主键行为 |
| `.mode` / `.headers` | 命令行格式控制 |
| 内存数据库 | `:memory:` 替代文件路径 |
| `INSERT OR REPLACE` / `INSERT OR IGNORE` | 冲突处理简写 |
| `CREATE TEMP TABLE` | 临时表（同 PG） |

### PostgreSQL 特有（SQLite 没有）

| 功能 | 说明 |
|------|------|
| `SERIAL` / `IDENTITY` | 自增主键 |
| `JSONB` | 二进制 JSON，支持索引和高级查询 |
| `ARRAY` | 原生数组类型 |
| `TSVECTOR` / `TSQUERY` | 全文搜索 |
| `GIN` / `GiST` / `BRIN` 索引 | 多种索引类型 |
| `MATERIALIZED VIEW` | 物化视图 |
| `TABLE INHERITANCE` | 表继承 |
| `PARTITION BY` | 表分区 |
| `LISTEN` / `NOTIFY` | 异步通知 |
| `EXTENSION` | 扩展系统（PostGIS, pg_trgm, pgcrypto 等） |
| `ROW LEVEL SECURITY` | 行级安全 |
| `pg_stat_statements` | 查询性能统计 |
| `EXPLAIN ANALYZE` | 详细执行计划 |
| `CITEXT` | 不区分大小写的字符串类型 |
| `DOMAIN` | 自定义数据类型域 |
| `FOREIGN DATA WRAPPER` | 外部数据源连接 |
| 事务隔离级别 | 完整支持（READ COMMITTED / REPEATABLE READ / SERIALIZABLE） |

---

## 9. 事务与并发

```sql
-- ========== SQLite ==========
-- 默认 autocommit
-- 写事务是串行的（一次只能一个写）
-- 读操作不需要事务也能执行

BEGIN;
INSERT INTO users(name) VALUES ('Alice');
COMMIT;

-- 支持延迟/立即/独占事务
BEGIN IMMEDIATE;  -- 立即获取写锁
BEGIN EXCLUSIVE;  -- 独占

-- 隔离级别：SERIALIZABLE（唯一支持，但实际没这么严格）
-- 只支持 SAVEPOINT（嵌套事务）

-- ========== PostgreSQL ==========
-- 默认 autocommit
-- MVCC：读不阻塞写，写不阻塞读
-- 支持完整的 4 个隔离级别

BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
INSERT INTO users(name) VALUES ('Alice');
COMMIT;

-- SAVEPOINT
SAVEPOINT sp1;
ROLLBACK TO SAVEPOINT sp1;

-- 行级锁
SELECT * FROM users WHERE id = 1 FOR UPDATE;
```

---

## 10. 分页查询对比

```sql
-- 两者语法相同
SELECT * FROM songs ORDER BY title LIMIT 10 OFFSET 20;

-- 但 PostgreSQL 还有更高效的键集分页（Keyset Pagination）
SELECT * FROM songs
WHERE title > 'last_seen_title'
ORDER BY title
LIMIT 10;
```

---

## 11. 实用技巧：让你的 SQLite 代码兼容 PostgreSQL

如果你希望写一份 SQL 同时在 SQLite 和 PostgreSQL 上运行：

```sql
-- ✅ 通用写法
CREATE TABLE users (
    id    INTEGER PRIMARY KEY,  -- SQLite 自增 + PG 隐式自增（SERIAL 除外）
    name  TEXT NOT NULL,         -- TEXT 两者都支持
    age   INTEGER DEFAULT 0,
    created TEXT DEFAULT (datetime('now'))  -- 用 TEXT 存时间戳（PG 也兼容 TEXT）
);

-- ✅ 兼容的日期函数
-- 两边都支持字符串比较（'2024-01-01' > '2023-12-31'）

-- ❌ 避免的写法
-- SERIAL          → PG only
-- AUTOINCREMENT   → SQLite only（且多数情况不需要）
-- JSONB           → PG only
-- ARRAY[]         → PG only
-- RETURNING       → PG only
-- ::TYPE          → PG only（用 CAST(x AS type) 替代）
-- ILIKE           → PG only（用 LIKE 或 UPPER() 替代）
-- STRING_AGG      → PG only（用 GROUP_CONCAT 替代）

-- 兼容的字符串拼接：两者都支持 ||
SELECT 'Hello' || ' ' || 'World';
```

---

## 快速参考卡片

```
┌─────────────────────────────────────────────────┐
│              SQLite          vs     PostgreSQL   │
├─────────────────────────────────────────────────┤
│  类型系统   弱类型（灵活）        强类型（严格）  │
│  布尔值     0/1 INTEGER          真正的 BOOLEAN │
│  日期时间   TEXT/INTEGER          原生 TIMESTAMP │
│  自增       INTEGER PRIMARY KEY   SERIAL/IDENTITY│
│  外键       默认不启用           默认启用       │
│  字符串拼接 ||                     ||           │
│  去重拼接   GROUP_CONCAT          STRING_AGG    │
│  正则       ❌ 无内置              ✅ 内置       │
│  窗口函数   ✅ 3.25+              ✅ 完整       │
│  UPSERT     ON CONFLICT           ON CONFLICT   │
│  RETURNING  ❌                    ✅             │
│  ALTER TABLE 弱                    强             │
│  并发       串行写                 MVCC 高并发   │
│  架构       serverless             客户端-服务器  │
└─────────────────────────────────────────────────┘
```

> **一句话总结**：SQLite 简单轻量适合单机练习，PostgreSQL 功能强大适合生产环境。大部分 SQL 通用，差异主要在数据类型严格度、日期时间函数、以及 PostgreSQL 独有功能（JSONB、数组、全文搜索等）。
