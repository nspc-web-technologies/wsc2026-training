# 実装メモ - WSC モジュール C

## レスポンスのフィールド順序

### アルバムの`publisher`の位置がエンドポイントにより異なる

- API #4 (アルバム詳細取得): `..., description, created_at, updated_at, publisher` (publisherがタイムスタンプの後)
- API #16/#17 (アルバム作成/更新): `..., description, publisher, created_at, updated_at` (publisherがタイムスタンプの前)
- API #11 metrics=album: `..., description, publisher, created_at, updated_at, total_view_count`

### 曲詳細のフィールド順序がエンドポイントにより異なる

- API #10/#11: `id, album_id, title, duration_seconds, order, label, view_count, is_cover, lyrics, cover_image_url, created_at, updated_at`
- API #19/#21: `id, album_id, title, duration_seconds, lyrics, order, view_count, label, is_cover, cover_image_url, created_at, updated_at`

### 簡略化されたリストレスポンス

- API #3 (アルバム一覧): `id, title, artist, release_year, publisher`のみ
- API #6 (アルバム内の曲): `id, album_id, title, label, duration_seconds, order, is_cover, cover_image_url`
- API #7 (全曲一覧): `id, album_id, title, label, duration_seconds, album_title, cover_image_url`

### ユーザーレスポンスのフィールドの違い

- API #12 (全ユーザー取得): `{id, username, email, role, is_banned, created_at}` — `updated_at`なし
- API #13 (ユーザーロール更新): `{id, username, email, role, is_banned, created_at, updated_at}` — 両方あり
- API #14 (ユーザーBAN): `{id, username, email, role, is_banned, updated_at}` — `created_at`なし
- API #15 (ユーザーBAN解除): `{id, username, email, role, is_banned, updated_at}` — `created_at`なし

## Laravelの注意点

### `cover_image_url`の生成

常にプレーン文字列: `'/api/songs/' . $song->id . '/cover'`

`url()`や`asset()`を使用しないこと — 絶対URLは採点で失敗する。

### `order`カラム

MySQLの予約語。生SQLでは バッククォートで囲む: `` `order` ``。Eloquentの`orderBy('order')`は自動的に処理する。

### `Is_cover`の大文字小文字

仕様ではAPI #19と#21のbodyテーブルで`Is_cover`（大文字のI）を使用。早期に解決する:
`$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover');`

### `helpers.php`の登録

`composer.json`に`"autoload": { "files": ["app/helpers.php"] }`を追加し、`composer dump-autoload`を実行する必要がある。

### `bootstrap/app.php`

`withRouting`（APIルート）、`withMiddleware`（エイリアス）、`withExceptions`（JSONエラーハンドラー）を設定する必要がある。これらがないと、ルートが読み込まれず、ミドルウェアエイリアスが解決されず、`abort()`がJSONではなくHTMLを返す。
