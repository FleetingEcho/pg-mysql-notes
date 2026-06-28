-- ============================================================
-- 🎵 Music Platform — SQLite Seed Script
-- 用于 SQL 练习的示例数据库
-- 用法: sqlite3 music.db < seed_music_db.sql
-- ============================================================

-- 使用 SQLite 支持的语法
-- PRIMARY KEY 用 rowid 隐式创建，或显式 INTEGER PRIMARY KEY

PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. 流派 (Genres)
-- ============================================================
DROP TABLE IF EXISTS listening_history;
DROP TABLE IF EXISTS playlist_songs;
DROP TABLE IF EXISTS playlists;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS genres;

CREATE TABLE genres (
    genre_id   INTEGER PRIMARY KEY,
    name       TEXT NOT NULL UNIQUE
);

INSERT INTO genres (genre_id, name) VALUES
(1, 'Pop'),
(2, 'Rock'),
(3, 'Classical'),
(4, 'Electronic'),
(5, 'Jazz'),
(6, 'R&B'),
(7, 'Hip Hop');

-- ============================================================
-- 2. 艺术家 (Artists)
-- ============================================================
CREATE TABLE artists (
    artist_id    INTEGER PRIMARY KEY,
    name         TEXT NOT NULL,
    country      TEXT NOT NULL,
    formed_year  INTEGER,
    genre_id     INTEGER REFERENCES genres(genre_id)
);

INSERT INTO artists (artist_id, name, country, formed_year, genre_id) VALUES
(1,  '周杰伦 (Jay Chou)',  '台湾',    2000, 1),
(2,  'Taylor Swift',       'USA',     2006, 1),
(3,  '久石让 (Joe Hisaishi)', '日本', 1981, 3),
(4,  'Queen',               'UK',      1970, 2),
(5,  '邓紫棋 (G.E.M.)',    '香港',    2008, 1),
(6,  'Daft Punk',           'France',  1993, 4),
(7,  '李荣浩 (Li Ronghao)', '中国',    2010, 1),
(8,  'Adele',               'UK',      2006, 1),
(9,  '林俊杰 (JJ Lin)',     '新加坡',  2003, 1),
(10, 'Metallica',           'USA',     1981, 2);

-- ============================================================
-- 3. 专辑 (Albums)
-- ============================================================
CREATE TABLE albums (
    album_id     INTEGER PRIMARY KEY,
    title        TEXT NOT NULL,
    artist_id    INTEGER NOT NULL REFERENCES artists(artist_id),
    release_year INTEGER NOT NULL,
    label        TEXT
);

INSERT INTO albums (album_id, title, artist_id, release_year, label) VALUES
(1,  '叶惠美',         1,  2003, 'Sony Music'),
(2,  '七里香',         1,  2004, 'Sony Music'),
(3,  '1989',           2,  2014, 'Big Machine'),
(4,  'Folklore',       2,  2020, 'Republic'),
(5,  'Kiki''s Delivery Service OST', 3, 1989, 'Studio Ghibli'),
(6,  'A Night at the Opera', 4, 1975, 'EMI'),
(7,  '新的心跳',       5,  2015, 'Hummingbird Music'),
(8,  'Random Access Memories', 6, 2013, 'Columbia'),
(9,  '模特',           7,  2013, '华纳音乐'),
(10, '21',              8,  2011, 'XL Recordings'),
(11, '第二天堂',       9,  2004, '海蝶音乐'),
(12, 'Master of Puppets', 10, 1986, 'Elektra'),
(13, '麻雀',           7,  2020, '华纳音乐'),
(14, 'Fearless',       2,  2008, 'Big Machine'),
(15, 'Lover',          2,  2019, 'Republic');

-- ============================================================
-- 4. 歌曲 (Songs)
-- ============================================================
CREATE TABLE songs (
    song_id         INTEGER PRIMARY KEY,
    title           TEXT NOT NULL,
    album_id        INTEGER NOT NULL REFERENCES albums(album_id),
    track_number    INTEGER NOT NULL,
    duration_seconds INTEGER NOT NULL,
    plays           INTEGER NOT NULL DEFAULT 0
);

