# API設計 - WSC モジュール C

## 概要

ベースURL: `http://wsXX.worldskills.org/XX_module_c/api`

認証: `X-Authorization: Bearer <token>` (User/Admin APIで必須)

レスポンス形式: `application/json`

エラーレスポンス形式:
```json
{
  "success": false,
  "message": "Error message here"
}
```

## エラーメッセージ

| Message | HTTPステータス | 条件 |
|---------|---------------|------|
| Access Token is required | 401 | X-Authorizationヘッダーなし |
| Invalid Access Token | 401 | 無効/期限切れ/存在しないトークン |
| Admin access required | 403 | 非管理者がAdmin APIにアクセス |
| Access denied | 403 | ログイン済みユーザーが自分に属さないリソースを操作しようとした |
| User is banned | 403 | BANされたユーザーが保護された機能にアクセス |
| Not Found | 404 | ルートまたはリソースが存在しない |
| Cover Not Found | 404 | アルバムまたは曲のカバー画像が存在しない |
| Too many covers provided | 400 | アルバムに既にis_cover=trueの曲が3曲ある（上限） |
| Login failed | 400 | usernameまたはpasswordが不正 |
| Username already taken | 409 | usernameが既に使用されている |
| Email already taken | 409 | メールアドレスが既に使用されている |
| Validation failed | 400 | フィールドの不足/不正 |
| Invalid parameter | 400 | 無効なクエリパラメータ (limit>100, 数値でない, <1) |
| Invalid cursor | 400 | 不正なカーソル |
| Invalid year format | 400 | 無効なyearパラメータ (例: "abc" や "2000-1990") |
| Invalid file type | 400 | アップロードファイルがJPEGでない |
| User not found | 404 | 管理者が存在しないuser_idに対して操作 |
| Cannot ban self | 400 | 管理者が自分自身をBANしようとした |
| Last admin demotion forbidden | 403 | 最後の管理者を'user'ロールに降格しようとした |
| Banned user update failed | 409 | BANされたユーザーのロールを更新できない |
| Cannot ban another admin | 403 | 管理者が他の管理者をBANしようとした |

## カーソルベースページネーション

- デフォルト: 1ページあたり10件
- `limit`パラメータ: 1〜100（<1 または >100 または数値でない場合Invalid parameter）
- 実装: `limit + 1`件をクエリ; count ≤ limit → 次ページなし; count = limit + 1 → 最後のレコードを破棄しnext_cursorを設定
- `next_cursor`: 現在のページの最後のレコード（limit番目のレコード）のID → `{"id":N}` → Base64エンコード → 次ページがない場合null
- `prev_cursor`: `cursor`パラメータが未指定の場合（最初のページ）null; 結果件数 = 0の場合null; それ以外は`（最初のアイテムID - 1）` → `{"id":N}` → Base64エンコード → 最初のアイテムID - 1 <= 0の場合null
- prev_cursorに関する注意: この設計は単方向カーソル（`WHERE id > cursor_id`）を使用。`prev_cursor`はそれ以前のデータが存在することを示す。その値は逆方向ナビゲーションのためには設計されていない。`null`か非`null`かのみが重要。
- `cursor`パラメータ: `cursor_id`にデコード → `WHERE id > cursor_id`を適用して次/前ページを取得
- 無効なカーソル: `Invalid cursor` (400)

## Public API（認証不要）

### 1. ユーザーログイン

`POST /api/login`

#### リクエストBody (application/json)

| フィールド | 型 | 必須 |
|-----------|-----|------|
| username | string | はい |
| password | string | はい |

#### ログインフロー
1. 必須フィールドのバリデーション (username, password) → `Validation failed` (400)
2. usernameでユーザーを検索 → 見つからない: `Login failed` (400)
3. Hash::checkでパスワード照合 → 不一致: `Login failed` (400)
4. is_bannedチェック → BANされている: `User is banned` (403)
5. user_idで既存トークンをDELETE → 新しいトークン(md5(username))をINSERT
6. token + userを返す

#### レスポンス (200)
```json
{
  "success": true,
  "data": {
    "token": "24c9e15e52afc47c225b757e7bee1f9d",
    "user": {
      "id": 1,
      "username": "user1",
      "email": "user1@web.wsa",
      "role": "user",
      "created_at": "2025-10-23T14:30:00.000Z",
      "updated_at": "2025-10-23T14:30:00.000Z"
    }
  }
}
```

