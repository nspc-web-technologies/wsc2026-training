# Project Structure - WSC Module C

## Directory Structure

```
module_c/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php         # Login, Register
│   │   │   ├── AlbumController.php        # Albums CRUD + Cover
│   │   │   ├── SongController.php         # Songs CRUD + Cover
│   │   │   ├── UserController.php         # User management (Admin)
│   │   │   └── StatisticsController.php   # Statistics
│   │   └── Middleware/
│   │       ├── TokenAuth.php              # Token check + BAN check
│   │       └── AdminAuth.php              # Admin role check
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
│       └── songs/          # Song cover images: {song_id}.jpg
│
├── routes/
│   └── api.php             # All API routes
│
└── bootstrap/
    └── app.php             # Middleware registration + JSON 404 handler
```
