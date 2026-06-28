# 🎵 Music Platform — SQL 练习题

> 基于 `music.db`，涵盖从基础到进阶的 SQL 练习。
> 使用 SQLite，建议用 DBeaver / VS Code SQLite 插件 / 命令行练习。

## 快速开始

```powershell
sqlite3 music.db
```

或在命令行直接查询：

```powershell
sqlite3 music.db "SELECT * FROM artists;"
```

---

## 表结构速览

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| `genres` | 音乐流派 | genre_id, name |
| `artists` | 艺术家 | artist_id, name, country, formed_year, genre_id |
| `albums` | 专辑 | album_id, title, artist_id, release_year, label |
| `songs` | 歌曲 | song_id, title, album_id, track_number, duration_seconds, plays |
| `users` | 用户 | user_id, username, email, country, created_at |
| `playlists` | 播放列表 | playlist_id, name, user_id, created_at, is_public |
| `playlist_songs` | 播放列表歌曲关系 | playlist_id, song_id, position, added_at |
| `listening_history` | 听歌历史 | history_id, user_id, song_id, listened_at, duration_played |

---

## Level 1 — 基础查询 (Q1~Q8)

### Q1. 查看所有流派

```sql
-- 写出你的 SQL
```

### Q2. 查看所有艺术家的名字和国家，按国家排序

```sql
-- 写出你的 SQL
```

### Q3. 找出播放量超过 1500 万的歌曲，显示歌曲名和播放量，按播放量降序

```sql
-- 写出你的 SQL
```

### Q4. 找出名字中包含 "Love" 的歌曲（不区分大小写）

```sql
-- 写出你的 SQL
```

### Q5. 找出 2000 年之后成立的艺术家，只显示名字和成立年份

```sql
-- 写出你的 SQL
```

### Q6. 找出时长超过 5 分钟（300 秒）的歌曲，显示歌名和时长（秒）

```sql
-- 写出你的 SQL
```

### Q7. 列出所有不同的专辑厂牌（label），按字母排序

```sql
-- 写出你的 SQL
```

### Q8. 找出所有来自美国（USA）和英国（UK）的艺术家

```sql
-- 写出你的 SQL
```

---

## Level 2 — 条件与排序 (Q9~Q14)

### Q9. 找出歌名以 "S" 开头的歌曲

```sql
-- 写出你的 SQL
```

### Q10. 找出播放量在 800 万到 1200 万之间的歌曲

```sql
-- 写出你的 SQL
```

### Q11. 找出艺术家名包含 "Li" 的艺术家（比如 李荣浩）

```sql
-- 写出你的 SQL
```

### Q12. 显示所有歌曲，按专辑 ID 排序，同一专辑内按曲目序号排序

```sql
-- 写出你的 SQL
```

### Q13. 显示歌曲名和时长（格式化为 "X分Y秒"），取前 10 首最长的

```sql
-- 写出你的 SQL
```

### Q14. 找出所有来自亚洲（中国、台湾、日本、新加坡、香港）的艺术家

```sql
-- 写出你的 SQL
```

---

## Level 3 — 聚合与分组 (Q15~Q20)

### Q15. 统计每个流派的歌曲数量，按数量降序

```sql
-- 写出你的 SQL
```

### Q16. 统计每个国家有多少位艺术家

```sql
-- 写出你的 SQL
```

### Q17. 找出发行专辑超过 2 张的艺术家，显示艺术家名和专辑数

```sql
-- 写出你的 SQL
```

### Q18. 每张专辑的平均歌曲时长，显示专辑名和平均时长（秒），按平均时长降序

```sql
-- 写出你的 SQL
```

### Q19. 统计每个厂牌（label）发行了多少张专辑

```sql
-- 写出你的 SQL
```

### Q20. 计算所有歌曲的总播放量、平均播放量、最高播放量和最低播放量

```sql
-- 写出你的 SQL
```

---

## Level 4 — 多表 JOIN (Q21~Q26)

### Q21. 列出所有专辑的标题和对应艺术家名，按发行年份排序

```sql
-- 写出你的 SQL
```

### Q22. 列出所有歌曲名、所属专辑名和艺术家名

```sql
-- 写出你的 SQL
```

### Q23. 统计每位艺术家有多少首歌曲（即使没有歌曲也要显示为 0）

```sql
-- 写出你的 SQL
```

### Q24. 显示每个播放列表的名称、创建者用户名和歌曲数量，只显示公开播放列表

```sql
-- 写出你的 SQL
```

### Q25. 找出从未被加入任何播放列表的歌曲

