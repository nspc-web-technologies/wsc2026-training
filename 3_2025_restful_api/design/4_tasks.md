# Implementation Tasks - WSC Module C

## 1. Project Setup
- [ ] Create Laravel 11 project
- [ ] Configure .env (DB connection)
- [ ] Remove unnecessary files

## 2. Database

- [ ] Create users migration (id, username, email, password, role, is_banned, timestamps)
- [ ] Create access_tokens migration (id, user_id FK, token UNIQUE, created_at)
- [ ] Create albums migration (id, title, artist, release_year, genre, description, publisher_id FK, deleted_at, timestamps)
- [ ] Create songs migration (id, album_id FK, title, duration_seconds, order, lyrics, is_cover, cover_image_path, view_count, deleted_at, timestamps)
- [ ] Create labels migration (id, name UNIQUE)
- [ ] Create song_labels migration (id, song_id FK, label_id FK, UNIQUE(song_id, label_id))
- [ ] Run migrations
- [ ] Create UserSeeder (admin/user1/user2 with bcrypt passwords)
- [ ] Create LabelSeeder (Pop/Rock/Hip-Hop/Electronic/Jazz/Classical/Chill/Country)
- [ ] Run seeders
- [ ] Create User model (fillable, hidden, casts: is_banned+timestamps)
- [ ] Create Album model (fillable, hidden: publisher_id+deleted_at, casts: timestamps, relationship: publisher→User)
- [ ] Create Song model (fillable, hidden: cover_image_path+deleted_at, casts: is_cover+timestamps, relationships: labels→Label, album→Album)
- [ ] Create Label model (fillable, timestamps=false)
- [ ] Create SongLabel model (fillable, timestamps=false)
- [ ] Create AccessToken model (fillable, const UPDATED_AT = null — keeps created_at auto-set, disables updated_at)
- [ ] NOTE: All models with created_at/updated_at must cast them as 'datetime:Y-m-d\TH:i:s.v\Z' to output .000Z format

## 3. Middleware

- [ ] Create TokenAuth middleware
  - [ ] Check X-Authorization header → 401 "Access Token is required"
  - [ ] Strip "Bearer " prefix → 401 "Invalid Access Token" if missing
  - [ ] Find token in access_tokens → 401 "Invalid Access Token" if not found
  - [ ] Check is_banned → 403 "User is banned"
  - [ ] Set $request->authUser
- [ ] Create AdminAuth middleware
  - [ ] Check role = 'admin' → 403 "Admin access required"
- [ ] Register middleware aliases in bootstrap/app.php (withMiddleware → alias 'token.auth' and 'admin.auth')
- [ ] Register JSON error handler in bootstrap/app.php (withExceptions → HttpException → response()->json(), fallback 'Not Found')
- [ ] Register api routes in bootstrap/app.php (withRouting api: routes/api.php, apiPrefix: 'api')

## 4. Routes (routes/api.php)

- [ ] Public routes (no middleware)
- [ ] User routes (token.auth middleware)
- [ ] Admin routes (token.auth + admin.auth middleware)
- [ ] NOTE: PUT .../songs/order vs POST .../songs/{song_id} are distinguished by HTTP method — route order does not matter

## 5. Helper Functions

- [ ] Create `app/helpers.php`
- [ ] Register in `composer.json` autoload.files: `"app/helpers.php"` → run `composer dump-autoload`

- [ ] encodeCursor(int $id): string
- [ ] decodeCursor(string $cursor): int (throws 400 on invalid)
- [ ] paginateQuery($query, $request): array (query limit+1; if count≤limit → next_cursor=null; else discard last; returns data + meta)
- [ ] validateLimit($request): int (throws 400 on invalid)
- [ ] composeAlbumCover(array $paths): \Illuminate\Http\Response (GD composition, uses deleteFileAfterSend)

## 6. Auth Controller (AuthController.php)

- [ ] login()
  - [ ] Validate username, password required → 400 "Validation failed"
  - [ ] Find user by username → 400 "Login failed" if not found
  - [ ] Hash::check password → 400 "Login failed" if mismatch
  - [ ] Check is_banned → 403 "User is banned"
  - [ ] DELETE existing token by user_id → INSERT new token (md5(username))
  - [ ] Return token + user (200)
- [ ] register()
  - [ ] Validate required fields → 400 "Validation failed"
  - [ ] Validate email format → 400 "Validation failed"
  - [ ] Check username unique → 409 "Username already taken"
  - [ ] Check email unique → 409 "Email already taken"
  - [ ] bcrypt password → INSERT user (role='user')
  - [ ] Return user (201)
- [ ] logout()
  - [ ] DELETE token by user_id
  - [ ] Return success (200)

## 7. Album Controller (AlbumController.php)

