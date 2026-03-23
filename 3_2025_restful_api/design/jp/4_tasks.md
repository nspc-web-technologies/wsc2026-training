# 実装タスク - WSC モジュール C

## 1. プロジェクトセットアップ
- [ ] Laravel 11プロジェクトを作成
- [ ] .envを設定（DB接続）
- [ ] 不要なファイルを削除

## 2. データベース

- [ ] usersマイグレーション作成 (id, username, email, password, role, is_banned, timestamps)
- [ ] access_tokensマイグレーション作成 (id, user_id FK, token UNIQUE, created_at)
- [ ] albumsマイグレーション作成 (id, title, artist, release_year, genre, description, publisher_id FK, deleted_at, timestamps)
- [ ] songsマイグレーション作成 (id, album_id FK, title, duration_seconds, order, lyrics, is_cover, cover_image_path, view_count, deleted_at, timestamps)
- [ ] labelsマイグレーション作成 (id, name UNIQUE)
- [ ] song_labelsマイグレーション作成 (id, song_id FK, label_id FK, UNIQUE(song_id, label_id))
- [ ] マイグレーション実行
- [ ] UserSeeder作成（admin/user1/user2、bcryptパスワード付き）
- [ ] LabelSeeder作成（Pop/Rock/Hip-Hop/Electronic/Jazz/Classical/Chill/Country）
- [ ] シーダー実行
- [ ] Userモデル作成（fillable, hidden, casts: is_banned+timestamps）
- [ ] Albumモデル作成（fillable, hidden: publisher_id+deleted_at, casts: timestamps, リレーション: publisher→User）
- [ ] Songモデル作成（fillable, hidden: cover_image_path+deleted_at, casts: is_cover+timestamps, リレーション: labels→Label, album→Album）
- [ ] Labelモデル作成（fillable, timestamps=false）
- [ ] SongLabelモデル作成（fillable, timestamps=false）
- [ ] AccessTokenモデル作成（fillable, const UPDATED_AT = null — created_atの自動設定を維持し、updated_atを無効化）
- [ ] 注意: created_at/updated_atを持つすべてのモデルは、.000Z形式を出力するために'datetime:Y-m-d\TH:i:s.v\Z'としてキャストする必要がある

## 3. ミドルウェア

- [ ] TokenAuthミドルウェア作成
  - [ ] X-Authorizationヘッダーをチェック → 401 "Access Token is required"
  - [ ] "Bearer "プレフィックスを除去 → 欠落している場合401 "Invalid Access Token"
  - [ ] access_tokensでトークンを検索 → 見つからない場合401 "Invalid Access Token"
  - [ ] is_bannedをチェック → 403 "User is banned"
  - [ ] $request->authUserを設定
- [ ] AdminAuthミドルウェア作成
  - [ ] role = 'admin'をチェック → 403 "Admin access required"
- [ ] bootstrap/app.phpにミドルウェアエイリアスを登録（withMiddleware → 'token.auth'と'admin.auth'をエイリアス）
- [ ] bootstrap/app.phpにJSONエラーハンドラーを登録（withExceptions → HttpException → response()->json()、フォールバック 'Not Found'）
- [ ] bootstrap/app.phpにAPIルートを登録（withRouting api: routes/api.php, apiPrefix: 'api'）

## 4. ルート (routes/api.php)

- [ ] パブリックルート（ミドルウェアなし）
- [ ] ユーザールート（token.authミドルウェア）
- [ ] 管理者ルート（token.auth + admin.authミドルウェア）
- [ ] 注意: PUT .../songs/order と POST .../songs/{song_id} はHTTPメソッドで区別される — ルート順序は重要ではない

## 5. ヘルパー関数

- [ ] `app/helpers.php`を作成
- [ ] `composer.json`のautoload.filesに登録: `"app/helpers.php"` → `composer dump-autoload`を実行

- [ ] encodeCursor(int $id): string
- [ ] decodeCursor(string $cursor): int（無効な場合400をスロー）
- [ ] paginateQuery($query, $request): array（limit+1件クエリ; count≤limitならnext_cursor=null; そうでなければ最後を破棄; dataとmetaを返す）
- [ ] validateLimit($request): int（無効な場合400をスロー）
- [ ] composeAlbumCover(array $paths): \Illuminate\Http\Response（GD合成、deleteFileAfterSendを使用）