```sql
-- 写出你的 SQL
```

### Q26. 找出播放量最高的前 5 首歌曲，显示歌名、艺术家名和播放量

```sql
-- 写出你的 SQL
```

---

## Level 5 — 子查询与 EXISTS (Q27~Q32)

### Q27. 找出从未被任何人听过（不在 listening_history 中）的歌曲

```sql
-- 写出你的 SQL
```

### Q28. 用 EXISTS 重写 Q27

```sql
-- 写出你的 SQL
```

### Q29. 找出被收听次数最多的前 3 首歌曲（基于 listening_history 计数）

```sql
-- 写出你的 SQL
```

### Q30. 找出总播放量高于所有歌曲平均播放量的歌曲

```sql
-- 写出你的 SQL
```

### Q31. 找出每个流派中播放量最高的歌曲（用子查询）

```sql
-- 写出你的 SQL
```

### Q32. 找出那些拥有超过 3 首歌曲被加入播放列表的艺术家

```sql
-- 写出你的 SQL
```

---

## Level 6 — 日期与时间 (Q33~Q36)

### Q33. 按月统计 2024 年的听歌次数，显示月份和听歌次数

```sql
-- 写出你的 SQL
```

### Q34. 找出在 2024 年 10 月之后注册的用户

```sql
-- 写出你的 SQL
```

### Q35. 统计每个时段（上午 6-12 点 / 下午 12-18 点 / 晚上 18-24 点 / 凌晨 0-6 点）的听歌次数

```sql
-- 写出你的 SQL
```

### Q36. 计算每位用户从注册到第一次听歌之间隔了多少天（有听歌记录的用户）

```sql
-- 写出你的 SQL
```

---

## Level 7 — CASE WHEN 与逻辑 (Q37~Q40)

### Q37. 将歌曲按时长分类：短（<180 秒）、中等（180-300 秒）、长（>300 秒），统计每类有多少首歌

```sql
-- 写出你的 SQL
```

### Q38. 将播放量按等级分类：热门（>=1500万）、普通（500万~1500万）、冷门（<500万），显示每首歌的歌名和等级

```sql
-- 写出你的 SQL
```

### Q39. 显示每位用户的用户名和国家，以及一条中文说明"来自 {国家} 的用户"

```sql
-- 写出你的 SQL
```

### Q40. 统计每位用户听过的不同歌曲数量，并标记为"老粉"（>=5首）、"活跃"（2~4首）、"新用户"（0~1首）

```sql
-- 写出你的 SQL
```

---

## Level 8 — 进阶挑战 (Q41~Q46)

### Q41. 每位用户的听歌总时长（秒），按总时长降序

> 提示：`duration_played` 为 NULL 表示完整听完，应取 `songs.duration_seconds`

```sql
-- 写出你的 SQL
```

### Q42. 找出每个用户最近一次听的歌曲，显示用户名、歌曲名和收听时间

```sql
-- 写出你的 SQL
```

### Q43. 找出被不同用户收听次数最多的歌手（按听歌记录中该歌手被听的次数）

```sql
-- 写出你的 SQL
```

### Q44. 用 UNION 找出所有叫 "Love" 的歌曲和所有叫 "Lover" 的歌曲

```sql
-- 写出你的 SQL
```

### Q45. 创建一个视图，包含歌曲名、专辑名、艺术家名和流派名，然后用这个视图查询所有 "Pop" 流派的歌曲

```sql
-- 写出你的 SQL
```

### Q46. 统计每张专辑被用户听过的总次数，显示专辑名和收听次数，哪怕没人听过也要显示为 0

```sql
-- 写出你的 SQL
```

---

## Level 9 — 数据修改 (Q47~Q50)

### Q47. 给 "Bohemian Rhapsody" 增加 100 万次播放量

```sql
-- 写出你的 SQL
```

### Q48. 删除所有没有歌曲的播放列表

```sql
-- 写出你的 SQL
```

### Q49. 为 "Pop" 流派创建一个新艺术家 "New Artist"，再为其创建一张专辑和一首歌

```sql
-- 写出你的 SQL
```

### Q50. 给所有时长 > 300 秒的歌曲增加 10% 的播放量（用 UPDATE 一次完成）

```sql
-- 写出你的 SQL
```

---

## 💡 提示（想不出来再看）

<details>
<summary>点击展开参考答案</summary>

### Q1. 查看所有流派

```sql
SELECT * FROM genres;
```

### Q2. 按国家排序艺术家

```sql
SELECT name, country FROM artists ORDER BY country;
```

