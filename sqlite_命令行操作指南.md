# SQLite 命令行操作指南

> 如何在命令行中写 SQL、执行查询、查看结果。
> 基于 `music.db` 演示，所有操作在 Windows PowerShell / cmd 下完成。

---

## 1. 打开数据库

```powershell
# 进入项目目录
cd C:\work\Mysql-notes

# 打开 music.db（交互模式）
sqlite3 music.db
```

进入交互模式后，提示符变成：

```
sqlite>
```

现在就**可以直接输入 SQL 语句**了。

---

## 2. 在交互模式中写 SQL

进入 `sqlite>` 后，直接敲 SQL：

```sql
-- 查看所有艺术家
sqlite> SELECT * FROM artists;
1|周杰伦 (Jay Chou)|台湾|2000|1
2|Taylor Swift|USA|2006|1
3|久石让 (Joe Hisaishi)|日本|1981|3
...

-- 带条件查询
sqlite> SELECT name, country FROM artists WHERE country = 'USA';
Taylor Swift|USA
Metallica|USA

-- 多行 SQL（回车换行继续输入，分号结束）
sqlite> SELECT title, plays
   ...> FROM songs
   ...> WHERE plays > 15000000
   ...> ORDER BY plays DESC;
```

**规则：**
- 每句 SQL 以 `;` 结尾
- 可以跨多行写，回车只是换行
- 不写分号的话，SQLite 认为你没写完，继续等待
- 支持上下箭头翻阅历史命令

### 退出交互模式

```sql
sqlite> .quit
-- 或按 Ctrl+D（Windows 上有时不行）
-- 或按 Ctrl+C（强制退出）
```

---

## 3. 让输出更好看

默认输出是管道格式 `列1|列2|列3`，不好读。执行前先设置：

```powershell
sqlite3 music.db
```

```sql
-- 显示列名
sqlite> .headers on

-- 列对齐（推荐）
sqlite> .mode column

-- 然后查询
sqlite> SELECT name, country, formed_year FROM artists;
name                      country     formed_year
------------------------  ----------- -----------
周杰伦 (Jay Chou)         台湾         2000
Taylor Swift              USA          2006
久石让 (Joe Hisaishi)     日本         1981
Queen                     UK           1970
邓紫棋 (G.E.M.)           香港         2008
...
```

### 其他好用模式

```sql
-- 带框线表格（最漂亮）
sqlite> .mode box
sqlite> SELECT name, country FROM artists LIMIT 3;
┌────────────────────────┬─────────┐
│         name           │ country │
├────────────────────────┼─────────┤
│ 周杰伦 (Jay Chou)      │ 台湾    │
│ Taylor Swift           │ USA     │
│ 久石让 (Joe Hisaishi)  │ 日本    │
└────────────────────────┴─────────┘

-- Markdown 格式（可以复制到文档里）
sqlite> .mode markdown
sqlite> SELECT name, country FROM artists LIMIT 3;
| name | country |
|------|---------|
| 周杰伦 (Jay Chou) | 台湾 |
| Taylor Swift | USA |
| 久石让 (Joe Hisaishi) | 日本 |

-- CSV 格式（导出用）
sqlite> .mode csv
sqlite> SELECT name, country FROM artists;
name,country
"周杰伦 (Jay Chou)",台湾
Taylor Swift,USA
"久石让 (Joe Hisaishi)",日本

-- JSON 格式
sqlite> .mode json
sqlite> SELECT name, country FROM artists LIMIT 2;
[{"name":"周杰伦 (Jay Chou)","country":"台湾"},
{"name":"Taylor Swift","country":"USA"}]
```

**一次性设置好（推荐）：**

```sql
sqlite> .headers on
sqlite> .mode column
sqlite> .timer on        -- 顺便打开计时
```

---

## 4. 单行模式（不进入交互，直接查）

适合快速查一下数据，**不用进入交互模式**：

```powershell
# 基本用法：sqlite3 数据库 "SQL语句"
sqlite3 music.db "SELECT * FROM genres;"

# 带输出格式
sqlite3 -header -column music.db "SELECT name, country FROM artists;"

# 简写参数
sqlite3 -header -column music.db "SELECT COUNT(*) FROM songs;"

# 查完就退出了，适合脚本里用
```

**搭配 PowerShell 管道很好用：**

```powershell
# 用 Format-Table 进一步美化
sqlite3 -header -column music.db "SELECT title, plays FROM songs ORDER BY plays DESC LIMIT 5;" | Format-Table

# 导出结果到文件
sqlite3 -header -csv music.db "SELECT * FROM artists;" > artists.csv

# 把结果作为变量
$songs = sqlite3 music.db "SELECT title FROM songs WHERE plays > 15000000;"
$songs
```

---

## 5. 完整的练习工作流

### 场景：做一道练习题

```powershell
# 1. 打开数据库
sqlite3 music.db

# 2. 设置好格式
.headers on
.mode column
.timer on

# 3. 先看看表结构，回忆一下有哪些字段
.schema songs

# 4. 写 SQL 查询
SELECT s.title, a.name AS artist, s.plays
FROM songs s
JOIN albums al ON s.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
WHERE s.plays > 15000000
ORDER BY s.plays DESC;

# 5. 如果写错了，改一下再执行（用 ↑ 键调出上一条）
# 6. 查完了，.quit 退出
.quit
```

### 场景：不记得表名了

```powershell
sqlite3 music.db ".tables"
# 输出: albums  artists  genres  listening_history  playlist_songs  playlists  songs  users
```

### 场景：不记得某张表的字段