## 6. 認証コントローラー (AuthController.php)

- [ ] login()
  - [ ] username, passwordの必須バリデーション → 400 "Validation failed"
  - [ ] usernameでユーザーを検索 → 見つからない場合400 "Login failed"
  - [ ] Hash::checkでパスワード照合 → 不一致の場合400 "Login failed"
  - [ ] is_bannedをチェック → 403 "User is banned"
  - [ ] user_idで既存トークンをDELETE → 新しいトークン(md5(username))をINSERT
  - [ ] token + userを返す (200)
- [ ] register()
  - [ ] 必須フィールドのバリデーション → 400 "Validation failed"
  - [ ] メール形式のバリデーション → 400 "Validation failed"
  - [ ] usernameのユニークチェック → 409 "Username already taken"
  - [ ] emailのユニークチェック → 409 "Email already taken"
  - [ ] bcryptでパスワードをハッシュ → ユーザーをINSERT (role='user')
  - [ ] userを返す (201)
- [ ] logout()
  - [ ] user_idでトークンをDELETE
  - [ ] successを返す (200)

## 7. アルバムコントローラー (AlbumController.php)

- [ ] index() - GET /api/albums
  - [ ] limitのバリデーション → 400 "Invalid parameter"
  - [ ] cursorのバリデーション → 400 "Invalid cursor"
  - [ ] year形式のバリデーション → 400 "Invalid year format"
  - [ ] capitalパラメータをフォールバック付きで読み取り: `$capital = $request->query('capital') ?? $request->query('filter')`
  - [ ] capitalフィルター適用 (LIKE 'X%')
  - [ ] yearフィルター適用 (= または BETWEEN)
  - [ ] WHERE deleted_at IS NULL, ORDER BY id ASC
  - [ ] カーソルページネーション
  - [ ] 簡略化されたアルバムリスト + metaを返す (200)
- [ ] show() - GET /api/albums/{album_id}
  - [ ] アルバムを検索 WHERE deleted_at IS NULL → 404 "Not Found"
  - [ ] アルバム詳細を返す (200)
- [ ] cover() - GET /api/albums/{album_id}/cover
  - [ ] アルバムを検索 → 404 "Not Found"
  - [ ] is_coverの曲を取得 (deleted_at IS NULL) ORDER BY order ASC
  - [ ] Count = 0 → 404 "Cover Not Found"
  - [ ] Count > 3 → 400 "Too many covers provided"
  - [ ] 各曲について: cover_image_pathがnull → 404 "Cover Not Found"; ファイル未発見 / GD失敗 → 404 "Cover Not Found"
  - [ ] 画像を合成してimage/jpegで出力 (200)
- [ ] songs() - GET /api/albums/{album_id}/songs
  - [ ] アルバムを検索 → 404 "Not Found"
  - [ ] 曲を取得 WHERE deleted_at IS NULL ORDER BY order ASC
  - [ ] ラベル付きの全曲を返す (200)
- [ ] store() - POST /api/albums [Admin]
  - [ ] 全必須フィールドのバリデーション → 400 "Validation failed"
  - [ ] release_yearの数値バリデーション → 400 "Validation failed"
  - [ ] アルバムをINSERT (publisher_id = 認証ユーザー)
  - [ ] アルバムを返す (201)
- [ ] update() - PUT /api/albums/{album_id} [Admin]
  - [ ] アルバムを検索 → 404 "Not Found"
  - [ ] title, descriptionの必須バリデーション → 400 "Validation failed"
  - [ ] title, descriptionをUPDATE
  - [ ] アルバムを返す (200)
- [ ] destroy() - DELETE /api/albums/{album_id} [Admin]
  - [ ] アルバムを検索 → 404 "Not Found"
  - [ ] アルバムをソフトデリート (deleted_at = NOW())
  - [ ] 全曲をソフトデリート (deleted_at = NOW())
  - [ ] successを返す (200)

## 8. 曲コントローラー (SongController.php)