### 2. ユーザー登録

`POST /api/register`

#### リクエストBody (application/json)

| フィールド | 型 | 必須 | バリデーション |
|-----------|-----|------|---------------|
| username | string | はい | ユニーク |
| email | string | はい | 有効なメール形式、ユニーク |
| password | string | はい | - |

#### バリデーション順序
1. 必須フィールドチェック → `Validation failed` (400)
2. メール形式チェック → `Validation failed` (400)
3. usernameのユニークチェック → `Username already taken` (409)
4. emailのユニークチェック → `Email already taken` (409)
5. bcryptでパスワードをハッシュ → ユーザーをINSERT (role='user', is_banned=false)

#### レスポンス (201)
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 4,
      "username": "user4",
      "email": "user4@web.wsa",
      "role": "user",
      "created_at": "2025-10-23T15:00:00.000Z",
      "updated_at": "2025-10-23T15:00:00.000Z"
    }
  }
}
```

### 3. 全アルバム取得

`GET /api/albums`

#### クエリパラメータ

| パラメータ | 型 | 説明 |
|-----------|-----|------|
| capital | string | タイトルの頭文字でフィルタリング — 単一文字（大文字小文字不問）; 空文字列は未指定として扱う（フィルターなし） |
| year | string | 年でフィルタリング 例: "2020" や "2018-2020"（BETWEEN、両端含む） |
| limit | number | 1ページあたりのレコード数 (1-100, デフォルト: 10) |
| cursor | string | ページネーション用カーソル |

> ⚠️ パラメータ名の曖昧さ: 仕様のパラメータ表では`capital`だが、例のURLでは`filter=A`を使用。両方サポート: `$capital = $request->query('capital') ?? $request->query('filter');`

#### Yearバリデーション
- 空文字列: 未指定として扱う（フィルターなし） — `capital`や`keyword`と一貫性あり
- 単一年: 数値でなければならない → 数値でない場合 `Invalid year format` (400)
- 範囲: `YYYY-YYYY`形式に一致し、開始 ≤ 終了でなければならない → そうでない場合 `Invalid year format` (400)

#### フィルターロジック
- `capital`: `WHERE title LIKE 'A%'`（MySQLではデフォルトで大文字小文字不問）
- `year` 単一: `WHERE release_year = 2020`
- `year` 範囲: `WHERE release_year BETWEEN 2018 AND 2020`
- 複数フィルター: AND条件
- カーソル + フィルターの同時適用: カーソルが提供された場合でも、すべてのアクティブフィルター（capital, year）は引き続き適用される必要がある
- ソフトデリート除外: `WHERE deleted_at IS NULL`
- ソート: `ORDER BY id ASC`

#### レスポンス (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 11,
      "title": "A Night at the Opera",
      "artist": "Queen",
      "release_year": 1975,
      "publisher": {
        "id": 1,
        "username": "user1",
        "email": "user1@web.wsa"
      }
    }
  ],
  "meta": {
    "prev_cursor": "eyJpZCI6MTB9",
    "next_cursor": "eyJpZCI6MjB9"
  }
}
```

### 4. アルバム詳細取得

`GET /api/albums/{album_id}`

#### ルートパラメータ

| パラメータ | 型 |
|-----------|-----|
| album_id | integer |

#### ロジック
- ソフトデリート除外: `WHERE id = ? AND deleted_at IS NULL`
- 見つからない: `Not Found` (404)

#### レスポンス (200)
```json
{
  "success": true,
  "data": {
    "id": 12,
    "title": "Abbey Road",
    "artist": "The Beatles",
    "release_year": 1969,
    "genre": "Rock",
    "description": "The eleventh studio album by the English rock band the Beatles.",
    "created_at": "2025-10-20T10:00:00.000Z",
    "updated_at": "2025-10-20T10:00:00.000Z",
    "publisher": {
      "id": 2,
      "username": "user2",
      "email": "user2@web.wsa"
    }
  }
}
```

### 5. アルバムカバー取得

`GET /api/albums/{album_id}/cover`