### Q3. 播放量超过 1500 万的歌曲

```sql
SELECT title, plays FROM songs WHERE plays > 15000000 ORDER BY plays DESC;
```

### Q4. 名字包含 "Love" 的歌曲

```sql
SELECT title FROM songs WHERE title LIKE '%Love%';
```

### Q5. 2000 年后成立的艺术家

```sql
SELECT name, formed_year FROM artists WHERE formed_year > 2000;
```

### Q6. 时长超过 5 分钟的歌曲

```sql
SELECT title, duration_seconds FROM songs WHERE duration_seconds > 300;
```

### Q7. 所有不同的厂牌

```sql
SELECT DISTINCT label FROM albums ORDER BY label;
```

### Q8. 来自美国或英国的艺术家

```sql
SELECT name, country FROM artists WHERE country IN ('USA', 'UK');
```

### Q9. 歌名以 S 开头

```sql
SELECT title FROM songs WHERE title LIKE 'S%';
```

### Q10. 播放量在 800 万到 1200 万之间

```sql
SELECT title, plays FROM songs
WHERE plays BETWEEN 8000000 AND 12000000
ORDER BY plays;
```

### Q11. 艺术家名包含 "Li"

```sql
SELECT name FROM artists WHERE name LIKE '%Li%';
```

### Q12. 按专辑 + 曲目序号排序

```sql
SELECT album_id, track_number, title FROM songs
ORDER BY album_id, track_number;
```

### Q13. 时长格式化为 X分Y秒

```sql
SELECT title,
    CAST(duration_seconds / 60 AS INTEGER) || '分' ||
    CAST(duration_seconds % 60 AS INTEGER) || '秒' AS duration_display
FROM songs
ORDER BY duration_seconds DESC
LIMIT 10;
```

### Q14. 亚洲艺术家

```sql
SELECT name, country FROM artists
WHERE country IN ('中国', '台湾', '日本', '新加坡', '香港');
```

### Q15. 每个流派的歌曲数量

```sql
SELECT g.name, COUNT(s.song_id) AS song_count
FROM genres g
LEFT JOIN artists a ON g.genre_id = a.genre_id
LEFT JOIN albums al ON a.artist_id = al.artist_id
LEFT JOIN songs s ON al.album_id = s.album_id
GROUP BY g.name
ORDER BY song_count DESC;
```

### Q16. 每个国家的艺术家数量

```sql
SELECT country, COUNT(*) AS artist_count
FROM artists
GROUP BY country
ORDER BY artist_count DESC;
```

### Q17. 发行专辑超过 2 张的艺术家

```sql
SELECT a.name, COUNT(al.album_id) AS album_count
FROM artists a
JOIN albums al ON a.artist_id = al.artist_id
GROUP BY a.name
HAVING COUNT(al.album_id) > 2
ORDER BY album_count DESC;
```

### Q18. 每张专辑的平均歌曲时长

```sql
SELECT al.title, AVG(s.duration_seconds) AS avg_duration
FROM albums al
JOIN songs s ON al.album_id = s.album_id
GROUP BY al.title
ORDER BY avg_duration DESC;
```

### Q19. 每个厂牌的专辑数量

```sql
SELECT label, COUNT(*) AS album_count
FROM albums
GROUP BY label
ORDER BY album_count DESC;
```

### Q20. 歌曲播放量统计

```sql
SELECT
    SUM(plays) AS total_plays,
    AVG(plays) AS avg_plays,
    MAX(plays) AS max_plays,
    MIN(plays) AS min_plays
FROM songs;
```

### Q21. 专辑 + 艺术家

```sql
SELECT al.title AS album, a.name AS artist, al.release_year
FROM albums al
JOIN artists a ON al.artist_id = a.artist_id
ORDER BY al.release_year;
```

### Q22. 歌曲 + 专辑 + 艺术家

```sql
SELECT s.title AS song, al.title AS album, a.name AS artist
FROM songs s
JOIN albums al ON s.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
ORDER BY a.name, al.release_year, s.track_number;
```

### Q23. 每位艺术家的歌曲数量（含 0）

```sql
SELECT a.name, COUNT(s.song_id) AS song_count
FROM artists a
LEFT JOIN albums al ON a.artist_id = al.artist_id
LEFT JOIN songs s ON al.album_id = s.album_id
GROUP BY a.name
ORDER BY song_count DESC;
```

### Q24. 公开播放列表的歌曲数量

