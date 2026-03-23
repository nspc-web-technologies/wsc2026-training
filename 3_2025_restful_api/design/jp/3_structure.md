# プロジェクト構造 - WSC モジュール C

## ディレクトリ構造

```
module_c/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php         # ログイン、登録
│   │   │   ├── AlbumController.php        # アルバムCRUD + カバー
│   │   │   ├── SongController.php         # 曲CRUD + カバー
│   │   │   ├── UserController.php         # ユーザー管理 (Admin)
│   │   │   └── StatisticsController.php   # 統計
│   │   └── Middleware/
│   │       ├── TokenAuth.php              # トークンチェック + BANチェック
│   │       └── AdminAuth.php              # 管理者ロールチェック
│   ├── Models/
│   │   ├── User.php
│   │   ├── Album.php
│   │   ├── Song.php
│   │   ├── Label.php
│   │   ├── SongLabel.php
│   │   └── AccessToken.php
│   └── helpers.php                        # encodeCursor, decodeCursor, validateLimit, paginateQuery, composeAlbumCover
│
├── database/
│   ├── migrations/
│   │   ├── 2025_01_01_000001_create_users_table.php
│   │   ├── 2025_01_01_000002_create_access_tokens_table.php
│   │   ├── 2025_01_01_000003_create_albums_table.php
│   │   ├── 2025_01_01_000004_create_songs_table.php
│   │   ├── 2025_01_01_000005_create_labels_table.php
│   │   └── 2025_01_01_000006_create_song_labels_table.php
│   └── seeders/
│       ├── DatabaseSeeder.php
│       ├── UserSeeder.php
│       └── LabelSeeder.php
│
├── public/
│   └── uploads/
│       └── songs/          # 曲のカバー画像: {song_id}.jpg
│
├── routes/
│   └── api.php             # 全APIルート
│
└── bootstrap/
    └── app.php             # ミドルウェア登録 + JSON 404ハンドラー
```