#### ロジック
1. アルバムを検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. `is_cover=true AND deleted_at IS NULL`の曲を取得 ORDER BY `order` ASC
3. Count = 0: `Cover Not Found` (404)
4. Count > 3: `Too many covers provided` (400)
5. 各曲について: cover_image_pathがnullでないこととファイルの存在を確認 → `Cover Not Found` (404); GDロード失敗 → `Cover Not Found` (404)
6. GDで500×500pxの画像を合成:
   - 1枚: 500×500全体
   - 2枚: 左250×500 + 右250×500
   - 3枚: 左250×500 + 右上250×250 + 右下250×250
7. `image/jpeg`として出力

#### レスポンス (200)
`Content-Type: image/jpeg` (バイナリ)

### 6. アルバム内の曲取得

`GET /api/albums/{album_id}/songs`

#### ロジック
- アルバムを検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
- 曲を取得: `WHERE album_id = ? AND deleted_at IS NULL ORDER BY order ASC`
- ページネーションなし（全件返却）
- 曲がないアルバム: 空配列を返す

#### レスポンス (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 101,
      "album_id": 12,
      "title": "Come Together",
      "label": ["Rock", "Pop"],
      "duration_seconds": 259,
      "order": 1,
      "is_cover": false,
      "cover_image_url": "/api/songs/101/cover"
    }
  ]
}
```

### 7. 全曲取得

`GET /api/songs`

#### クエリパラメータ

| パラメータ | 型 | 説明 |
|-----------|-----|------|
| keyword | string | 曲タイトルでフィルタリング（部分一致）; 空文字列は未指定として扱う（フィルターなし） |
| limit | number | 1ページあたりのレコード数 (1-100, デフォルト: 10) |
| cursor | string | ページネーション用カーソル |

> ⚠️ パラメータ名の曖昧さ: 仕様のパラメータ表では`keyword`だが、例のURLでは`filter[keyword]=love`を使用。両方サポート: `$keyword = $request->query('keyword') ?? $request->input('filter.keyword');`

#### フィルターロジック
- `keyword`: `WHERE title LIKE '%love%'`
- カーソル + フィルターの同時適用: カーソルが提供された場合でも、keywordフィルターは引き続き適用される必要がある
- ソフトデリート除外: `WHERE deleted_at IS NULL`
- ソート: `ORDER BY id ASC`

#### レスポンス (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 102,
      "album_id": 12,
      "title": "Something",
      "label": ["Rock"],
      "duration_seconds": 182,
      "album_title": "Abbey Road",
      "cover_image_url": "/api/songs/102/cover"
    }
  ],
  "meta": {
    "next_cursor": "eyJpZCI6MTAyfQ==",
    "prev_cursor": null
  }
}
```

### 8. 曲カバー取得

`GET /api/songs/{song_id}/cover`

#### ロジック
1. 曲を検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. cover_image_pathがnullでないこととファイルの存在を確認 → `Cover Not Found` (404)
3. GDでバリデーション: `imagecreatefromjpeg(public_path($cover_image_path))` → 失敗: `Cover Not Found` (404); 成功時: `imagedestroy($img)` を即座に実行
4. 元のファイルをそのまま返す: `response()->file(public_path($cover_image_path), ['Content-Type' => 'image/jpeg'])`
   - `imagejpeg()`で再エンコードしないこと — 再エンコードはバイナリを変更し画質を劣化させる

#### レスポンス (200)
`Content-Type: image/jpeg` (バイナリ)

## User API（認証必須）

ミドルウェア: TokenAuth
- `X-Authorization`ヘッダーの存在を確認 → `Access Token is required` (401)
- `Bearer `プレフィックスを除去 → プレフィックスがないかトークンが空の場合: `Invalid Access Token` (401)
- access_tokensテーブルでトークンを検索 → 見つからない: `Invalid Access Token` (401)
- ユーザーのis_banned=true: `User is banned` (403)

### 9. ユーザーログアウト

`POST /api/logout`

#### ロジック
- access_tokensからDELETE WHERE user_id = 認証済みユーザーID
- 注意: トークン行が存在しなくてもDELETEは安全に呼び出せる（0行影響はエラーではない）

#### レスポンス (200)
```json
{
  "success": true
}
```