INSERT INTO songs (song_id, title, album_id, track_number, duration_seconds, plays) VALUES
-- 叶惠美 (album 1)
(1,  '以父之名',     1, 1, 340, 12500000),
(2,  '晴天',          1, 2, 269, 15800000),
(3,  '东风破',        1, 3, 315, 14200000),
(4,  '三年二班',      1, 4, 278, 8900000),
-- 七里香 (album 2)
(5,  '七里香',        2, 1, 298, 13500000),
(6,  '止战之殇',      2, 2, 277, 7200000),
(7,  '园游会',        2, 3, 245, 6800000),
(8,  '我的地盘',      2, 4, 223, 6100000),
-- 1989 (album 3)
(9,  'Shake It Off',  3, 1, 219, 18500000),
(10, 'Blank Space',   3, 2, 231, 17200000),
(11, 'Style',         3, 3, 231, 14800000),
(12, 'Bad Blood',     3, 4, 211, 13200000),
-- Folklore (album 4)
(13, 'Cardigan',      4, 1, 239, 12500000),
(14, 'Exile',         4, 2, 285, 11200000),
(15, 'The 1',         4, 3, 210, 9800000),
(16, 'Betty',         4, 4, 294, 8500000),
-- Kiki's Delivery Service (album 5)
(17, '海の見える街',   5, 1, 214, 5600000),
(18, '仕事はじめ',    5, 2, 178, 4200000),
(19, '旅立ち',        5, 3, 225, 4800000),
(20, 'かあさんのほうき', 5, 4, 198, 3900000),
-- A Night at the Opera (album 6)
(21, 'Bohemian Rhapsody', 6, 1, 355, 22000000),
(22, "You're My Best Friend", 6, 2, 172, 11500000),
(23, 'Love of My Life', 6, 3, 209, 10800000),
(24, "I'm in Love with My Car", 6, 4, 185, 5200000),
-- 新的心跳 (album 7)
(25, '多远都要在一起', 7, 1, 275, 9800000),
(26, '再见',          7, 2, 218, 8500000),
(27, '新的心跳',      7, 3, 227, 7200000),
(28, '一路逆风',      7, 4, 244, 6100000),
-- Random Access Memories (album 8)
(29, 'Get Lucky',     8, 1, 368, 19500000),
(30, 'Instant Crush', 8, 2, 338, 11200000),
(31, 'Lose Yourself to Dance', 8, 3, 329, 9800000),
(32, 'Giorgio by Moroder', 8, 4, 549, 6500000),
-- 模特 (album 9)
(33, '李白',          9, 1, 254, 14500000),
(34, '模特',          9, 2, 263, 12800000),
(35, '作曲家',        9, 3, 226, 10500000),
(36, '不将就',        9, 4, 281, 11200000),
-- 21 (album 10)
(37, 'Rolling in the Deep', 10, 1, 228, 21000000),
(38, 'Someone Like You', 10, 2, 285, 19800000),
(39, 'Set Fire to the Rain', 10, 3, 242, 16200000),
(40, 'Turning Tables', 10, 4, 264, 10500000),
-- 第二天堂 (album 11)
(41, '江南',          11, 1, 259, 15200000),
(42, '豆浆油条',      11, 2, 245, 7800000),
(43, '美人鱼',        11, 3, 271, 9200000),
(44, '第二天堂',      11, 4, 249, 6800000),
-- Master of Puppets (album 12)
(45, 'Master of Puppets', 12, 1, 515, 16500000),
(46, 'Battery',        12, 2, 313, 12800000),
(47, 'Welcome Home (Sanitarium)', 12, 3, 387, 11500000),
(48, 'Orion',          12, 4, 508, 7800000),
-- 麻雀 (album 13)
(49, '麻雀',          13, 1, 278, 10800000),
(50, '老友记',        13, 2, 225, 7200000),
(51, '等着等着就老了', 13, 3, 252, 6500000),
(52, '我爱你',        13, 4, 241, 5800000),
-- Fearless (album 14)
(53, 'Love Story',    14, 1, 235, 19500000),
(54, 'You Belong with Me', 14, 2, 231, 17800000),
(55, 'Fearless',      14, 3, 241, 10500000),
(56, 'Fifteen',       14, 4, 294, 9200000),
-- Lover (album 15)
(57, 'ME!',           15, 1, 193, 14200000),
(58, 'You Need to Calm Down', 15, 2, 191, 13500000),
(59, 'Lover',         15, 3, 221, 12800000),
(60, 'The Archer',    15, 4, 211, 9500000);