```powershell
sqlite3 music.db ".schema songs"
# 输出:
# CREATE TABLE songs (
#     song_id  INTEGER PRIMARY KEY,
#     title    TEXT NOT NULL,
#     album_id INTEGER NOT NULL REFERENCES albums(album_id),
#     ...
# );
```

### 场景：用 .sql 文件跑批量的 SQL

先建一个文件 `my_query.sql`：

```sql
-- my_query.sql
.headers on
.mode column

-- 播放量最高的 5 首歌
SELECT s.title, a.name AS artist, s.plays
FROM songs s
JOIN albums al ON s.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
ORDER BY s.plays DESC
LIMIT 5;

-- 每个流派歌曲数量
SELECT g.name, COUNT(s.song_id) AS song_count
FROM genres g
LEFT JOIN artists a ON g.genre_id = a.genre_id
LEFT JOIN albums al ON a.artist_id = al.artist_id
LEFT JOIN songs s ON al.album_id = s.album_id
GROUP BY g.name
ORDER BY song_count DESC;
```

然后一次性执行：

```powershell
sqlite3 music.db < my_query.sql
```

---

## 6. 常用命令速查

### 点命令（`.` 开头，只在交互模式有效）

| 命令 | 作用 | 示例 |
|------|------|------|
| `.tables` | 列出所有表 | `.tables` |
| `.tables %song%` | 模糊搜索表名 | `.tables %artist%` |
| `.schema` | 查看所有表结构 | `.schema` |
| `.schema songs` | 查看指定表结构 | `.schema songs albums` |
| `.indexes` | 查看索引 | `.indexes songs` |
| `.headers on` | 显示列名 | `.headers on` |
| `.mode column` | 列对齐模式 | `.mode column` |
| `.mode box` | 带框线表格 | `.mode box` |
| `.mode markdown` | Markdown 格式 | `.mode markdown` |
| `.mode csv` | CSV 格式 | `.mode csv` |
| `.mode json` | JSON 格式 | `.mode json` |
| `.timer on` | 显示查询耗时 | `.timer on` |
| `.read file.sql` | 执行 SQL 文件 | `.read seed.sql` |
| `.output file.txt` | 结果写入文件 | `.output result.txt` |
| `.import file.csv tbl` | 导入 CSV 到表 | `.import data.csv songs` |
| `.dump` | 导出整个数据库 | `.dump > backup.sql` |
| `.dump songs` | 导出指定表 | `.dump songs` |
| `.backup file.db` | 原子备份 | `.backup music_backup.db` |
| `.restore file.db` | 从备份恢复 | `.restore music_backup.db` |
| `.quit` | 退出 | `.quit` |

### 命令行参数（不在交互模式）

```powershell
# 语法
sqlite3 [选项] 数据库 "SQL语句"

# 常用选项
sqlite3 -header music.db "SELECT * FROM artists;"
sqlite3 -column music.db "SELECT * FROM artists;"
sqlite3 -csv music.db "SELECT * FROM artists;" > out.csv
sqlite3 -json music.db "SELECT * FROM artists;"
sqlite3 -markdown music.db "SELECT * FROM artists;"

# 执行 SQL 文件
sqlite3 music.db < script.sql

# 查看帮助
sqlite3 -help
```

---

## 7. 完整示例：从头练习一遍

```powershell
# ===== 第一步：打开数据库 =====
sqlite3 music.db

# ===== 第二步：设置格式 =====
.headers on
.mode box
.timer on

# ===== 第三步：探索数据 =====
.tables
.schema artists
.schema songs

# ===== 第四步：写 SQL 练习 =====

-- 所有 Pop 流派艺术家
SELECT a.name, a.country
FROM artists a
JOIN genres g ON a.genre_id = g.genre_id
WHERE g.name = 'Pop';

-- 平均歌曲时长最长的专辑 Top 5
SELECT al.title, ROUND(AVG(s.duration_seconds), 1) AS avg_duration
FROM albums al
JOIN songs s ON al.album_id = s.album_id
GROUP BY al.title
ORDER BY avg_duration DESC
LIMIT 5;

-- 被收听次数最多的艺术家
SELECT ar.name, COUNT(lh.history_id) AS total_listens
FROM listening_history lh
JOIN songs s ON lh.song_id = s.song_id
JOIN albums al ON s.album_id = al.album_id
JOIN artists ar ON al.artist_id = ar.artist_id
GROUP BY ar.artist_id
ORDER BY total_listens DESC
LIMIT 5;

-- 无播放列表的歌曲
SELECT title FROM songs
WHERE song_id NOT IN (SELECT song_id FROM playlist_songs);

-- 创建视图
CREATE VIEW v_artist_songs AS
SELECT ar.name AS artist, al.title AS album, s.title AS song, s.duration_seconds
FROM artists ar
JOIN albums al ON ar.artist_id = al.artist_id
JOIN songs s ON al.album_id = s.album_id;

-- 用视图查询
SELECT * FROM v_artist_songs WHERE artist LIKE '%Taylor%';

-- 查看查询计划
EXPLAIN QUERY PLAN SELECT * FROM songs WHERE title LIKE '%Love%';

# ===== 第五步：退出 =====
.quit
```

---

## 一句话总结

```
sqlite3 music.db              ← 进入交互模式（可写多行 SQL）
sqlite3 music.db "SQL语句"    ← 单行模式（查完即退）
sqlite3 music.db < file.sql   ← 批量执行 SQL 文件
```

练习的时候建议进**交互模式**，写多行 SQL、改错重试都很方便。