### 10. 曲詳細取得

`GET /api/songs/{song_id}`

#### ロジック
1. 曲を検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. view_countをインクリメント: `Song::where('id', $id)->increment('view_count')`（クエリビルダー、モデルの`$song->increment()`は`updated_at`を更新してしまうので使用しない）
3. モデルをリフレッシュ: `$song->refresh()` で更新されたview_countを取得
4. 更新されたview_count付きの曲を返す

#### レスポンス (200)
```json
{
  "success": true,
  "data": {
    "id": 101,
    "album_id": 12,
    "title": "Come Together",
    "duration_seconds": 259,
    "order": 1,
    "label": ["Rock"],
    "view_count": 124,
    "is_cover": false,
    "lyrics": "Here come old flat top...",
    "cover_image_url": "/api/songs/101/cover",
    "created_at": "2025-10-20T10:01:00.000Z",
    "updated_at": "2025-10-20T10:01:00.000Z"
  }
}
```

### 11. 統計結果取得

`GET /api/statistics`

#### クエリパラメータ

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| metrics | string | はい | `song` \| `album` \| `label` |
| labels | string | いいえ | metrics=songとmetrics=labelの場合、例: "Pop,Rock" |

#### バリデーション
- metricsが未指定または無効な値: `Validation failed` (400)

#### metrics=song

- 全曲を返す（ソフトデリート除外）
- `labels`パラメータが提供された場合（非空）: 指定されたラベルの少なくとも1つを持つ曲にフィルタリング（例: `labels=Pop,Rock` → ラベルがPopまたはRockの曲）; 存在しないラベル名はサイレントに無視; 空文字列は未指定として扱う（フィルターなし）
- ORDER BY view_count DESC
- ページネーションなし

#### レスポンス — metrics=song (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 101,
      "album_id": 12,
      "title": "Come Together",
      "duration_seconds": 259,
      "order": 1,
      "label": ["Rock"],
      "view_count": 123,
      "is_cover": false,
      "lyrics": "Here come old flat top...",
      "cover_image_url": "/api/songs/101/cover",
      "created_at": "2025-10-20T10:01:00.000Z",
      "updated_at": "2025-10-20T10:01:00.000Z"
    }
  ]
}
```

#### metrics=album

- 全アルバムを返す（ソフトデリート除外）
- total_view_count = アルバム内の非ソフトデリート曲のview_countのSUM（曲がない場合0）
- ORDER BY total_view_count DESC
- ページネーションなし

#### レスポンス — metrics=album (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 13,
      "title": "My Album",
      "artist": "My Band",
      "release_year": 2025,
      "genre": "Indie Rock",
      "description": "Description.",
      "publisher": {
        "id": 1,
        "username": "admin",
        "email": "admin@web.wsa"
      },
      "created_at": "2025-10-23T16:00:00.000Z",
      "updated_at": "2025-10-23T16:05:00.000Z",
      "total_view_count": 17
    }
  ]
}
```

#### metrics=label

- 全ラベルを返す（または`labels`パラメータでフィルタリング）
- `labels`パラメータ: カンマ区切りのラベル名 例: "Pop,Rock" → 一致するラベルのみにフィルタリング; 存在しない名前はサイレントに無視; 空文字列は未指定として扱う（全ラベルを返す）
- 各ラベル: view_count DESCでトップ10曲（ソフトデリート除外）
- total_view_count = それらトップ10曲のview_countのSUM（ラベルに曲がない場合0）
- ラベルをtotal_view_count DESCでソート
- ページネーションなし

#### レスポンス — metrics=label (200)
```json
{
  "success": true,
  "data": [
    {
      "total_view_count": 6,
      "label": "Rock",
      "songs": [
        {
          "id": 101,
          "album_id": 12,
          "title": "Come Together",
          "duration_seconds": 259,
          "order": 1,
          "label": ["Rock"],
          "view_count": 4,
          "is_cover": false,
          "lyrics": "Here come old flat top...",
          "cover_image_url": "/api/songs/101/cover",
          "created_at": "2025-10-20T10:01:00.000Z",
          "updated_at": "2025-10-20T10:01:00.000Z"
        }
      ]
    }
  ]
}
```

## Admin API（認証 + 管理者ロール必須）

