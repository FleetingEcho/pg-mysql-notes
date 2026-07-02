# SQL 面试知识整理

> **说明：** 代码示例以通用 SQL / SQLite 为主；PostgreSQL 特有语法会单独标注。

> 涵盖分库分表、性能优化、常见面试题、数据库理论等进阶内容。

---

## 目录

1. [分库分表](#1-分库分表)
2. [SQL 执行顺序与优化](#2-sql-执行顺序与优化)
3. [索引原理与策略](#3-索引原理与策略)
4. [事务与隔离级别](#4-事务与隔离级别)
5. [数据库范式](#5-数据库范式)
6. [常见 SQL 面试题](#6-常见-sql-面试题)
7. [设计题](#7-设计题)
8. [MySQL vs PostgreSQL vs SQLite 面试要点](#8-mysql-vs-postgresql-vs-sqlite-面试要点)

---

## 1. 分库分表

### 1.1 什么情况下需要分库分表？

```
单表数据量  →  问题                   →  什么时候分
──────────    ──────────               ──────────────
~500万行      B+树 3~4 层，还行        暂不需要
~1000万行    查询开始变慢               考虑索引优化
~5000万行    索引层数增加，IO 增多      考虑分表
~1亿+行      备份/DDL 锁表时间过长      必须分表
~10亿+行     单库连接数/磁盘/CPU 瓶颈   分库 + 分表
```

**具体场景判断：**

| 指标 | 警戒线 | 说明 |
|------|--------|------|
| 单表行数 | > 2000 万 | B+树层数增加，查询性能下降 |
| 单库连接数 | > 2000 | 连接池耗尽，响应变慢 |
| 单表存储 | > 50 GB | 备份/恢复时间过长 |
| 磁盘 IO 利用率 | > 70% | 写入压力大，需拆分写入负载 |
| 慢查询比例 | > 5% | 索引优化无法解决时 |

### 1.2 分库分表的策略

#### 垂直分库（按业务拆分）

```
原来：一个数据库包含用户、订单、商品所有表

拆后：
┌─ 用户库(user_db) ─┐    ┌─ 订单库(order_db) ─┐    ┌─ 商品库(product_db) ─┐
│ users              │    │ orders              │    │ products             │
│ user_addresses     │    │ order_items         │    │ categories           │
└────────────────────┘    └─────────────────────┘    └───────────────────────┘
```

**优点**：业务解耦、各自独立扩展
**缺点**：跨库 JOIN 困难（需应用层处理或引入中间件）

#### 垂直分表（按字段拆分）

```sql
-- 原来一张表有太多字段
CREATE TABLE articles (
    id        INT PRIMARY KEY,
    title     VARCHAR(200),
    summary   VARCHAR(500),
    content   TEXT,              -- 大字段，查询少
    author_id INT,
    created_at DATETIME,
    -- ... 还有 20 个不常用的字段
);

-- 拆分为主表和扩展表
CREATE TABLE articles (
    id         INT PRIMARY KEY,
    title      VARCHAR(200),
    summary    VARCHAR(500),
    author_id  INT,
    created_at DATETIME
);

CREATE TABLE articles_ext (
    id          INT PRIMARY KEY,
    content     TEXT,
    -- ... 其他不常用字段
);
```

**适用场景**：表中存在大量不常用的大字段

#### 水平分表（按行拆分）⭐ 最常见

**方式一：Hash 分片**

```sql
-- 按 user_id 取模分到 4 张表
-- order_0, order_1, order_2, order_3

-- 路由规则
shard_id = user_id % 4

-- 查询时：
SELECT * FROM order_{shard_id} WHERE user_id = 123;
```

**优点**：数据分布均匀
**缺点**：扩缩容需要重新哈希（迁移数据）

**方式二：Range 分片**

```sql
-- 按时间范围分表
-- orders_202401, orders_202402, orders_202403 ...

-- 查询时：
SELECT * FROM orders_202401 WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';
```

**优点**：范围查询友好、扩容简单（加新表即可）
**缺点**：热点数据集中（当月表写入压力大）

**方式三：一致性 Hash**

```
哈希环分布，解决扩缩容时的数据迁移问题。
常用于中间件实现（如 sharding-jdbc、MyCat）。
```

### 1.3 分库分表带来的问题及解决方案

| 问题 | 说明 | 解决方案 |
|------|------|---------|
| **跨库 JOIN** | 数据在不同库，无法直接 JOIN | 应用层多次查询后组装 / 引入搜索引擎（ES） |
| **分布式事务** | 跨库操作需要保证一致性 | 2PC / TCC / 最终一致性（消息队列） |
| **全局主键** | 自增 ID 在各分片会重复 | 雪花算法 / UUID / 数据库分段生成 |
| **分页排序** | ORDER BY + LIMIT 跨分片后不准 | 各分片查询后归并排序（取更多条再聚合） |
| **数据迁移** | 扩缩容时数据要重新分布 | 双写迁移 / 一致性哈希最小化迁移 |

### 1.4 常见的分库分表中间件

| 中间件 | 说明 |
|--------|------|
| **Apache ShardingSphere** | Java 生态，功能最全，支持分片/读写分离/加密 |
| **MyCat** | 基于 Proxy 架构，对应用透明 |
| **Vitess** | YouTube 开源，K8s 原生，支持分布式 JOIN |
| **TDSQL** | 腾讯云，自动分片 |

---

## 2. SQL 执行顺序与优化

### 2.1 SQL 各子句执行顺序

```sql
SELECT DISTINCT column, AGG_FUNC(column)    -- ⑤ 选择列
FROM table1                                 -- ① 确定数据源
JOIN table2 ON condition                     -- ② 关联
WHERE condition                              -- ③ 行过滤（聚合前）
GROUP BY column                              -- ④ 分组
HAVING condition                             -- ⑥ 组过滤（聚合后）
ORDER BY column                              -- ⑦ 排序
LIMIT n OFFSET m                             -- ⑧ 分页
```

**常见错误：**

```sql
-- ❌ 错误：WHERE 里用聚合
SELECT vend_id, COUNT(*)
FROM products
WHERE COUNT(*) > 2       -- WHERE 在 GROUP BY 之前执行，此时 COUNT 还没算
GROUP BY vend_id;

-- ✅ 正确：用 HAVING
SELECT vend_id, COUNT(*)
FROM products
GROUP BY vend_id
HAVING COUNT(*) > 2;
```

### 2.2 SQL 优化三板斧

```
第一板斧：索引优化
  ├── EXPLAIN 分析查询计划
  ├── 检查是否走索引（type = ALL 表示全表扫描）
  └── 为 WHERE / JOIN / ORDER BY 列建索引

第二板斧：SQL 改写
  ├── 避免 SELECT *（只取需要的列）
  ├── 避免在 WHERE 中对列做函数运算（WHERE YEAR(date) = 2024 → 改为范围查询）
  ├── 避免隐式类型转换（WHERE id = '123' → 字符串 vs 数字）
  └── 大表分页优化（用游标分页代替 OFFSET）

第三板斧：架构优化
  ├── 读写分离（主库写、从库读）
  ├── 缓存（Redis 缓存热点数据）
  └── 分库分表（数据量实在太大时）
```

### 2.3 EXPLAIN 解读

```sql
-- 看这条查询是否用到了索引
EXPLAIN SELECT * FROM songs WHERE title LIKE '%Love%';
```

**关键字段（MySQL 语法）：**

| 字段 | 说明 | 好 | 坏 |
|------|------|----|----|
| `type` | 访问类型 | `const`, `ref`, `range` | `ALL`（全表扫描）|
| `key` | 实际使用的索引 | 有值 | `NULL` |
| `rows` | 扫描的行数 | 越小越好 | 很大 |
| `Extra` | 附加信息 | `Using index`（覆盖索引） | `Using filesort`, `Using temporary` |

**type 从好到差：**

```
system > const > eq_ref > ref > range > index > ALL
```

### 2.4 大分页优化

```sql
-- ❌ 慢：OFFSET 越大越慢（前面 100000 行全扫了）
SELECT * FROM songs ORDER BY plays DESC LIMIT 20 OFFSET 100000;

-- ✅ 快：游标分页（Keyset Pagination）
-- 记下上一页最后一条的 plays 值
SELECT * FROM songs
WHERE plays < 16500000    -- 上一页最后一条的 plays
ORDER BY plays DESC
LIMIT 20;
```

---

## 3. 索引原理与策略

### 3.1 B+Tree 索引

```
为什么用 B+Tree 不用二叉树/哈希？

二叉树：           深度大，树高=log2(N)，1000万行≈24层，每次磁盘 IO 找一层 → 慢
B+Tree：          每个节点存多个键，树高≈3~4层，3~4次 IO 就能定位到数据
哈希索引：         等值查询 O(1)，但不支持范围查询 ORDER BY / > / <
```

**B+Tree 特点：**
- 所有数据存在叶子节点
- 叶子节点之间用链表连接（范围查询友好）
- 非叶子节点只存键和指针（不存数据，一个节点能存更多键）

### 3.2 索引分类

```sql
-- 主键索引（聚簇索引）
-- 数据直接存储在索引的叶子节点（InnoDB）

-- 普通索引（二级索引）
CREATE INDEX idx_title ON songs(title);

-- 唯一索引
CREATE UNIQUE INDEX idx_email ON users(email);

-- 组合索引（最左前缀原则）
CREATE INDEX idx_artist_plays ON songs(artist_id, plays);
-- 能用到索引的查询：
WHERE artist_id = 1
WHERE artist_id = 1 AND plays > 10000
-- 用不到索引的查询：
WHERE plays > 10000          -- 跳过了最左列
WHERE artist_id > 5 AND plays > 10000  -- 范围查询后索引失效
```

### 3.3 什么时候索引失效？

```sql
-- ❌ 对索引列做函数运算
WHERE YEAR(created_at) = 2024     -- 改为：WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01'

-- ❌ 隐式类型转换
WHERE phone = 1234567890          -- phone 是 VARCHAR，有隐式转换

-- ❌ LIKE 以 % 开头
WHERE title LIKE '%Love%'         -- ❌ 走不了索引
WHERE title LIKE 'Love%'          -- ✅ 可以走索引

-- ❌ OR 条件中包含非索引列
WHERE id = 1 OR name = 'test'     -- name 没有索引 → 全表扫描

-- ❌ NOT IN / !=
WHERE status != 'active'          -- 大部分数据库不走索引
```

### 3.4 面试高频：索引设计原则

```
1. 区分度高的列放前面（选择性 = COUNT(DISTINCT col) / COUNT(*)）
2. 常用 WHERE 条件的列建索引
3. JOIN 的关联列建索引
4. ORDER BY 的列建索引（避免 filesort）
5. 小表不需要索引（全表扫描可能比走索引快）
6. 不要过度索引（写入变慢，占用空间）
7. 覆盖索引：索引包含查询所需的所有列（Extra = Using index）
```

---

## 4. 事务与隔离级别

### 4.1 并发三大问题

| 问题 | 说明 | 类比 |
|------|------|------|
| **脏读** | 读到另一个事务未提交的数据 | 别人还没决定，你就信了 |
| **不可重复读** | 同一事务内，两次读同一行结果不同（数据被修改） | 第一次看到 100，再查变成 200 |
| **幻读** | 同一事务内，两次查询返回的行数不同（有插入/删除） | 第一次查到 5 行，再查变成 6 行 |

### 4.2 四种隔离级别

| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
|----------|------|------------|------|
| READ UNCOMMITTED | ✅ 可能 | ✅ 可能 | ✅ 可能 |
| READ COMMITTED | ❌ 不会 | ✅ 可能 | ✅ 可能 |
| REPEATABLE READ | ❌ 不会 | ❌ 不会 | ✅ 可能（MySQL InnoDB 通过间隙锁解决） |
| SERIALIZABLE | ❌ 不会 | ❌ 不会 | ❌ 不会 |

**各数据库默认级别：**
- MySQL：`REPEATABLE READ`
- PostgreSQL：`READ COMMITTED`
- SQLite：`SERIALIZABLE`

### 4.3 MVCC（多版本并发控制）

```
MVCC 让"读不阻塞写，写不阻塞读"

核心：每行有多个版本（undo log 记录），每个事务看到的是
该事务开始时刻的快照（或上一个已提交版本）。

MySQL InnoDB 的实现：
  - 每行隐藏两个字段：DB_TRX_ID（最后修改的事务ID）、DB_ROLL_PTR（回滚指针）
  - 通过 ReadView 判断哪些版本可见
```

---

## 5. 数据库范式

| 范式 | 定义 | 反例 |
|------|------|------|
| **1NF** | 每列不可再分 | 某列存了"北京,上海"（应拆为多行或多表）|
| **2NF** | 满足1NF，非主键列**完全依赖于主键** | 订单明细表里有"商品名称"（应只存商品ID，建商品表）|
| **3NF** | 满足2NF，非主键列**不传递依赖于主键** | 订单表里有"客户电话"（应只存客户ID）|

**实际工作中：** 不一定要严格遵循范式。有时为了性能会**反范式**（冗余一些字段，减少 JOIN）。

---

## 6. 常见 SQL 面试题

### 6.1 经典笔试：第二高的值

```sql
-- 题目：查询歌曲中第二高的播放量

-- 方法一：LIMIT + OFFSET
SELECT DISTINCT plays FROM songs ORDER BY plays DESC LIMIT 1 OFFSET 1;

-- 方法二：子查询
SELECT MAX(plays) FROM songs
WHERE plays < (SELECT MAX(plays) FROM songs);

-- 方法三：窗口函数
SELECT DISTINCT plays FROM (
    SELECT plays, DENSE_RANK() OVER (ORDER BY plays DESC) AS rnk
    FROM songs
) WHERE rnk = 2;
```

### 6.2 连续出现/登录

```sql
-- 题目：找出连续 3 天都有听歌记录的用户

-- SQLite 版本
WITH user_dates AS (
    SELECT DISTINCT user_id, DATE(listened_at) AS listen_date
    FROM listening_history
),
date_rank AS (
    SELECT user_id, listen_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY listen_date) AS rn
    FROM user_dates
),
groups AS (
    SELECT user_id, listen_date,
        DATE(listen_date, '-' || (rn - 1) || ' days') AS grp
    FROM date_rank
)
SELECT DISTINCT user_id
FROM groups
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;
```

```sql
-- PostgreSQL 版本
WITH user_dates AS (
    SELECT DISTINCT user_id, listened_at::DATE AS listen_date
    FROM listening_history
),
date_rank AS (
    SELECT user_id, listen_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY listen_date) AS rn
    FROM user_dates
),
groups AS (
    SELECT user_id, listen_date,
        listen_date - (rn - 1) * INTERVAL '1 day' AS grp
    FROM date_rank
)
SELECT DISTINCT user_id
FROM groups
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;
```

### 6.3 分组 Top N

```sql
-- 题目：每个流派播放量最高的歌曲

-- 方式一：相关子查询
SELECT g.name AS genre, s.title, s.plays
FROM songs s
JOIN albums al ON s.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
JOIN genres g ON a.genre_id = g.genre_id
WHERE s.plays = (
    SELECT MAX(s2.plays)
    FROM songs s2
    JOIN albums al2 ON s2.album_id = al2.album_id
    JOIN artists a2 ON al2.artist_id = a2.artist_id
    WHERE a2.genre_id = a.genre_id
);

-- 方式二：窗口函数
SELECT genre, title, plays FROM (
    SELECT g.name AS genre, s.title, s.plays,
        ROW_NUMBER() OVER (PARTITION BY g.genre_id ORDER BY s.plays DESC) AS rnk
    FROM songs s
    JOIN albums al ON s.album_id = al.album_id
    JOIN artists a ON al.artist_id = a.artist_id
    JOIN genres g ON a.genre_id = g.genre_id
) WHERE rnk = 1;
```

### 6.4 删除重复数据

```sql
-- 题目：删除同名的重复艺术家（保留 ID 最小的）

DELETE FROM artists
WHERE artist_id NOT IN (
    SELECT MIN(artist_id) FROM artists GROUP BY name
);
```

### 6.5 环比/同比

```sql
-- 环比：计算每月听歌次数与上月的差值

WITH monthly AS (
    SELECT STRFTIME('%Y-%m', listened_at) AS month, COUNT(*) AS cnt
    FROM listening_history
    GROUP BY month
)
SELECT month, cnt,
    LAG(cnt) OVER (ORDER BY month) AS prev_month_cnt,
    cnt - LAG(cnt) OVER (ORDER BY month) AS diff
FROM monthly;
```

### 6.6 行列转换

```sql
-- 题目：将流派名转为列，统计各类歌曲数量

-- 方法：CASE WHEN + 聚合
SELECT
    COUNT(CASE WHEN g.name = 'Pop' THEN 1 END) AS Pop,
    COUNT(CASE WHEN g.name = 'Rock' THEN 1 END) AS Rock,
    COUNT(CASE WHEN g.name = 'Classical' THEN 1 END) AS Classical
FROM songs s
JOIN albums al ON s.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
JOIN genres g ON a.genre_id = g.genre_id;
```

### 6.7 找出有某关系但没有另一关系的数据

```sql
-- 题目：找到那些创建了播放列表但从没听过歌的用户

SELECT u.username
FROM users u
WHERE u.user_id IN (SELECT DISTINCT user_id FROM playlists)
  AND u.user_id NOT IN (SELECT DISTINCT user_id FROM listening_history);
```

### 6.8 找出各部门工资最高的员工（经典面试题）

```sql
-- 假如需要自己建表示例：
CREATE TABLE dept_emp (
    id       INT,
    name     TEXT,
    dept     TEXT,
    salary   REAL
);

INSERT INTO dept_emp VALUES
(1, 'Alice', 'Engineering', 8000),
(2, 'Bob', 'Engineering', 7500),
(3, 'Charlie', 'Sales', 6000),
(4, 'David', 'Sales', 6500),
(5, 'Eve', 'Engineering', 8500);

-- 查询各部门工资最高的员工
SELECT dept, name, salary
FROM dept_emp
WHERE (dept, salary) IN (
    SELECT dept, MAX(salary) FROM dept_emp GROUP BY dept
);

-- 或窗口函数
SELECT dept, name, salary FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) AS rnk
    FROM dept_emp
) WHERE rnk = 1;
```

### 6.9 找出连续范围/断号

```sql
-- 题目：找到 songs 表中 song_id 不连续的那些"缺口"

-- 先找出不连续的位置
SELECT a.song_id + 1 AS missing_start,
       MIN(b.song_id) - 1 AS missing_end
FROM songs a
JOIN songs b ON b.song_id > a.song_id + 1
GROUP BY a.song_id
HAVING missing_start <= missing_end;
```

---

## 7. 设计题

### 7.1 设计一个关注/粉丝系统

```sql
-- 用户关系表（千万级用户）
CREATE TABLE follows (
    follower_id  INT NOT NULL,  -- 关注者
    followee_id  INT NOT NULL,  -- 被关注者
    created_at   DATETIME NOT NULL,
    PRIMARY KEY (follower_id, followee_id),
    INDEX idx_followee (followee_id)  -- 查粉丝时用
);

-- 查询某人的关注列表（我关注了谁）
SELECT * FROM follows WHERE follower_id = 123 ORDER BY created_at DESC;

-- 查询某人的粉丝列表（谁关注了我）
SELECT * FROM follows WHERE followee_id = 123 ORDER BY created_at DESC;

-- 互相关注（双向关注）
SELECT f1.follower_id, f1.followee_id
FROM follows f1
JOIN follows f2 ON f1.follower_id = f2.followee_id
               AND f1.followee_id = f2.follower_id;
```

**面试追问：**
- Q: 数据量到亿级怎么办？ → 分库分表，按 follower_id 分片
- Q: 查询某人的粉丝（按 followee 查）跨分片怎么处理？ → 建立反向索引表
- Q: 一个用户关注了 10 万人怎么办？ → 限制上限，或加 Feed 流改造

### 7.2 设计一个积分/排行榜系统

```sql
-- 积分表
CREATE TABLE user_scores (
    user_id    INT PRIMARY KEY,
    score      INT NOT NULL,
    updated_at DATETIME NOT NULL
);

CREATE INDEX idx_score ON user_scores(score DESC);

-- 查询 Top 10
SELECT * FROM user_scores ORDER BY score DESC LIMIT 10;

-- 查询我的排名
SELECT COUNT(*) + 1 AS rank FROM user_scores WHERE score > (SELECT score FROM user_scores WHERE user_id = 123);
```

**面试追问：**
- Q: 实时排行榜性能瓶颈？ → Redis Sorted Set
- Q: 分数相同按时间排序？ → `ORDER BY score DESC, updated_at ASC`
- Q: 按周/月重置排行榜？ → 分表 `scores_2024W40`，或用 TTL

### 7.3 设计一个消息/评论表

```sql
CREATE TABLE comments (
    id         INT PRIMARY KEY,
    post_id    INT NOT NULL,
    parent_id  INT,                -- NULL = 顶级评论，非 NULL = 回复
    user_id    INT NOT NULL,
    content    TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    INDEX idx_post (post_id, created_at)
);

-- 查询某篇文章的顶级评论（分页）
SELECT * FROM comments WHERE post_id = 1 AND parent_id IS NULL
ORDER BY created_at DESC LIMIT 20;

-- 查询某条评论的回复
SELECT * FROM comments WHERE parent_id = 5 ORDER BY created_at;

-- 评论数
SELECT post_id, COUNT(*) FROM comments GROUP BY post_id;
```

---

## 8. MySQL vs PostgreSQL vs SQLite 面试要点

### 8.1 快速对比

| 方面 | MySQL | PostgreSQL | SQLite |
|------|-------|------------|--------|
| **架构** | C/S | C/S | 嵌入式 |
| **ACID** | InnoDB ✅ | ✅ | ✅ |
| **并发控制** | MVCC | MVCC | 串行写 |
| **索引** | BTree, Hash, 全文 | BTree, Hash, GIN, GiST, BRIN, 全文 | BTree |
| **JSON** | ✅ (5.7+) | ✅✅ (JSONB 更优) | ❌ |
| **窗口函数** | ✅ (8.0+) | ✅ | ✅ (3.25+) |
| **CTE递归** | ✅ (8.0+) | ✅ | ✅ |
| **物化视图** | ❌ | ✅ | ❌ |
| **表分区** | ✅ | ✅ | ❌ |
| **GIS/地理** | ✅ | ✅✅ (PostGIS) | ❌ |
| **全文搜索** | ✅ | ✅ | ❌ (需 FTS5 扩展)|
| **复制** | 主从/组复制 | 流复制/逻辑复制 | ❌ |

### 8.2 面试高频问题

**Q: MySQL 的 InnoDB 和 MyISAM 有什么区别？**
```
InnoDB：事务、行级锁、外键、MVCC → 生产环境选这个
MyISAM：不支持事务、表级锁、全文搜索（旧版）→ 已基本淘汰
```

**Q: SQLite 什么场景下不适合？**
```
1. 高并发写入（多个用户同时写）
2. 需要用户权限管理
3. 海量数据（>100GB）
4. 需要存储过程/自定义函数
```

**Q: PostgreSQL 比 MySQL 强在哪？**
```
1. 更丰富的数据类型（数组、JSONB、范围类型、枚举）
2. 更成熟的查询优化器（复杂查询通常更快）
3. 扩展系统（PostGIS 地理空间、pg_trgm 模糊搜索）
4. 物化视图、表继承、DDL 事务
```

**Q: 数据库连接池一般配多大？**
```
经验公式：connections = ((core_count * 2) + effective_spindle_count)
不一定要大：100 个连接并发查 ≠ 100 倍于 1 个连接的速度
推荐：Tomcat JDBC Pool / HikariCP（Spring Boot 默认）
```

---

## 附：面试 SQL 速查卡

```
┌─────────────────────────────────────────────────────────┐
│  面试题型              关键思路                         │
├─────────────────────────────────────────────────────────┤
│  第二高的值           LIMIT 1 OFFSET 1 / MAX 子查询     │
│  分组 Top N           窗口函数 ROW_NUMBER + PARTITION BY │
│  连续N天              ROW_NUMBER - 日期 = 常数 → 分组   │
│  删除重复             保留 MIN(ID)，删除其他             │
│  行列转换             CASE WHEN + GROUP BY               │
│  环比/同比            LAG / LEAD 窗口函数                │
│  EXISTS vs NOT EXISTS  比 IN/NOT IN 通常更高效           │
│  最左前缀            组合索引 (a,b,c) → a, ab, abc 有效  │
│  分库分表             垂直/水平，Hash/Range 分片         │
│  游标分页             WHERE id > 上一页最大 id LIMIT N   │
│  MVCC                 ReadView + 隐藏字段 TRX_ID         │
│  间隙锁               解决 REPEATABLE READ 下幻读问题    │
└─────────────────────────────────────────────────────────┘
```