-- ============================================================
-- 5. 用户 (Users)
-- ============================================================
CREATE TABLE users (
    user_id    INTEGER PRIMARY KEY,
    username   TEXT NOT NULL UNIQUE,
    email      TEXT NOT NULL,
    country    TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (date('now'))
);

INSERT INTO users (user_id, username, email, country, created_at) VALUES
(1, 'alice_99',    'alice@example.com',    'USA',      '2023-01-15'),
(2, 'bob_music',   'bob@example.com',      'UK',       '2023-03-20'),
(3, '小明',         'xiaoming@example.com', '中国',     '2023-05-10'),
(4, 'sakura_jpop', 'sakura@example.com',   '日本',     '2023-06-01'),
(5, 'rockfan42',   'rockfan@example.com',  '德国',     '2023-08-12'),
(6, 'melody_lover','melody@example.com',   '法国',     '2024-01-05'),
(7, 'dj_shadow',   'shadow@example.com',   '加拿大',   '2024-02-14'),
(8, 'lily_pad',    'lily@example.com',     '澳大利亚', '2024-04-22'),
(9, 'tom_guitar',  'tom@example.com',      '巴西',     '2024-06-30'),
(10, '阿杰',        'ajie@example.com',    '台湾',     '2024-08-15');

-- ============================================================
-- 6. 播放列表 (Playlists)
-- ============================================================
CREATE TABLE playlists (
    playlist_id INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    user_id     INTEGER NOT NULL REFERENCES users(user_id),
    created_at  TEXT NOT NULL DEFAULT (date('now')),
    is_public   INTEGER NOT NULL DEFAULT 1
);

INSERT INTO playlists (playlist_id, name, user_id, created_at, is_public) VALUES
(1, '经典华语',    3,  '2023-07-01', 1),
(2, 'Workout Hits',  2,  '2023-09-15', 1),
(3, '深夜听',      10, '2024-09-01', 0),
(4, 'Pop Queens',    1,  '2024-03-10', 1),
(5, 'Rock Classics', 5,  '2024-05-20', 1),
(6, '开车专用',    9,  '2024-08-01', 0),
(7, '学习背景音乐', 4,  '2024-06-15', 1),
(8, '最新最爱',    8,  '2024-10-01', 1);

-- ============================================================
-- 7. 播放列表歌曲 (Playlist Songs)
-- ============================================================
CREATE TABLE playlist_songs (
    playlist_id INTEGER NOT NULL REFERENCES playlists(playlist_id),
    song_id     INTEGER NOT NULL REFERENCES songs(song_id),
    position    INTEGER NOT NULL,
    added_at    TEXT NOT NULL DEFAULT (datetime('now')),
    PRIMARY KEY (playlist_id, song_id)
);