追加ミドルウェア: AdminAuth
- ユーザーのrole = 'admin'を確認 → 管理者でない場合 `Admin access required` (403)

### 12. 全ユーザー取得

`GET /api/users`

#### クエリパラメータ

| パラメータ | 型 | 説明 |
|-----------|-----|------|
| cursor | string | ページネーション用カーソル |
| limit | number | 1ページあたりのレコード数 (1-100, デフォルト: 10) |

#### ロジック
- 全ユーザーを返す（フィルターなし）
- ソート: `ORDER BY id ASC`

#### レスポンス (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "username": "user1",
      "email": "user1@web.wsa",
      "role": "user",
      "is_banned": false,
      "created_at": "2025-10-23T14:30:00.000Z"
    }
  ],
  "meta": {
    "next_cursor": "eyJpZCI6MTF9",
    "prev_cursor": null
  }
}
```

### 13. ユーザーロール更新

`PUT /api/users/{user_id}`

#### リクエストBody (application/json)

| フィールド | 型 | 必須 | バリデーション |
|-----------|-----|------|---------------|
| role | string | はい | 'admin'または'user'のみ |

#### バリデーション/ロジック順序
1. user_idでユーザーを検索 → 見つからない: `User not found` (404)
2. roleが未指定または無効な値: `Validation failed` (400)
3. 対象ユーザーのis_banned=true: `Banned user update failed` (409)
4. 対象が最後の管理者 + 新しいrole='user': `Last admin demotion forbidden` (403)
5. ユーザーのroleをUPDATE

#### レスポンス (200)
```json
{
  "success": true,
  "data": {
    "id": 2,
    "username": "user2",
    "email": "user2@web.wsa",
    "role": "admin",
    "is_banned": false,
    "created_at": "2025-10-23T15:00:00.000Z",
    "updated_at": "2025-10-23T16:20:00.000Z"
  }
}
```

### 14. ユーザーBAN

`PUT /api/users/{user_id}/ban`

#### ロジック順序
1. user_idでユーザーを検索 → 見つからない: `User not found` (404)
2. user_id = 認証済み管理者のID: `Cannot ban self` (400)
3. 対象ユーザーのrole = 'admin': `Cannot ban another admin` (403)
4. 既にBANされている場合: 現在のユーザーデータで200を返す（冪等）
5. is_banned = trueにUPDATE

#### レスポンス (200)
```json
{
  "success": true,
  "data": {
    "id": 2,
    "username": "user2",
    "email": "user2@web.wsa",
    "role": "user",
    "is_banned": true,
    "updated_at": "2025-10-23T16:21:00.000Z"
  }
}
```

### 15. ユーザーBAN解除

`PUT /api/users/{user_id}/unban`

#### ロジック順序
1. user_idでユーザーを検索 → 見つからない: `User not found` (404)
2. 既にBAN解除されている場合: 現在のユーザーデータで200を返す（冪等）
3. is_banned = falseにUPDATE

#### レスポンス (200)
```json
{
  "success": true,
  "data": {
    "id": 2,
    "username": "user2",
    "email": "user2@web.wsa",
    "role": "user",
    "is_banned": false,
    "updated_at": "2025-10-23T16:22:00.000Z"
  }
}
```

### 16. 新規アルバム作成

`POST /api/albums`

#### リクエストBody (multipart/form-data)

| フィールド | 型 | 必須 |
|-----------|-----|------|
| title | string | はい |
| artist | string | はい |
| release_year | number | はい |
| genre | string | はい |
| description | string | はい |

#### バリデーション
- 全フィールド必須 → `Validation failed` (400)
- release_yearは数値でなければならない → `Validation failed` (400)
- publisher_id = 認証済みユーザーID（自動設定）

#### ロジック
1. 全必須フィールドとrelease_yearの数値バリデーション（上記参照）
2. アルバムをINSERT (publisher_id = $request->authUser->id)
3. publisherをロード: `$album->load('publisher')`
4. publisherオブジェクト付きのアルバムを返す (201)

#### レスポンス (201)
```json
{
  "success": true,
  "data": {
    "id": 13,
    "title": "My New Album",
    "artist": "My Band",
    "release_year": 2025,
    "genre": "Indie Rock",
    "description": "This is the description.",
    "publisher": {
      "id": 2,
      "username": "user2",
      "email": "user2@web.wsa"
    },
    "created_at": "2025-10-23T16:00:00.000Z",
    "updated_at": "2025-10-23T16:00:00.000Z"
  }
}
```

### 17. アルバム詳細更新

`PUT /api/albums/{album_id}`

#### リクエストBody (application/json)

| フィールド | 型 | 必須 |
|-----------|-----|------|
| title | string | はい |
| description | string | はい |

#### ロジック
1. アルバムを検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. 必須フィールドのバリデーション → `Validation failed` (400)
3. title, descriptionのみをUPDATE
4. publisherをロード: `$album->load('publisher')`
5. publisherオブジェクト付きのアルバムを返す (200)

#### レスポンス (200)
```json
{
  "success": true,
  "data": {
    "id": 13,
    "title": "My Updated Album Title",
    "artist": "My Band",
    "release_year": 2025,
    "genre": "Indie Rock",
    "description": "Updated description.",
    "publisher": {
      "id": 2,
      "username": "user2",
      "email": "user2@web.wsa"
    },
    "created_at": "2025-10-23T16:00:00.000Z",
    "updated_at": "2025-10-23T16:05:00.000Z"
  }
}
```

### 18. アルバム削除

`DELETE /api/albums/{album_id}`

#### ロジック
1. アルバムを検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. アルバムをソフトデリート: `UPDATE albums SET deleted_at = NOW()`
3. 全曲をソフトデリート: `UPDATE songs SET deleted_at = NOW() WHERE album_id = ? AND deleted_at IS NULL`

#### レスポンス (200)
```json
{
  "success": true
}
```

### 19. アルバムに曲を追加

`POST /api/albums/{album_id}/songs`

#### リクエストBody (multipart/form-data)

| フィールド | 型 | 必須 |
|-----------|-----|------|
| title | string | はい |
| duration_seconds | number | はい |
| label | string | いいえ（オプション、カンマ区切り） |
| lyrics | string | はい |
| cover_image | file (image/jpeg) | はい |
| is_cover | boolean ("true"/"1" or "false"/"0") | はい |

> ⚠️ `Is_cover`の大文字小文字: 仕様ではbodyテーブルで`Is_cover`（大文字のI）を使用。早期に解決する: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover');` — この解決済みの値を必須チェックとパースの両方に使用する。