- [ ] index() - GET /api/songs
  - [ ] limitのバリデーション → 400 "Invalid parameter"
  - [ ] cursorのバリデーション → 400 "Invalid cursor"
  - [ ] keywordパラメータをフォールバック付きで読み取り: `$keyword = $request->query('keyword') ?? $request->input('filter.keyword')`
  - [ ] keywordフィルター適用 (title LIKE '%keyword%')
  - [ ] WHERE deleted_at IS NULL, ORDER BY id ASC
  - [ ] カーソルページネーション
  - [ ] album_title + labels + meta付きの曲を返す (200)
- [ ] cover() - GET /api/songs/{song_id}/cover
  - [ ] 曲を検索 WHERE deleted_at IS NULL → 404 "Not Found"
  - [ ] cover_image_pathがnullでないこととファイルの存在を確認 → 404 "Cover Not Found"
  - [ ] GDロードチェック (imagecreatefromjpeg) → 失敗: 404 "Cover Not Found"; 成功: 即座にimagedestroy
  - [ ] 元のファイルをそのまま返す: response()->file(public_path($cover_image_path)) — 再エンコードしないこと
- [ ] show() - GET /api/songs/{song_id} [User]
  - [ ] 曲を検索 WHERE deleted_at IS NULL → 404 "Not Found"
  - [ ] クエリビルダーでview_countをインクリメント (`Song::where('id', $id)->increment('view_count')`) — モデルの`$song->increment()`は`updated_at`を更新してしまうので使用しない
  - [ ] モデルをリフレッシュ (`$song->refresh()`) して更新されたview_countを取得
  - [ ] labels + 更新されたview_count付きの曲を返す (200)
- [ ] store() - POST /api/albums/{album_id}/songs [Admin]
  - [ ] アルバムを検索 → 404 "Not Found"
  - [ ] is_coverフィールドを解決: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover')`
  - [ ] 必須フィールドのバリデーション (title, duration_seconds, lyrics, cover_image, $isCoverRaw !== null) → 400 "Validation failed"
  - [ ] duration_secondsの数値バリデーション → 400 "Validation failed"
  - [ ] cover_imageのJPEGバリデーション → 400 "Invalid file type"
  - [ ] is_coverのパース ($isCoverRaw "true"/"1" → true)
  - [ ] ラベルのパース: 未指定/空 → 空配列; 指定あり → 分割、重複除去、各名前の存在確認 → 400 "Validation failed"
  - [ ] is_cover=trueの場合、is_coverカウント < 3を確認 → 400 "Too many covers provided"
  - [ ] orderを計算 (ソフトデリート済みも含めてMAX(order) + 1)
  - [ ] 曲をINSERT (cover_image_path = null 一時的) → song_idを取得
  - [ ] 画像をpublic_path('uploads/songs/{song_id}.jpg')に保存 → 失敗時: INSERTした曲をDELETE → 500
  - [ ] 曲のcover_image_pathをUPDATE
  - [ ] song_labelsをINSERT
  - [ ] 曲を返す (201)
- [ ] updateOrder() - PUT /api/albums/{album_id}/songs/order [Admin]
  - [ ] アルバムを検索 → 404 "Not Found"
  - [ ] song_idsが配列であることをバリデーション → 400 "Validation failed"
  - [ ] 重複IDがないことをバリデーション → 400 "Validation failed"
  - [ ] 全IDが存在し、アルバムに属し、ソフトデリートされていないことをバリデーション → 400 "Validation failed"
  - [ ] song_idsが非ソフトデリートの全曲を含むことをバリデーション → 400 "Validation failed"
  - [ ] 各曲のorderをUPDATE
  - [ ] successを返す (200)