INSERT INTO playlist_songs (playlist_id, song_id, position, added_at) VALUES
-- 经典华语 (playlist 1)
(1, 1,  1,  '2023-07-01'),  -- 以父之名
(1, 2,  2,  '2023-07-01'),  -- 晴天
(1, 5,  3,  '2023-07-01'),  -- 七里香
(1, 33, 4,  '2023-07-01'),  -- 李白
(1, 41, 5,  '2023-08-15'),  -- 江南
(1, 25, 6,  '2024-01-10'),  -- 多远都要在一起
(1, 49, 7,  '2024-09-20'),  -- 麻雀
-- Workout Hits (playlist 2)
(2, 9,  1,  '2023-09-15'),  -- Shake It Off
(2, 29, 2,  '2023-09-15'),  -- Get Lucky
(2, 45, 3,  '2023-10-01'),  -- Master of Puppets
(2, 37, 4,  '2023-10-15'),  -- Rolling in the Deep
(2, 12, 5,  '2024-02-10'),  -- Bad Blood
-- 深夜听 (playlist 3)
(3, 38, 1,  '2024-09-01'),  -- Someone Like You
(3, 49, 2,  '2024-09-05'),  -- 麻雀
(3, 23, 3,  '2024-09-10'),  -- Love of My Life
(3, 59, 4,  '2024-09-15'),  -- Lover
(3, 30, 5,  '2024-09-20'),  -- Instant Crush
(3, 17, 6,  '2024-09-25'),  -- 海の見える街
-- Pop Queens (playlist 4)
(4, 9,  1,  '2024-03-10'),  -- Shake It Off
(4, 10, 2,  '2024-03-10'),  -- Blank Space
(4, 37, 3,  '2024-03-10'),  -- Rolling in the Deep
(4, 38, 4,  '2024-03-15'),  -- Someone Like You
(4, 53, 5,  '2024-04-01'),  -- Love Story
(4, 57, 6,  '2024-05-01'),  -- ME!
(4, 58, 7,  '2024-06-01'),  -- You Need to Calm Down
(4, 25, 8,  '2024-07-01'),  -- 多远都要在一起
(4, 33, 9,  '2024-08-01'),  -- 李白
-- Rock Classics (playlist 5)
(5, 21, 1,  '2024-05-20'),  -- Bohemian Rhapsody
(5, 45, 2,  '2024-05-20'),  -- Master of Puppets
(5, 46, 3,  '2024-05-20'),  -- Battery
(5, 24, 4,  '2024-06-01'),  -- I'm in Love with My Car
(5, 22, 5,  '2024-06-15'),  -- You're My Best Friend
-- 开车专用 (playlist 6)
(6, 9,  1,  '2024-08-01'),  -- Shake It Off
(6, 29, 2,  '2024-08-01'),  -- Get Lucky
(6, 33, 3,  '2024-08-05'),  -- 李白
(6, 41, 4,  '2024-08-10'),  -- 江南
(6, 31, 5,  '2024-08-15'),  -- Lose Yourself to Dance
(6, 5,  6,  '2024-08-20'),  -- 七里香
-- 学习背景音乐 (playlist 7)
(7, 17, 1,  '2024-06-15'),  -- 海の見える街
(7, 18, 2,  '2024-06-15'),  -- 仕事はじめ
(7, 19, 3,  '2024-06-20'),  -- 旅立ち
(7, 20, 4,  '2024-06-25'),  -- かあさんのほうき
(7, 30, 5,  '2024-07-01'),  -- Instant Crush
(7, 48, 6,  '2024-07-15'),  -- Orion
-- 最新最爱 (playlist 8)
(8, 49, 1,  '2024-10-01'),  -- 麻雀
(8, 59, 2,  '2024-10-01'),  -- Lover
(8, 13, 3,  '2024-10-01'),  -- Cardigan
(8, 50, 4,  '2024-10-05'),  -- 老友记
(8, 60, 5,  '2024-10-10');  -- The Archer

-- ============================================================
-- 8. 听歌历史 (Listening History)
-- ============================================================
CREATE TABLE listening_history (
    history_id      INTEGER PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users(user_id),
    song_id         INTEGER NOT NULL REFERENCES songs(song_id),
    listened_at     TEXT NOT NULL,
    duration_played INTEGER  -- 实际听了多少秒（NULL = 完整听完）
);