```sql
SELECT p.name AS playlist, u.username AS creator, COUNT(ps.song_id) AS song_count
FROM playlists p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN playlist_songs ps ON p.playlist_id = ps.playlist_id
WHERE p.is_public = 1
GROUP BY p.playlist_id
ORDER BY song_count DESC;
```

### Q25. 从未被加入播放列表的歌曲

```sql
SELECT s.title
FROM songs s
WHERE s.song_id NOT IN (
    SELECT DISTINCT song_id FROM playlist_songs
);
```

### Q26. 播放量前 5 的歌曲（含艺术家）

```sql
SELECT s.title, a.name AS artist, s.plays
FROM songs s
JOIN albums al ON s.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
ORDER BY s.plays DESC
LIMIT 5;
```

### Q27. 从未被听过的歌曲（NOT IN）

```sql
SELECT s.title FROM songs s
WHERE s.song_id NOT IN (
    SELECT DISTINCT song_id FROM listening_history
);
```

### Q28. 从未被听过的歌曲（NOT EXISTS）

```sql
SELECT s.title FROM songs s
WHERE NOT EXISTS (
    SELECT 1 FROM listening_history lh
    WHERE lh.song_id = s.song_id
);
```

### Q29. 被收听次数最多的前 3 首

```sql
SELECT s.title, a.name AS artist, COUNT(lh.history_id) AS listen_count
FROM listening_history lh
JOIN songs s ON lh.song_id = s.song_id
JOIN albums al ON s.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
GROUP BY s.song_id
ORDER BY listen_count DESC
LIMIT 3;
```

### Q30. 高于平均播放量的歌曲

```sql
SELECT title, plays FROM songs
WHERE plays > (SELECT AVG(plays) FROM songs)
ORDER BY plays DESC;
```

### Q31. 每个流派中播放量最高的歌曲

```sql
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
)
ORDER BY g.name;
```

### Q32. 拥有超过 3 首歌曲被加入播放列表的艺术家

```sql
SELECT a.name, COUNT(DISTINCT ps.song_id) AS song_in_playlists
FROM artists a
JOIN albums al ON a.artist_id = al.artist_id
JOIN songs s ON al.album_id = s.album_id
JOIN playlist_songs ps ON s.song_id = ps.song_id
GROUP BY a.artist_id
HAVING COUNT(DISTINCT ps.song_id) > 3
ORDER BY song_in_playlists DESC;
```

### Q33. 按月统计 2024 年听歌次数

```sql
SELECT STRFTIME('%Y-%m', listened_at) AS month, COUNT(*) AS listen_count
FROM listening_history
WHERE listened_at >= '2024-01-01' AND listened_at < '2025-01-01'
GROUP BY month
ORDER BY month;
```

### Q34. 2024 年 10 月之后注册的用户

```sql
SELECT username, created_at FROM users
WHERE created_at > '2024-10-01'
ORDER BY created_at;
```

### Q35. 按时间段统计听歌次数

```sql
SELECT
    CASE
        WHEN CAST(STRFTIME('%H', listened_at) AS INTEGER) BETWEEN 6 AND 11 THEN '上午'
        WHEN CAST(STRFTIME('%H', listened_at) AS INTEGER) BETWEEN 12 AND 17 THEN '下午'
        WHEN CAST(STRFTIME('%H', listened_at) AS INTEGER) BETWEEN 18 AND 23 THEN '晚上'
        ELSE '凌晨'
    END AS time_period,
    COUNT(*) AS listen_count
FROM listening_history
GROUP BY time_period
ORDER BY listen_count DESC;
```

### Q36. 注册到首次听歌的天数

```sql
SELECT u.username, u.created_at,
    MIN(lh.listened_at) AS first_listen,
    JULIANDAY(MIN(lh.listened_at)) - JULIANDAY(u.created_at) AS days_to_first_listen
FROM users u
JOIN listening_history lh ON u.user_id = lh.user_id
GROUP BY u.user_id
HAVING days_to_first_listen IS NOT NULL
ORDER BY days_to_first_listen;
```

### Q37. 按时长分类统计歌曲

```sql
SELECT
    CASE
        WHEN duration_seconds < 180 THEN '短 (<3分)'
        WHEN duration_seconds BETWEEN 180 AND 300 THEN '中等 (3~5分)'
        ELSE '长 (>5分)'
    END AS duration_category,
    COUNT(*) AS song_count
FROM songs
GROUP BY duration_category
ORDER BY song_count DESC;
```

### Q38. 按播放量等级显示歌曲