#### ロジック
1. アルバムを検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. is_coverフィールドを解決: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover')`
3. 必須フィールドのバリデーション (title, duration_seconds, lyrics, cover_image, $isCoverRaw !== null) → `Validation failed` (400)
4. duration_secondsは数値でなければならない → `Validation failed` (400)
5. cover_imageのMIMEタイプでJPEGをバリデーション: `$request->file('cover_image')->getMimeType() === 'image/jpeg'` → `Invalid file type` (400)
6. is_coverのパース: $isCoverRaw "true"/"1" → true, それ以外 → false
7. labelが提供され非空の場合: カンマで分割 → 名前を重複除去 → 各名前についてlabelsテーブルで名前検索（大文字小文字不問） → 見つからない場合 `Validation failed` (400); 挿入用のラベルIDを収集; labelが未指定または空文字列の場合 → ラベルなし（空配列）
8. is_cover=trueの場合: アルバムの現在のis_coverカウント（ソフトデリート除外）< 3を確認 → 3を超える場合 `Too many covers provided` (400)
9. orderを計算: `SELECT MAX(order) FROM songs WHERE album_id = ?`（ソフトデリート済みも含む） + 1、nullの場合デフォルト1
10. 曲をINSERT (cover_image_path = null 一時的) → song_idを取得
11. cover_imageを`public_path('uploads/songs/{song_id}.jpg')`に保存 → 失敗時: INSERTした曲をDELETE → 500を返す
12. songs SET cover_image_path = `uploads/songs/{song_id}.jpg`（public/からの相対パス）をUPDATE
13. song_labelsをINSERT