INSERT INTO listening_history (history_id, user_id, song_id, listened_at, duration_played) VALUES
-- alice_99 的听歌记录
(1,  1, 9,  '2024-10-01 08:15:00', NULL),
(2,  1, 10, '2024-10-01 08:19:00', NULL),
(3,  1, 37, '2024-10-01 14:30:00', 120),
(4,  1, 53, '2024-10-02 09:00:00', NULL),
(5,  1, 58, '2024-10-02 09:04:00', NULL),
(6,  1, 38, '2024-10-03 22:15:00', NULL),
-- bob_music
(7,  2, 29, '2024-10-01 07:30:00', NULL),
(8,  2, 31, '2024-10-01 07:36:00', 180),
(9,  2, 9,  '2024-10-01 07:42:00', NULL),
(10, 2, 45, '2024-10-02 18:00:00', NULL),
(11, 2, 21, '2024-10-03 20:00:00', 310),
-- 小明
(12, 3, 2,  '2024-10-01 12:00:00', NULL),
(13, 3, 5,  '2024-10-01 12:05:00', NULL),
(14, 3, 1,  '2024-10-01 12:10:00', NULL),
(15, 3, 33, '2024-10-02 20:30:00', NULL),
(16, 3, 41, '2024-10-03 21:00:00', NULL),
(17, 3, 49, '2024-10-04 10:15:00', NULL),
(18, 3, 25, '2024-10-05 16:00:00', 180),
-- sakura_jpop
(19, 4, 17, '2024-10-01 10:00:00', NULL),
(20, 4, 18, '2024-10-01 10:04:00', NULL),
(21, 4, 19, '2024-10-01 10:07:00', NULL),
(22, 4, 20, '2024-10-01 10:11:00', NULL),
(23, 4, 2,  '2024-10-02 15:00:00', NULL),
-- rockfan42
(24, 5, 21, '2024-10-01 19:00:00', NULL),
(25, 5, 45, '2024-10-01 19:06:00', NULL),
(26, 5, 46, '2024-10-01 19:11:00', NULL),
(27, 5, 47, '2024-10-02 20:00:00', 300),
(28, 5, 48, '2024-10-03 21:00:00', NULL),
(29, 5, 24, '2024-10-04 22:00:00', 150),
-- melody_lover
(30, 6, 59, '2024-10-02 11:00:00', NULL),
(31, 6, 30, '2024-10-02 14:00:00', NULL),
(32, 6, 23, '2024-10-03 09:30:00', NULL),
-- dj_shadow
(33, 7, 29, '2024-10-01 23:00:00', NULL),
(34, 7, 30, '2024-10-01 23:07:00', NULL),
(35, 7, 31, '2024-10-01 23:13:00', 200),
(36, 7, 32, '2024-10-02 00:00:00', 400),
(37, 7, 21, '2024-10-03 22:00:00', NULL),
-- lily_pad
(38, 8, 13, '2024-10-05 09:00:00', NULL),
(39, 8, 49, '2024-10-05 10:00:00', NULL),
(40, 8, 59, '2024-10-05 11:00:00', NULL),
(41, 8, 50, '2024-10-06 14:00:00', 150),
-- tom_guitar
(42, 9, 33, '2024-10-03 08:00:00', NULL),
(43, 9, 41, '2024-10-03 08:05:00', NULL),
(44, 9, 5,  '2024-10-04 09:00:00', NULL),
(45, 9, 21, '2024-10-05 17:00:00', 350),
-- 阿杰
(46, 10, 2,  '2024-10-01 22:00:00', NULL),
(47, 10, 5,  '2024-10-01 22:05:00', NULL),
(48, 10, 33, '2024-10-02 23:00:00', NULL),
(49, 10, 49, '2024-10-05 21:30:00', NULL),
(50, 10, 38, '2024-10-06 22:00:00', NULL);

-- ============================================================
-- 🎯 验证数据完整性
-- ============================================================
SELECT '✅ 数据加载完成!' AS status;
SELECT '流派: ' || COUNT(*) || ' 个' FROM genres;
SELECT '艺术家: ' || COUNT(*) || ' 位' FROM artists;
SELECT '专辑: ' || COUNT(*) || ' 张' FROM albums;
SELECT '歌曲: ' || COUNT(*) || ' 首' FROM songs;
SELECT '用户: ' || COUNT(*) || ' 个' FROM users;
SELECT '播放列表: ' || COUNT(*) || ' 个' FROM playlists;
SELECT '播放列表歌曲: ' || COUNT(*) || ' 条' FROM playlist_songs;
SELECT '听歌记录: ' || COUNT(*) || ' 条' FROM listening_history;