- [ ] index() - GET /api/albums
  - [ ] Validate limit → 400 "Invalid parameter"
  - [ ] Validate cursor → 400 "Invalid cursor"
  - [ ] Validate year format → 400 "Invalid year format"
  - [ ] Read capital param with fallback: `$capital = $request->query('capital') ?? $request->query('filter')`
  - [ ] Apply capital filter (LIKE 'X%')
  - [ ] Apply year filter (= or BETWEEN)
  - [ ] WHERE deleted_at IS NULL, ORDER BY id ASC
  - [ ] Cursor pagination
  - [ ] Return simplified album list + meta (200)
- [ ] show() - GET /api/albums/{album_id}
  - [ ] Find album WHERE deleted_at IS NULL → 404 "Not Found"
  - [ ] Return full album details (200)
- [ ] cover() - GET /api/albums/{album_id}/cover
  - [ ] Find album → 404 "Not Found"
  - [ ] Get is_cover songs (deleted_at IS NULL) ORDER BY order ASC
  - [ ] Count = 0 → 404 "Cover Not Found"
  - [ ] Count > 3 → 400 "Too many covers provided"
  - [ ] For each song: cover_image_path null → 404 "Cover Not Found"; file not found / GD fail → 404 "Cover Not Found"
  - [ ] Compose and output image/jpeg (200)
- [ ] songs() - GET /api/albums/{album_id}/songs
  - [ ] Find album → 404 "Not Found"
  - [ ] Get songs WHERE deleted_at IS NULL ORDER BY order ASC
  - [ ] Return all songs with labels (200)
- [ ] store() - POST /api/albums [Admin]
  - [ ] Validate all required fields → 400 "Validation failed"
  - [ ] Validate release_year numeric → 400 "Validation failed"
  - [ ] INSERT album (publisher_id = auth user)
  - [ ] Return album (201)
- [ ] update() - PUT /api/albums/{album_id} [Admin]
  - [ ] Find album → 404 "Not Found"
  - [ ] Validate title, description required → 400 "Validation failed"
  - [ ] UPDATE title, description
  - [ ] Return album (200)
- [ ] destroy() - DELETE /api/albums/{album_id} [Admin]
  - [ ] Find album → 404 "Not Found"
  - [ ] Soft-delete album (deleted_at = NOW())
  - [ ] Soft-delete all songs (deleted_at = NOW())
  - [ ] Return success (200)

## 8. Song Controller (SongController.php)

- [ ] index() - GET /api/songs
  - [ ] Validate limit → 400 "Invalid parameter"
  - [ ] Validate cursor → 400 "Invalid cursor"
  - [ ] Read keyword param with fallback: `$keyword = $request->query('keyword') ?? $request->input('filter.keyword')`
  - [ ] Apply keyword filter (title LIKE '%keyword%')
  - [ ] WHERE deleted_at IS NULL, ORDER BY id ASC
  - [ ] Cursor pagination
  - [ ] Return songs with album_title + labels + meta (200)
- [ ] cover() - GET /api/songs/{song_id}/cover
  - [ ] Find song WHERE deleted_at IS NULL → 404 "Not Found"
  - [ ] Check cover_image_path not null and file exists → 404 "Cover Not Found"
  - [ ] GD load check (imagecreatefromjpeg) → fail: 404 "Cover Not Found"; success: imagedestroy immediately
  - [ ] Return original file directly: response()->file(public_path($cover_image_path)) — do NOT re-encode
- [ ] show() - GET /api/songs/{song_id} [User]
  - [ ] Find song WHERE deleted_at IS NULL → 404 "Not Found"
  - [ ] INCREMENT view_count via query builder (`Song::where('id', $id)->increment('view_count')`) — NOT model `$song->increment()` which updates `updated_at`
  - [ ] Refresh model (`$song->refresh()`) to get updated view_count
  - [ ] Return song with labels + updated view_count (200)
- [ ] store() - POST /api/albums/{album_id}/songs [Admin]
  - [ ] Find album → 404 "Not Found"
  - [ ] Resolve is_cover field: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover')`
  - [ ] Validate required fields (title, duration_seconds, lyrics, cover_image, $isCoverRaw !== null) → 400 "Validation failed"
  - [ ] Validate duration_seconds numeric → 400 "Validation failed"
  - [ ] Validate cover_image is JPEG → 400 "Invalid file type"
  - [ ] Parse is_cover ($isCoverRaw "true"/"1" → true)
  - [ ] Parse labels: if absent/empty → empty array; if present → split, deduplicate, validate each exists → 400 "Validation failed"
  - [ ] Check is_cover count < 3 if is_cover=true → 400 "Too many covers provided"
  - [ ] Calculate order (MAX(order) including soft-deleted + 1)
  - [ ] INSERT song (cover_image_path = null temporarily) → get song_id
  - [ ] Save image to public_path('uploads/songs/{song_id}.jpg') → on failure: DELETE song → 500
  - [ ] UPDATE song cover_image_path
  - [ ] INSERT song_labels
  - [ ] Return song (201)