- [ ] updateSong() - POST /api/albums/{album_id}/songs/{song_id} [Admin]
  - [ ] アルバムを検索 → 404 "Not Found"
  - [ ] song_idとalbum_idで曲を検索 → 404 "Not Found"
  - [ ] is_coverフィールドを解決: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover')`
  - [ ] 必須フィールドのバリデーション (title, duration_seconds, lyrics, $isCoverRaw !== null) → 400 "Validation failed"
  - [ ] duration_secondsの数値バリデーション → 400 "Validation failed"
  - [ ] cover_imageが提供された場合: JPEGをバリデーション → 400 "Invalid file type"
  - [ ] is_coverのパース ($isCoverRaw "true"/"1" → true)
  - [ ] ラベルのパース: labelフィールドが未指定 (null) → 400 "Validation failed"; 空文字列 → 全ラベル削除; 非空 → 分割、重複除去、各名前の存在確認 → 400 "Validation failed"
  - [ ] is_cover=trueかつ以前がfalseの場合、is_coverカウント（ソフトデリート除外） < 3を確認 → 400 "Too many covers provided"
  - [ ] 曲のフィールドをUPDATE
  - [ ] cover_imageが提供された場合: 画像ファイルを上書き → 失敗時: 500を返す
  - [ ] 古いsong_labelsをDELETE → 新しいsong_labelsをINSERT
  - [ ] 曲を返す (200)
- [ ] destroySong() - DELETE /api/albums/{album_id}/songs/{song_id} [Admin]
  - [ ] アルバムを検索 → 404 "Not Found"
  - [ ] song_idとalbum_idで曲を検索 → 404 "Not Found"
  - [ ] 曲をソフトデリート (deleted_at = NOW())
  - [ ] successを返す (200)

## 9. ユーザーコントローラー (UserController.php) [Admin]

- [ ] index() - GET /api/users
  - [ ] limitのバリデーション → 400 "Invalid parameter"
  - [ ] cursorのバリデーション → 400 "Invalid cursor"
  - [ ] ORDER BY id ASC
  - [ ] カーソルページネーション
  - [ ] ユーザーを返す（`updated_at`なし — フィールド: id, username, email, role, is_banned, created_at） + meta (200)
- [ ] update() - PUT /api/users/{user_id}
  - [ ] ユーザーを検索 → 404 "User not found"
  - [ ] roleの必須 + 有効値バリデーション → 400 "Validation failed"
  - [ ] 対象ユーザーのis_bannedをチェック → 409 "Banned user update failed"
  - [ ] 最後の管理者降格をチェック → 403 "Last admin demotion forbidden"
  - [ ] roleをUPDATE
  - [ ] ユーザーを返す（updated_at付き） (200)
- [ ] ban() - PUT /api/users/{user_id}/ban
  - [ ] ユーザーを検索 → 404 "User not found"
  - [ ] 自己BANをチェック → 400 "Cannot ban self"
  - [ ] 対象が管理者かチェック → 403 "Cannot ban another admin"
  - [ ] 既にBANされている場合 → 現在のユーザーデータで200を返す（冪等）
  - [ ] is_banned = trueにUPDATE
  - [ ] ユーザーを返す（`created_at`なし — フィールド: id, username, email, role, is_banned, updated_at） (200)
- [ ] unban() - PUT /api/users/{user_id}/unban
  - [ ] ユーザーを検索 → 404 "User not found"
  - [ ] 既にBAN解除されている場合 → 現在のユーザーデータで200を返す（冪等）
  - [ ] is_banned = falseにUPDATE
  - [ ] ユーザーを返す（`created_at`なし — フィールド: id, username, email, role, is_banned, updated_at） (200)

## 10. 統計コントローラー (StatisticsController.php) [User]

- [ ] index() - GET /api/statistics
  - [ ] metricsの必須 + 有効値バリデーション ('song'|'album'|'label') → 400 "Validation failed"
  - [ ] metrics=song: 全曲をview_count DESCでソート; `labels`パラメータが提供された場合、一致するラベルを持つ曲にフィルタリング
  - [ ] metrics=album: 全アルバム + total_view_countをtotal_view_count DESCでソート
  - [ ] metrics=label: ラベル（+ オプションフィルター） + 各トップ10曲をtotal_view_count DESCでソート
  - [ ] dataを返す (200)

## 11. 最終確認

- [ ] public/uploads/songs/ディレクトリを作成
- [ ] 全22エンドポイントをテスト
- [ ] エラーレスポンスが仕様と一致するか確認
- [ ] カーソルページネーションが正しく動作するか確認
