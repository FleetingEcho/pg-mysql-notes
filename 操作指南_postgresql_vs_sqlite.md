# PostgreSQL vs SQLite 操作指南

> 常用操作的**两边对照**，方便你快速找到对应命令。

---

## 📋 目录

1. [安装与启动](#1-安装与启动)
2. [连接与退出](#2-连接与退出)
3. [数据库管理](#3-数据库管理)
4. [用户与权限](#4-用户与权限)
5. [表操作](#5-表操作)
6. [数据 CRUD](#6-数据-crud)
7. [导入导出](#7-导入导出)
8. [查看信息](#8-查看信息)
9. [备份与恢复](#9-备份与恢复)
10. [实用技巧](#10-实用技巧)

---

## 1. 安装与启动

### PostgreSQL

```powershell
# ---- Windows ----
# 下载安装: https://www.postgresql.org/download/windows/
# 安装后，服务会自动启动

# 手动启动/停止服务
net start postgresql-x64-17
net stop postgresql-x64-17

# 或通过 pg_ctl
pg_ctl start -D "C:\Program Files\PostgreSQL\17\data"
pg_ctl stop -D "C:\Program Files\PostgreSQL\17\data"

# ---- Docker 方式（推荐练习用）----
# 启动容器
docker run -d --name my-pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:17

# 停止/启动
docker stop my-pg
docker start my-pg

# 删除
docker rm -f my-pg
```

### SQLite

```powershell
# Windows: 下载 sqlite3.exe 放到 PATH 即可
# 地址: https://www.sqlite.org/download.html

# 验证安装
sqlite3 --version

# 无需安装，无需启动，直接操作文件
```

---

## 2. 连接与退出

### PostgreSQL

```bash
# 连接本地数据库
psql -U postgres -d mydb

# 连远程
psql -U username -d dbname -h host -p 5432

# 连接 URL 格式
psql "postgresql://username:password@localhost:5432/dbname"

# 退出
\q
```

### SQLite

```bash
# 打开/创建数据库文件
sqlite3 music.db

# 打开后，如果文件不存在会自动创建

# 使用内存数据库（不写文件）
sqlite3 :memory:

# 退出
.quit
# 或按 Ctrl+D
```

---

## 3. 数据库管理

### PostgreSQL

```sql
-- 查看所有数据库
\l
-- 或
SELECT datname FROM pg_database;

-- 创建数据库
CREATE DATABASE mydb;
CREATE DATABASE mydb OWNER myuser ENCODING 'UTF8';

-- 切换数据库
\c mydb

-- 查看当前数据库
SELECT current_database();

-- 删除数据库
DROP DATABASE mydb;
-- ⚠️ 不能删除当前连接的数据库，需先切换到另一库
```

### SQLite

```sql
-- SQLite 没有"创建数据库"的命令
-- 一个 .db 文件就是一个数据库
-- 连接时自动创建

-- 查看当前打开的数据库文件
.database
-- 输出: main: C:\work\Mysql-notes\music.db

-- 附加另一个数据库（同时操作两个文件）
ATTACH DATABASE 'other.db' AS other;

-- 分离
DETACH DATABASE other;

-- 删除数据库：直接删文件
-- 在命令行执行: Remove-Item music.db
```

---

## 4. 用户与权限

### PostgreSQL（完善的用户/权限体系）

```sql
-- ===== 用户/角色管理 =====

-- 创建用户（可登录）
CREATE USER alice WITH PASSWORD 'password123';

-- 创建角色（不可登录，用于权限组）
CREATE ROLE read_only;

-- 创建超级用户
CREATE USER admin WITH SUPERUSER PASSWORD 'admin_pass';

-- 设置连接限制和有效期
CREATE USER guest WITH PASSWORD 'guest'
    CONNECTION LIMIT 5
    VALID UNTIL '2025-12-31';

-- 修改密码
ALTER USER alice WITH PASSWORD 'new_password';

-- 重命名用户
ALTER USER alice RENAME TO alice_new;

-- 锁定/解锁
ALTER USER alice NOLOGIN;   -- 禁止登录
ALTER USER alice LOGIN;     -- 恢复登录

-- 删除用户
DROP USER alice;

-- 如果用户有对象，先转移所有权再删
REASSIGN OWNED BY alice TO postgres;
DROP OWNED BY alice;
DROP USER alice;

-- ===== 权限管理 =====

-- 授予数据库连接权限
GRANT CONNECT ON DATABASE mydb TO alice;

-- 授予 schema 使用权限
GRANT USAGE ON SCHEMA public TO alice;

-- 授予表权限
GRANT SELECT ON products TO alice;
GRANT SELECT, INSERT, UPDATE ON products TO alice;
GRANT ALL ON products TO alice;

-- 授予某 schema 中所有表的权限
GRANT SELECT ON ALL TABLES IN SCHEMA public TO alice;

-- 设置未来创建的表也自动授权
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO alice;

-- 撤销权限
REVOKE SELECT ON products FROM alice;

-- 查看权限
\dp products
SELECT * FROM information_schema.role_table_grants WHERE table_name = 'products';

-- ===== 角色组 =====
CREATE ROLE read_only NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
GRANT read_only TO alice;  -- alice 继承 read_only 的权限
```

### SQLite（无用户概念）

```sql
-- SQLite 没有用户系统，没有权限管理
-- 谁有文件访问权限，谁就能读/写数据库

-- 可以通过 PRAGMA 做一些安全控制
PRAGMA cipher_compatibility = 3;  -- SQLCipher 加密扩展
-- 但标准 SQLite 不支持密码/用户

-- 如果确实需要加密，可以考虑：
-- 1. SQLCipher（加密版 SQLite）
-- 2. 操作系统级别的文件权限控制
-- 3. 应用层控制访问

-- 唯一相关的设置：
PRAGMA foreign_keys = ON;  -- 启用外键约束（默认关闭！）
```

---

## 5. 表操作

### PostgreSQL

```sql
-- ===== 创建表 =====

-- 基本建表
CREATE TABLE customers (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(255) UNIQUE,
    age        INTEGER DEFAULT 0 CHECK (age >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- IF NOT EXISTS
CREATE TABLE IF NOT EXISTS products (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- 从查询结果创建表
CREATE TABLE cheap_products AS
SELECT * FROM products WHERE price < 10;

-- 临时表（会话结束自动删除）
CREATE TEMP TABLE temp_results (id INTEGER, value TEXT);

-- ===== 修改表 =====
ALTER TABLE customers ADD COLUMN phone VARCHAR(20);
ALTER TABLE customers DROP COLUMN phone;
ALTER TABLE customers DROP COLUMN IF EXISTS phone;
ALTER TABLE customers RENAME COLUMN phone TO mobile;
ALTER TABLE customers ALTER COLUMN name TYPE TEXT;
ALTER TABLE customers ALTER COLUMN age SET DEFAULT 18;
ALTER TABLE customers ALTER COLUMN age DROP DEFAULT;
ALTER TABLE customers ALTER COLUMN name SET NOT NULL;
ALTER TABLE customers ALTER COLUMN name DROP NOT NULL;
ALTER TABLE customers RENAME TO clients;
ALTER TABLE products ADD CONSTRAINT chk_price CHECK (price > 0);
ALTER TABLE products DROP CONSTRAINT chk_price;

-- ===== 删除表 =====
DROP TABLE customers;
DROP TABLE IF EXISTS customers;
DROP TABLE customers CASCADE;  -- 同时删除依赖此表的视图等

-- ===== 索引 =====
CREATE INDEX idx_customers_email ON customers (email);
CREATE UNIQUE INDEX idx_customers_email_uniq ON customers (email);
CREATE INDEX idx_customers_name_email ON customers (name, email);
DROP INDEX idx_customers_email;
```

### SQLite

```sql
-- ===== 创建表 =====

-- 基本建表（语法类似，但类型宽松）
CREATE TABLE customers (
    id         INTEGER PRIMARY KEY,     -- SQLite 自增主键
    name       TEXT NOT NULL,
    email      TEXT UNIQUE,
    age        INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
);

-- IF NOT EXISTS
CREATE TABLE IF NOT EXISTS products (
    id    INTEGER PRIMARY KEY,
    name  TEXT NOT NULL,
    price REAL NOT NULL
);

-- 从查询结果创建表
CREATE TABLE cheap_products AS
SELECT * FROM products WHERE price < 10;

-- 临时表
CREATE TEMP TABLE temp_results (id INTEGER, value TEXT);

-- ===== 修改表（⚠️ 功能极少！）=====
ALTER TABLE customers ADD COLUMN phone TEXT;         -- ✅ 唯一能干的事
ALTER TABLE customers RENAME TO clients;             -- ✅ 重命名

-- ❌ 以下操作 SQLite 不支持：
-- ALTER TABLE ... DROP COLUMN      （3.35.0+ 才支持）
-- ALTER TABLE ... RENAME COLUMN    （3.25.0+ 才支持）
-- ALTER TABLE ... ALTER COLUMN     ❌ 不支持

-- 如果确实要删除/修改列，只能重建表
-- SQLite 标准做法：
ALTER TABLE customers RENAME TO customers_old;

CREATE TABLE customers (
    id    INTEGER PRIMARY KEY,
    name  TEXT NOT NULL
    -- 去掉了 email 列
);

INSERT INTO customers SELECT id, name FROM customers_old;
DROP TABLE customers_old;

-- ===== 删除表 =====
DROP TABLE customers;
DROP TABLE IF EXISTS customers;
-- SQLite 没有 CASCADE（因为外键默认不启用）

-- ===== 索引 =====
CREATE INDEX idx_customers_email ON customers (email);
CREATE UNIQUE INDEX idx_customers_email_uniq ON customers (email);
DROP INDEX IF EXISTS idx_customers_email;
```

---

## 6. 数据 CRUD

### PostgreSQL & SQLite（大部分相同）

```sql
-- ===== INSERT =====

-- 基本插入（两者相同）
INSERT INTO products(name, price) VALUES ('Widget', 9.99);

-- 批量插入
INSERT INTO products(name, price) VALUES
    ('Widget', 9.99),
    ('Gadget', 14.99),
    ('Doohickey', 4.99);

-- 从查询插入
INSERT INTO cheap_products SELECT * FROM products WHERE price < 10;

-- ===== PostgreSQL 特有 =====
-- RETURNING（SQLite 不支持！）
INSERT INTO products(name, price) VALUES ('New', 5.99) RETURNING id;
UPDATE products SET price = 10 WHERE id = 1 RETURNING *;
DELETE FROM products WHERE id = 1 RETURNING *;

-- ===== SQLite 特有 =====
-- INSERT OR REPLACE
INSERT OR REPLACE INTO products(id, name, price) VALUES (1, 'Widget', 8.99);

-- INSERT OR IGNORE
INSERT OR IGNORE INTO products(id, name, price) VALUES (1, 'Widget', 8.99);

-- ===== UPDATE（两者相同）=====
UPDATE products SET price = 12.99 WHERE id = 1;
UPDATE products SET price = price * 1.1 WHERE price < 10;

-- ===== DELETE（两者相同）=====
DELETE FROM products WHERE id = 1;
DELETE FROM products;  -- 清空表（SQLite 很快，PG 需要 VACUUM 回收空间）

-- ===== UPSERT（两者都支持，语法微差）=====
-- PostgreSQL
INSERT INTO products(id, name, price) VALUES (1, 'Widget', 8.99)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, price = EXCLUDED.price;

-- SQLite
INSERT INTO products(id, name, price) VALUES (1, 'Widget', 8.99)
ON CONFLICT(id) DO UPDATE SET name = excluded.name, price = excluded.price;
--                          ↑ 注意：SQLite 用 excluded 小写
```

---

## 7. 导入导出

### PostgreSQL

```bash
# ---- 从 SQL 文件导入 ----
psql -U postgres -d mydb -f seed.sql

# ---- 导出到 SQL 文件 ----
pg_dump -U postgres -d mydb > backup.sql

# 只导出表结构（不含数据）
pg_dump -U postgres -d mydb --schema-only > schema.sql

# 只导出数据
pg_dump -U postgres -d mydb --data-only > data.sql

# 自定义格式（推荐，支持并行恢复）
pg_dump -U postgres -d mydb -Fc > backup.dump

# ---- 从 CSV 导入/导出（SQL）----
-- 导出到 CSV
COPY products TO '/tmp/products.csv' WITH (FORMAT CSV, HEADER);

-- 从 CSV 导入
COPY products FROM '/tmp/products.csv' WITH (FORMAT CSV, HEADER);

# psql 中的 \copy（读/写客户端本地文件）
\copy products TO 'C:/data/products.csv' WITH (FORMAT CSV, HEADER)
\copy products FROM 'C:/data/products.csv' WITH (FORMAT CSV, HEADER)
```

### SQLite

```bash
# ---- 从 SQL 文件导入 ----
# 方式一
sqlite3 music.db < seed_music_db.sql

# 方式二（在 sqlite3 里面）
sqlite> .read seed_music_db.sql

# ---- 导出到 SQL 文件 ----
sqlite3 music.db .dump > backup.sql

# 只导出表结构
sqlite3 music.db .schema > schema.sql

# 只导出特定表
sqlite3 music.db ".dump songs" > songs.sql

# ---- CSV 导入/导出 ----
# 导出到 CSV
sqlite3 music.db ".headers on" ".mode csv" ".output songs.csv" "SELECT * FROM songs;" ".output stdout"

# 或简写：
sqlite3 -header -csv music.db "SELECT * FROM songs;" > songs.csv

# 从 CSV 导入
.mode csv
.import songs.csv songs

# ---- 导出到 Markdown ----
.mode markdown
SELECT * FROM genres;
```

---

## 8. 查看信息

### PostgreSQL（元命令 + 系统视图）

```sql
-- psql 元命令（最常用）
\l              -- 列出数据库
\c dbname       -- 切换数据库
\d              -- 列出当前 schema 的表/视图/序列
\d tablename    -- 查看表结构（列、类型、约束）
\d+ tablename   -- 详细表结构（含注释、存储参数）
\di             -- 列出索引
\dv             -- 列出视图
\df             -- 列出函数
\du             -- 列出用户/角色
\dn             -- 列出 schema
\dt             -- 只列出表
\dt *.*         -- 列出所有 schema 的表
\x              -- 切换扩展显示（宽表时很好用）
\timing         -- 显示查询耗时

-- 系统视图查询
-- 查看表结构
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns
WHERE table_name = 'products';

-- 查看表大小
SELECT pg_size_pretty(pg_total_relation_size('products'));

-- 查看所有表大小
SELECT tablename, pg_size_pretty(pg_total_relation_size(quote_ident(tablename))) AS size
FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(quote_ident(tablename)) DESC;

-- 查看活动连接
SELECT pid, usename, state, query FROM pg_stat_activity;

-- 查看慢查询
SELECT query, calls, total_exec_time / calls AS avg_ms
FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10;
```

### SQLite（点命令）

```sql
-- sqlite3 中的 . 命令
.tables            -- 列出所有表
.tables %song%     -- 模糊匹配表名
.schema            -- 查看所有表结构
.schema songs      -- 查看指定表结构
.schema songs albums  -- 查看多个表
.indexes           -- 列出索引
.indexes songs     -- 查看特定表的索引
.databases         -- 查看当前打开的数据库文件
.dump              -- 导出整个数据库为 SQL
.dump songs        -- 只导出某表

-- 输出格式控制
.headers on        -- 显示列名
.mode column       -- 列对齐输出
.mode csv          -- CSV 格式
.mode markdown     -- Markdown 表格格式
.mode json         -- JSON 格式
.mode box          -- 带框线表格（美观）
.nullvalue NULL    -- NULL 显示为 NULL（默认空白）

-- 性能相关
.timer on          -- 显示查询耗时
.expert            -- 给出索引建议（基于 EXPLAIN QUERY PLAN）

-- 示例：以 markdown 格式查看所有歌曲
.mode markdown
.headers on
SELECT title, duration_seconds, plays FROM songs LIMIT 5;
```

---

## 9. 备份与恢复

### PostgreSQL

```bash
# ---- 备份 ----
# 单个数据库备份
pg_dump -U postgres -d mydb > mydb_backup.sql

# 压缩备份
pg_dump -U postgres -d mydb | gzip > mydb_backup.sql.gz

# 自定义格式（推荐，支持并行和选择性恢复）
pg_dump -U postgres -d mydb -Fc > mydb_backup.dump

# 备份所有数据库
pg_dumpall -U postgres > all_backup.sql

# ---- 恢复 ----
# 从 SQL 文件恢复
psql -U postgres -d mydb < mydb_backup.sql

# 从自定义格式恢复
pg_restore -U postgres -d mydb mydb_backup.dump

# 先重建数据库
dropdb -U postgres mydb
createdb -U postgres mydb
psql -U postgres -d mydb < mydb_backup.sql
```

### SQLite

```bash
# ---- 备份 ----
# 方式一：直接复制文件（SQLite 备份就这么简单）
copy music.db music_backup.db   # Windows
cp music.db music_backup.db     # Linux/Mac

# 方式二：用 SQL 导出（可读、跨版本）
sqlite3 music.db .dump > music_backup.sql

# 方式三：用 .backup 命令（原子备份，文件在用也能备）
sqlite3 music.db ".backup music_backup.db"

# ---- 恢复 ----
# 方式一：直接复制回来
copy music_backup.db music.db

# 方式二：从 SQL 恢复
sqlite3 music.db < music_backup.sql

# 方式三：从 .backup 恢复
sqlite3 music.db ".restore music_backup.db"
```

---

## 10. 实用技巧

### PostgreSQL 常用技巧

```sql
-- 查看当前正在执行的查询
SELECT pid, now() - query_start AS running_time, query, state
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY running_time DESC;

-- 终止查询（不杀连接）
SELECT pg_cancel_backend(pid);

-- 强制终止（断开连接）
SELECT pg_terminate_backend(pid);

-- 重建索引（整理碎片）
REINDEX TABLE products;

-- 更新统计信息（帮优化器做更好的执行计划）
ANALYZE;

-- 清理死元组（MVCC 产生的旧版本数据）
VACUUM ANALYZE;

-- 查看等待锁的查询
SELECT blocked.pid AS blocked_pid, blocking.pid AS blocking_pid,
       blocked.query AS blocked_query, blocking.query AS blocking_query
FROM pg_stat_activity AS blocked
JOIN pg_stat_activity AS blocking
  ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
```

### SQLite 常用技巧

```sql
-- 查看查询计划（看有没有用到索引）
EXPLAIN QUERY PLAN SELECT * FROM songs WHERE title LIKE '%Love%';

-- 让 LIKE 查询走索引（需要先建索引）
CREATE INDEX idx_songs_title ON songs(title);

-- PRAGMA 常用设置（每次连接都要设！）
PRAGMA foreign_keys = ON;          -- 启用外键
PRAGMA journal_mode = WAL;         -- WAL 模式（读写不互斥，推荐）
PRAGMA synchronous = NORMAL;       -- 平衡性能与安全
PRAGMA cache_size = -8000;         -- 缓存 8MB
PRAGMA temp_store = MEMORY;        -- 临时表存内存

-- 查看当前 PRAGMA 设置
PRAGMA journal_mode;   -- 返回当前日志模式

-- 统计信息
SELECT COUNT(*) FROM sqlite_master WHERE type = 'table';  -- 表数量
SELECT COUNT(*) FROM sqlite_master WHERE type = 'index';  -- 索引数量

-- 查看数据库文件完整性
PRAGMA integrity_check;

-- 查看外键状态
PRAGMA foreign_keys;
```

---

## 速查卡片

```
┌─────────────────────────────────────────────────────────────────────┐
│                     操作             PostgreSQL    SQLite           │
├─────────────────────────────────────────────────────────────────────┤
│  启动服务           net start pg...          无需（直接打开文件）   │
│  连接               psql -U postgres          sqlite3 music.db      │
│  创建数据库         CREATE DATABASE           ATTACH 或直接建文件   │
│  创建用户           CREATE USER               ❌ 无用户概念         │
│  修改密码           ALTER USER ... PASSWORD   ❌                    │
│  授予权限           GRANT ... ON ... TO ...   ❌                    │
│  创建表             CREATE TABLE              相同                  │
│  修改表             ALTER TABLE（强）          ALTER TABLE（弱）     │
│  删除列             ALTER ... DROP COLUMN     需重建表              │
│  插入               INSERT INTO               相同                  │
│  更新               UPDATE ... SET            相同                  │
│  删除               DELETE FROM               相同                  │
│  事务               BEGIN/COMMIT/ROLLBACK     相同（串行写）        │
│  UPSERT             ON CONFLICT DO UPDATE      ON CONFLICT DO UPDATE │
│  返回插入行         RETURNING                 ❌                    │
│  查看表结构         \d table                    .schema table        │
│  列出表             \dt                         .tables              │
│  导入 SQL           psql -f file.sql           sqlite3 db < file.sql │
│  导出 SQL           pg_dump > file.sql         sqlite3 db .dump     │
│  导入 CSV           COPY ... FROM ...          .import file.csv tbl  │
│  备份               pg_dump / pg_dumpall       复制 .db 文件即可     │
│  查看执行计划       EXPLAIN ANALYZE            EXPLAIN QUERY PLAN    │
│  终止查询           pg_cancel_backend()        ❌ 单线程无需终止     │
└─────────────────────────────────────────────────────────────────────┘
```

> **总结**：PostgreSQL 操作比 SQLite 复杂得多，因为有用户体系、权限管理、服务管理等。
> 练习 SQL 语句本身时两者几乎一样，**差异主要体现在运维和高级功能上**。