- [ ] updateOrder() - PUT /api/albums/{album_id}/songs/order [Admin]
  - [ ] Find album → 404 "Not Found"
  - [ ] Validate song_ids is array → 400 "Validation failed"
  - [ ] Validate no duplicate IDs → 400 "Validation failed"
  - [ ] Validate all IDs exist, belong to album, not soft-deleted → 400 "Validation failed"
  - [ ] Validate song_ids contains ALL non-soft-deleted songs → 400 "Validation failed"
  - [ ] UPDATE order for each song
  - [ ] Return success (200)
- [ ] updateSong() - POST /api/albums/{album_id}/songs/{song_id} [Admin]
  - [ ] Find album → 404 "Not Found"
  - [ ] Find song by song_id AND album_id → 404 "Not Found"
  - [ ] Resolve is_cover field: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover')`
  - [ ] Validate required fields (title, duration_seconds, lyrics, $isCoverRaw !== null) → 400 "Validation failed"
  - [ ] Validate duration_seconds numeric → 400 "Validation failed"
  - [ ] If cover_image provided: validate JPEG → 400 "Invalid file type"
  - [ ] Parse is_cover ($isCoverRaw "true"/"1" → true)
  - [ ] Parse labels: if label field absent (null) → 400 "Validation failed"; if empty string → remove all labels; if non-empty → split, deduplicate, validate each exists → 400 "Validation failed"
  - [ ] Check is_cover count (exclude soft-deleted) < 3 if is_cover=true AND previously false → 400 "Too many covers provided"
  - [ ] UPDATE song fields
  - [ ] If cover_image provided: overwrite image file → on failure: return 500
  - [ ] DELETE old song_labels → INSERT new song_labels
  - [ ] Return song (200)
- [ ] destroySong() - DELETE /api/albums/{album_id}/songs/{song_id} [Admin]
  - [ ] Find album → 404 "Not Found"
  - [ ] Find song by song_id AND album_id → 404 "Not Found"
  - [ ] Soft-delete song (deleted_at = NOW())
  - [ ] Return success (200)

## 9. User Controller (UserController.php) [Admin]

- [ ] index() - GET /api/users
  - [ ] Validate limit → 400 "Invalid parameter"
  - [ ] Validate cursor → 400 "Invalid cursor"
  - [ ] ORDER BY id ASC
  - [ ] Cursor pagination
  - [ ] Return users (NO `updated_at` — fields: id, username, email, role, is_banned, created_at) + meta (200)
- [ ] update() - PUT /api/users/{user_id}
  - [ ] Find user → 404 "User not found"
  - [ ] Validate role required + valid value → 400 "Validation failed"
  - [ ] Check target user is_banned → 409 "Banned user update failed"
  - [ ] Check last admin demotion → 403 "Last admin demotion forbidden"
  - [ ] UPDATE role
  - [ ] Return user (with updated_at) (200)
- [ ] ban() - PUT /api/users/{user_id}/ban
  - [ ] Find user → 404 "User not found"
  - [ ] Check self ban → 400 "Cannot ban self"
  - [ ] Check target is admin → 403 "Cannot ban another admin"
  - [ ] Already banned → return 200 with current user data (idempotent)
  - [ ] UPDATE is_banned = true
  - [ ] Return user (NO `created_at` — fields: id, username, email, role, is_banned, updated_at) (200)
- [ ] unban() - PUT /api/users/{user_id}/unban
  - [ ] Find user → 404 "User not found"
  - [ ] Already unbanned → return 200 with current user data (idempotent)
  - [ ] UPDATE is_banned = false
  - [ ] Return user (NO `created_at` — fields: id, username, email, role, is_banned, updated_at) (200)

## 10. Statistics Controller (StatisticsController.php) [User]

- [ ] index() - GET /api/statistics
  - [ ] Validate metrics required + valid value ('song'|'album'|'label') → 400 "Validation failed"
  - [ ] metrics=song: all songs ORDER BY view_count DESC; if `labels` param provided, filter to songs having at least one matching label
  - [ ] metrics=album: all albums + total_view_count ORDER BY total_view_count DESC
  - [ ] metrics=label: labels (+ optional filter) + top 10 songs each ORDER BY total_view_count DESC
  - [ ] Return data (200)

## 11. Final

- [ ] Create public/uploads/songs/ directory
- [ ] Test all 22 endpoints
- [ ] Verify error responses match spec
- [ ] Verify cursor pagination works correctly