```sql
SELECT
    s.title,
    s.plays,
    CASE
        WHEN s.plays >= 15000000 THEN '🔥 热门'
        WHEN s.plays BETWEEN 5000000 AND 14999999 THEN '👍 普通'
        ELSE '❄️ 冷门'
    END AS popularity
FROM songs s
ORDER BY s.plays DESC;
```

### Q39. 显示用户及其国家说明

```sql
SELECT username, country,
    '来自 ' || country || ' 的用户' AS description
FROM users;
```

### Q40. 按听歌数量标记用户活跃度

```sql
SELECT u.username,
    COUNT(DISTINCT lh.song_id) AS distinct_songs,
    CASE
        WHEN COUNT(DISTINCT lh.song_id) >= 5 THEN '🌟 老粉'
        WHEN COUNT(DISTINCT lh.song_id) BETWEEN 2 AND 4 THEN '👍 活跃'
        ELSE '🆕 新用户'
    END AS user_level
FROM users u
LEFT JOIN listening_history lh ON u.user_id = lh.user_id
GROUP BY u.user_id
ORDER BY distinct_songs DESC;
```

### Q41. 用户听歌总时长

```sql
SELECT u.username,
    SUM(COALESCE(lh.duration_played, s.duration_seconds)) AS total_seconds,
    ROUND(SUM(COALESCE(lh.duration_played, s.duration_seconds)) / 60.0, 1) AS total_minutes
FROM users u
LEFT JOIN listening_history lh ON u.user_id = lh.user_id
LEFT JOIN songs s ON lh.song_id = s.song_id
GROUP BY u.user_id
ORDER BY total_seconds DESC;
```

### Q42. 每个用户最近一次听的歌

```sql
SELECT u.username, s.title, lh.listened_at
FROM listening_history lh
JOIN users u ON lh.user_id = u.user_id
JOIN songs s ON lh.song_id = s.song_id
WHERE lh.listened_at = (
    SELECT MAX(lh2.listened_at)
    FROM listening_history lh2
    WHERE lh2.user_id = lh.user_id
)
ORDER BY u.username;
```

### Q43. 被不同用户收听最多的歌手

```sql
SELECT ar.name AS artist,
    COUNT(DISTINCT lh.user_id) AS unique_listeners,
    COUNT(lh.history_id) AS total_listens
FROM listening_history lh
JOIN songs s ON lh.song_id = s.song_id
JOIN albums al ON s.album_id = al.album_id
JOIN artists ar ON al.artist_id = ar.artist_id
GROUP BY ar.artist_id
ORDER BY unique_listeners DESC, total_listens DESC;
```

### Q44. 用 UNION 查询

```sql
SELECT title, '包含 Love' AS note FROM songs WHERE title LIKE '%Love%'
UNION
SELECT title, '包含 Lover' AS note FROM songs WHERE title LIKE '%Lover%'
ORDER BY title;
```

### Q45. 创建视图并查询

```sql
CREATE VIEW v_song_details AS
SELECT s.title AS song, al.title AS album, a.name AS artist, g.name AS genre
FROM songs s
JOIN albums al ON s.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
JOIN genres g ON a.genre_id = g.genre_id;

-- 然后用视图查询
SELECT * FROM v_song_details WHERE genre = 'Pop';
```

### Q46. 每张专辑的收听次数（含 0）

```sql
SELECT al.title AS album,
    COUNT(lh.history_id) AS listen_count
FROM albums al
LEFT JOIN songs s ON al.album_id = s.album_id
LEFT JOIN listening_history lh ON s.song_id = lh.song_id
GROUP BY al.album_id
ORDER BY listen_count DESC;
```

### Q47. 增加播放量

```sql
UPDATE songs SET plays = plays + 1000000
WHERE title = 'Bohemian Rhapsody';
```

### Q48. 删除空播放列表

```sql
DELETE FROM playlists
WHERE playlist_id NOT IN (
    SELECT DISTINCT playlist_id FROM playlist_songs
);
```

### Q49. 新增艺术家、专辑和歌曲

```sql
-- 先找到 Pop 的 genre_id
INSERT INTO artists(name, country, formed_year, genre_id)
VALUES ('New Artist', 'China', 2024, 1);

INSERT INTO albums(title, artist_id, release_year, label)
VALUES ('First Album', 11, 2024, 'Independent');

INSERT INTO songs(title, album_id, track_number, duration_seconds, plays)
VALUES ('First Song', 16, 1, 210, 0);
```

### Q50. 批量更新长歌曲播放量

```sql
UPDATE songs
SET plays = CAST(plays * 1.1 AS INTEGER)
WHERE duration_seconds > 300;
```

</details>