#### レスポンス (201)
```json
{
  "success": true,
  "data": {
    "id": 301,
    "album_id": 13,
    "title": "My First Song",
    "duration_seconds": 180,
    "lyrics": "Lyrics...",
    "order": 1,
    "view_count": 0,
    "label": ["Pop", "Rock"],
    "is_cover": false,
    "cover_image_url": "/api/songs/301/cover",
    "created_at": "2025-10-23T16:10:00.000Z",
    "updated_at": "2025-10-23T16:10:00.000Z"
  }
}
```

### 20. 曲の順序更新

`PUT /api/albums/{album_id}/songs/order`

#### リクエストBody (application/json)

```json
{
  "song_ids": [302, 301]
}
```

#### ロジック
1. アルバムを検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. song_idsのバリデーション:
   - 配列でなければならない → `Validation failed` (400)
   - 重複IDを含んではならない → `Validation failed` (400)
   - 各IDが存在し、アルバムに属し（ソフトデリート除外）ていなければならない → `Validation failed` (400)
   - アルバムの非ソフトデリートの全曲を含んでいなければならない → `Validation failed` (400)
3. orderを更新: song_ids[0] → order=1, song_ids[1] → order=2, 以下同様

#### レスポンス (200)
```json
{
  "success": true
}
```

### 21. 曲詳細更新

`POST /api/albums/{album_id}/songs/{song_id}`

#### リクエストBody (multipart/form-data)

| フィールド | 型 | 必須 |
|-----------|-----|------|
| title | string | はい |
| duration_seconds | number | はい |
| label | string | はい（カンマ区切り; 空文字列は全ラベルを削除） |
| lyrics | string | はい |
| cover_image | file (image/jpeg) | いいえ（未提供の場合は既存を保持） |
| is_cover | boolean ("true"/"1" or "false"/"0") | はい |

> ⚠️ `Is_cover`の大文字小文字: 仕様ではbodyテーブルで`Is_cover`（大文字のI）を使用。早期に解決する: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover');` — この解決済みの値を必須チェックとパースの両方に使用する。

#### ロジック
1. アルバムを検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. song_idとalbum_idで曲を検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
3. is_coverフィールドを解決: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover')`
4. 必須フィールドのバリデーション (title, duration_seconds, lyrics, $isCoverRaw !== null) → `Validation failed` (400)
5. duration_secondsは数値でなければならない → `Validation failed` (400)
6. cover_imageが提供された場合: MIMEタイプでJPEGをバリデーション (`getMimeType() === 'image/jpeg'`) → `Invalid file type` (400)
7. is_coverのパース: $isCoverRaw "true"/"1" → true, それ以外 → false
8. ラベルのパース: labelフィールドが未指定 (null) → `Validation failed` (400); 空文字列の場合 → 全ラベルを削除（空配列）; 非空文字列の場合 → カンマで分割 → 名前を重複除去 → 各名前についてlabelsテーブルで名前検索（大文字小文字不問） → 見つからない場合 `Validation failed` (400); ラベルIDを収集
9. is_cover=trueかつ以前がis_cover=falseの場合: アルバムのis_coverカウント（ソフトデリート除外）< 3を確認 → `Too many covers provided` (400)
10. cover_imageが提供された場合: `public_path('uploads/songs/{song_id}.jpg')`に保存（上書き） → 失敗時: 500を返す（この時点でDBは未変更なのでロールバック不要）
11. 曲のフィールドをUPDATE
12. 既存のsong_labelsをDELETE → 新しいsong_labelsをINSERT

#### レスポンス (200)
```json
{
  "success": true,
  "data": {
    "id": 301,
    "album_id": 13,
    "title": "My First Song (Remix)",
    "duration_seconds": 190,
    "lyrics": "Lyrics...",
    "order": 2,
    "view_count": 0,
    "label": ["Pop"],
    "is_cover": false,
    "cover_image_url": "/api/songs/301/cover",
    "created_at": "2025-10-23T16:10:00.000Z",
    "updated_at": "2025-10-23T16:15:00.000Z"
  }
}
```

### 22. アルバムから曲を削除

`DELETE /api/albums/{album_id}/songs/{song_id}`

#### ロジック
1. アルバムを検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
2. song_idとalbum_idで曲を検索（ソフトデリート除外） → 見つからない: `Not Found` (404)
3. 曲をソフトデリート: `UPDATE songs SET deleted_at = NOW()`

#### レスポンス (200)
```json
{
  "success": true
}
```
