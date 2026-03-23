# データベース設計 - WSC モジュール C

## テーブル構造

### 1. users

#### フィールド

- `id` - 主キー (INT, AUTO_INCREMENT)
- `username` - ユーザー名 (VARCHAR(255), UNIQUE)
- `email` - メールアドレス (VARCHAR(255), UNIQUE)
- `password` - ハッシュ化されたパスワード (VARCHAR(255))
- `role` - ユーザーロール (ENUM('admin','user'), デフォルト: 'user')
- `is_banned` - BANフラグ (BOOLEAN, デフォルト: FALSE)
- `created_at` - 作成日時 (TIMESTAMP)
- `updated_at` - 更新日時 (TIMESTAMP)

#### 制約

- UNIQUE: `username`
- UNIQUE: `email`

### 2. access_tokens

#### フィールド

- `id` - 主キー (INT, AUTO_INCREMENT)
- `user_id` - ユーザーID (INT, 外部キー)
- `token` - MD5トークン (VARCHAR(32), UNIQUE)
- `created_at` - 作成日時 (TIMESTAMP)

#### 制約

- UNIQUE: `token`
- FOREIGN KEY: `user_id` → `users(id)` (ON DELETE CASCADE)

#### トークンロジック

- 生成方法: `md5($user->username)` (小文字の16進数)
- ログイン時: user_idで既存トークンをDELETE → 新しいトークンをINSERT
- ログアウト時: user_idでトークンをDELETE

### 3. albums

#### フィールド

- `id` - 主キー (INT, AUTO_INCREMENT)
- `title` - アルバムタイトル (VARCHAR(255))
- `artist` - アーティスト名 (VARCHAR(255))
- `release_year` - リリース年 (INT)
- `genre` - ジャンル (VARCHAR(255))
- `description` - 説明 (TEXT)
- `publisher_id` - パブリッシャーのユーザーID (INT, 外部キー)
- `deleted_at` - ソフトデリートのタイムスタンプ (TIMESTAMP, NULLABLE)
- `created_at` - 作成日時 (TIMESTAMP)
- `updated_at` - 更新日時 (TIMESTAMP)

#### 制約

- FOREIGN KEY: `publisher_id` → `users(id)` (ON DELETE RESTRICT)

### 4. songs

#### フィールド

- `id` - 主キー (INT, AUTO_INCREMENT)
- `album_id` - アルバムID (INT, 外部キー)
- `title` - 曲タイトル (VARCHAR(255))
- `duration_seconds` - 再生時間（秒） (INT)
- `order` - アルバム内の順序 (INT)
- `lyrics` - 歌詞 (TEXT)
- `is_cover` - カバーフラグ (BOOLEAN, デフォルト: FALSE)
- `cover_image_path` - カバー画像パス (VARCHAR(512), NULLABLE)
- `view_count` - 閲覧数 (INT, デフォルト: 0)
- `deleted_at` - ソフトデリートのタイムスタンプ (TIMESTAMP, NULLABLE)
- `created_at` - 作成日時 (TIMESTAMP)
- `updated_at` - 更新日時 (TIMESTAMP)

#### 制約

- FOREIGN KEY: `album_id` → `albums(id)` (ON DELETE RESTRICT)

#### カバー画像の保存

- DB値 (`cover_image_path`): `uploads/songs/{song_id}.jpg` (public/からの相対パス)
- 物理パス: `public/uploads/songs/{song_id}.jpg` (= `public_path('uploads/songs/{song_id}.jpg')`)
- URL: `/api/songs/{song_id}/cover`

### 5. labels

#### フィールド

- `id` - 主キー (INT, AUTO_INCREMENT)
- `name` - ラベル名 (VARCHAR(255), UNIQUE)

#### 初期データ

| id | name |
|----|------|
| 1 | Pop |
| 2 | Rock |
| 3 | Hip-Hop |
| 4 | Electronic |
| 5 | Jazz |
| 6 | Classical |
| 7 | Chill |
| 8 | Country |

### 6. song_labels

#### フィールド

- `id` - 主キー (INT, AUTO_INCREMENT)
- `song_id` - 曲ID (INT, 外部キー)
- `label_id` - ラベルID (INT, 外部キー)

#### 制約

- UNIQUE: (`song_id`, `label_id`)
- FOREIGN KEY: `song_id` → `songs(id)` (ON DELETE CASCADE)
- FOREIGN KEY: `label_id` → `labels(id)` (ON DELETE CASCADE)

## ER図

```
users (1) ─────< (N) albums
users (1) ─────< (N) access_tokens
albums (1) ─────< (N) songs
songs (N) >─────< (N) labels  [via song_labels]
```

## 初期データ

### users

| id | username | email | password | role | is_banned |
|----|----------|-------|----------|------|-----------|
| 1 | admin | admin@web.wsa | bcrypt('adminpass') | admin | false |
| 2 | user1 | user1@web.wsa | bcrypt('user1pass') | user | false |
| 3 | user2 | user2@web.wsa | bcrypt('user2pass') | user | false |

## ビジネスルール

1. ソフトデリート: albumsとsongsの`deleted_at`カラム（物理削除なし）
2. カスケードソフトデリート: アルバムがソフトデリートされた場合、そのすべての曲もソフトデリートされる
3. トークン管理: MD5(username)の固定値、ログイン時にDELETE→INSERT
4. ラベルバリデーション: ラベルはlabelsテーブルに存在する必要がある
5. 順序管理: 新しい曲のorder = MAX(order)+1（ソフトデリート済みも含む）、削除後の再順序付けなし
6. 管理者制約: 常に少なくとも1人の管理者が存在する必要がある
7. カバー画像: DBには`uploads/songs/{song_id}.jpg`（相対パス）を保存。物理パスは`public/uploads/songs/{song_id}.jpg`。JPEG のみ
