# API Design - WSC Module C

## Overview

Base URL: `http://wsXX.worldskills.org/XX_module_c/api`

Authentication: `X-Authorization: Bearer <token>` (required for User/Admin APIs)

Response Format: `application/json`

Error response format:
```json
{
  "success": false,
  "message": "Error message here"
}
```

## Error Messages

| Message | HTTP Status | Condition |
|---------|-------------|-----------|
| Access Token is required | 401 | No X-Authorization header |
| Invalid Access Token | 401 | Invalid/expired/non-existent token |
| Admin access required | 403 | Non-admin accessing Admin API |
| Access denied | 403 | A logged-in user attempts to operate on a resource that does not belong to them |
| User is banned | 403 | Banned user accessing protected features |
| Not Found | 404 | Route or resource does not exist |
| Cover Not Found | 404 | Album or song cover image does not exist |
| Too many covers provided | 400 | Album already has 3 is_cover=true songs (at limit) |
| Login failed | 400 | Incorrect username or password |
| Username already taken | 409 | Username already in use |
| Email already taken | 409 | Email already in use |
| Validation failed | 400 | Missing/invalid fields |
| Invalid parameter | 400 | Invalid query params (limit>100, not number, <1) |
| Invalid cursor | 400 | Malformed cursor |
| Invalid year format | 400 | Invalid year param (e.g. "abc" or "2000-1990") |
| Invalid file type | 400 | Uploaded file is not JPEG |
| User not found | 404 | Admin operating on non-existent user_id |
| Cannot ban self | 400 | Admin trying to ban themselves |
| Last admin demotion forbidden | 403 | Attempting to demote the last remaining admin to 'user' role |
| Banned user update failed | 409 | Cannot update banned user role |
| Cannot ban another admin | 403 | Admin trying to ban another admin |

## Cursor-Based Pagination

- Default: 10 records per page
- `limit` parameter: 1–100 (Invalid parameter if <1 or >100 or not number)
- Implementation: query `limit + 1` records; if count ≤ limit → no next page; if count = limit + 1 → discard last record and set next_cursor
- `next_cursor`: ID of the last record in current page (the limit-th record) → `{"id":N}` → Base64 encode → null if no next page
- `prev_cursor`: null if no `cursor` param was given (first page); null if result count = 0; otherwise `(first item ID - 1)` → `{"id":N}` → Base64 encode → null if first item ID - 1 <= 0
- Note on prev_cursor: This design uses a single-direction cursor (`WHERE id > cursor_id`). `prev_cursor` indicates that earlier data exists; its value is not designed to navigate backward. Only `null` vs non-null matters.
- `cursor` parameter: decoded to `cursor_id` → apply `WHERE id > cursor_id` to get next/previous page
- Invalid cursor: `Invalid cursor` (400)

---

## Public API (No Authentication Required)

---

### 1. User Login

`POST /api/login`

#### Request Body (application/json)

| Field | Type | Required |
|-------|------|----------|
| username | string | Yes |
| password | string | Yes |

#### Login Flow
1. Validate required fields (username, password) → `Validation failed` (400)
2. Find user by username → not found: `Login failed` (400)
3. Hash::check password → mismatch: `Login failed` (400)
4. is_banned check → banned: `User is banned` (403)
5. DELETE existing token by user_id → INSERT new token (md5(username))
6. Return token + user

#### Response (200)
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

---

### 2. User Register

`POST /api/register`

#### Request Body (application/json)

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| username | string | Yes | Unique |
| email | string | Yes | Valid email format, Unique |
| password | string | Yes | - |

#### Validation Order
1. Required fields check → `Validation failed` (400)
2. Email format check → `Validation failed` (400)
3. Username unique check → `Username already taken` (409)
4. Email unique check → `Email already taken` (409)
5. bcrypt hash password → INSERT user (role='user', is_banned=false)

#### Response (201)
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

---

### 3. Get All Albums

`GET /api/albums`

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| capital | string | Filter by first letter of title — single character (case-insensitive); empty string is treated as not provided (no filter) |
| year | string | Filter by year e.g. "2020" or "2018-2020" (BETWEEN, inclusive) |
| limit | number | Records per page (1-100, default: 10) |
| cursor | string | Cursor for pagination |

> ⚠️ Param name ambiguity: Spec parameter table says `capital`, but example URL uses `filter=A`. Support both: `$capital = $request->query('capital') ?? $request->query('filter');`

#### Year Validation
- Empty string: treated as not provided (no filter) — consistent with `capital` and `keyword`
- Single year: must be numeric → `Invalid year format` (400) if not
- Range: must match `YYYY-YYYY` format, start ≤ end → `Invalid year format` (400) if not

#### Filter Logic
- `capital`: `WHERE title LIKE 'A%'` (MySQL case-insensitive by default)
- `year` single: `WHERE release_year = 2020`
- `year` range: `WHERE release_year BETWEEN 2018 AND 2020`
- Multiple filters: AND condition
- Cursor + filters apply simultaneously: when cursor is provided, all active filters (capital, year) must still be applied
- Exclude soft-deleted: `WHERE deleted_at IS NULL`
- Sort: `ORDER BY id ASC`

#### Response (200)
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

---

### 4. Get Album Details

`GET /api/albums/{album_id}`

#### Route Parameters

| Parameter | Type |
|-----------|------|
| album_id | integer |

#### Logic
- Exclude soft-deleted: `WHERE id = ? AND deleted_at IS NULL`
- Not found: `Not Found` (404)

#### Response (200)
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

---

### 5. Get Album Cover

`GET /api/albums/{album_id}/cover`

#### Logic
1. Find album (exclude soft-deleted) → not found: `Not Found` (404)
2. Get songs with `is_cover=true AND deleted_at IS NULL` ORDER BY `order` ASC
3. Count = 0: `Cover Not Found` (404)
4. Count > 3: `Too many covers provided` (400)
5. For each song: check cover_image_path is not null and physical file exists → `Cover Not Found` (404); GD load fail → `Cover Not Found` (404)
6. Compose 500×500px image using GD:
   - 1 image: full 500×500
   - 2 images: left 250×500 + right 250×500
   - 3 images: left 250×500 + right-top 250×250 + right-bottom 250×250
7. Output as `image/jpeg`

#### Response (200)
`Content-Type: image/jpeg` (binary)

---

### 6. Get Songs in Album

`GET /api/albums/{album_id}/songs`

#### Logic
- Find album (exclude soft-deleted) → not found: `Not Found` (404)
- Get songs: `WHERE album_id = ? AND deleted_at IS NULL ORDER BY order ASC`
- No pagination (return all)
- Empty album: return empty array

#### Response (200)
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

---

### 7. Get All Songs

`GET /api/songs`

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| keyword | string | Filter by song title (partial match); empty string is treated as not provided (no filter) |
| limit | number | Records per page (1-100, default: 10) |
| cursor | string | Cursor for pagination |

> ⚠️ Param name ambiguity: Spec parameter table says `keyword`, but example URL uses `filter[keyword]=love`. Support both: `$keyword = $request->query('keyword') ?? $request->input('filter.keyword');`

#### Filter Logic
- `keyword`: `WHERE title LIKE '%love%'`
- Cursor + filters apply simultaneously: when cursor is provided, keyword filter must still be applied
- Exclude soft-deleted: `WHERE deleted_at IS NULL`
- Sort: `ORDER BY id ASC`

#### Response (200)
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

---

### 8. Get Song Cover

`GET /api/songs/{song_id}/cover`

#### Logic
1. Find song (exclude soft-deleted) → not found: `Not Found` (404)
2. Check cover_image_path is not null and physical file exists → `Cover Not Found` (404)
3. Validate with GD: `imagecreatefromjpeg(public_path($cover_image_path))` → fail: `Cover Not Found` (404); on success: `imagedestroy($img)` immediately
4. Return original file directly: `response()->file(public_path($cover_image_path), ['Content-Type' => 'image/jpeg'])`
   - Do NOT re-encode via `imagejpeg()` — re-encoding changes the binary and degrades quality

#### Response (200)
`Content-Type: image/jpeg` (binary)

---

## User API (Authentication Required)

Middleware: TokenAuth
- Check `X-Authorization` header exists → `Access Token is required` (401)
- Strip `Bearer ` prefix → if prefix missing or token empty: `Invalid Access Token` (401)
- Look up token in access_tokens table → not found: `Invalid Access Token` (401)
- User is_banned=true: `User is banned` (403)

---

### 9. User Logout

`POST /api/logout`

#### Logic
- DELETE from access_tokens WHERE user_id = authenticated user id
- Note: the DELETE is safe to call even if no token row exists (0 rows affected is not an error)

#### Response (200)
```json
{
  "success": true
}
```

---

### 10. Get Song Details

`GET /api/songs/{song_id}`

#### Logic
1. Find song (exclude soft-deleted) → not found: `Not Found` (404)
2. Increment view_count: `Song::where('id', $id)->increment('view_count')` (query builder, NOT model `$song->increment()` which updates `updated_at`)
3. Refresh model: `$song->refresh()` to get updated view_count
4. Return song with updated view_count

#### Response (200)
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

---

### 11. Get Statistics Result

`GET /api/statistics`

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| metrics | string | Yes | `song` \| `album` \| `label` |
| labels | string | No | For metrics=song and metrics=label, e.g. "Pop,Rock" |

#### Validation
- metrics missing or invalid value: `Validation failed` (400)

#### metrics=song

- Return all songs (exclude soft-deleted)
- If `labels` param provided (non-empty): filter to songs having at least one of the specified labels (e.g. `labels=Pop,Rock` → songs with label Pop OR Rock); non-existent label names are silently ignored; empty string is treated as not provided (no filter)
- ORDER BY view_count DESC
- No pagination

#### Response — metrics=song (200)
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

- Return all albums (exclude soft-deleted)
- total_view_count = SUM of view_count of non-soft-deleted songs in album (0 if no songs)
- ORDER BY total_view_count DESC
- No pagination

#### Response — metrics=album (200)
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

- Return all labels (or filtered by `labels` param)
- `labels` param: comma-separated label names e.g. "Pop,Rock" → filter to matching labels only; non-existent names are silently ignored; empty string is treated as not provided (return all labels)
- Each label: top 10 songs by view_count DESC (exclude soft-deleted)
- total_view_count = SUM of view_count of those top 10 songs (0 if label has no songs)
- ORDER labels by total_view_count DESC
- No pagination

#### Response — metrics=label (200)
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

---

## Admin API (Authentication + Admin Role Required)

Additional Middleware: AdminAuth
- Check user role = 'admin' → `Admin access required` (403) if not

---

### 12. Get All Users

`GET /api/users`

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| cursor | string | Cursor for pagination |
| limit | number | Records per page (1-100, default: 10) |

#### Logic
- Return all users (no filter)
- Sort: `ORDER BY id ASC`

#### Response (200)
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

---

### 13. Update User Role

`PUT /api/users/{user_id}`

#### Request Body (application/json)

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| role | string | Yes | 'admin' or 'user' only |

#### Validation/Logic Order
1. Find user by user_id → not found: `User not found` (404)
2. role missing or invalid value: `Validation failed` (400)
3. Target user is_banned=true: `Banned user update failed` (409)
4. Target is last admin + new role='user': `Last admin demotion forbidden` (403)
5. UPDATE user role

#### Response (200)
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

---

### 14. Ban User

`PUT /api/users/{user_id}/ban`

#### Logic Order
1. Find user by user_id → not found: `User not found` (404)
2. user_id = authenticated admin id: `Cannot ban self` (400)
3. Target user role = 'admin': `Cannot ban another admin` (403)
4. Already banned: return 200 with current user data (idempotent)
5. UPDATE is_banned = true

#### Response (200)
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

---

### 15. Unban User

`PUT /api/users/{user_id}/unban`

#### Logic Order
1. Find user by user_id → not found: `User not found` (404)
2. Already unbanned: return 200 with current user data (idempotent)
3. UPDATE is_banned = false

#### Response (200)
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

---

### 16. Create New Album

`POST /api/albums`

#### Request Body (multipart/form-data)

| Field | Type | Required |
|-------|------|----------|
| title | string | Yes |
| artist | string | Yes |
| release_year | number | Yes |
| genre | string | Yes |
| description | string | Yes |

#### Validation
- All fields required → `Validation failed` (400)
- release_year must be numeric → `Validation failed` (400)
- publisher_id = authenticated user id (auto-set)

#### Logic
1. Validate all required fields and release_year numeric (see above)
2. INSERT album with publisher_id = $request->authUser->id
3. Load publisher: `$album->load('publisher')`
4. Return album with publisher object (201)

#### Response (201)
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

---

### 17. Update Album Details

`PUT /api/albums/{album_id}`

#### Request Body (application/json)

| Field | Type | Required |
|-------|------|----------|
| title | string | Yes |
| description | string | Yes |

#### Logic
1. Find album (exclude soft-deleted) → not found: `Not Found` (404)
2. Validate required fields → `Validation failed` (400)
3. UPDATE title, description only
4. Load publisher: `$album->load('publisher')`
5. Return album with publisher object (200)

#### Response (200)
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

---

### 18. Delete Album

`DELETE /api/albums/{album_id}`

#### Logic
1. Find album (exclude soft-deleted) → not found: `Not Found` (404)
2. Soft-delete album: `UPDATE albums SET deleted_at = NOW()`
3. Soft-delete all songs: `UPDATE songs SET deleted_at = NOW() WHERE album_id = ? AND deleted_at IS NULL`

#### Response (200)
```json
{
  "success": true
}
```

---

### 19. Add Song to Album

`POST /api/albums/{album_id}/songs`

#### Request Body (multipart/form-data)

| Field | Type | Required |
|-------|------|----------|
| title | string | Yes |
| duration_seconds | number | Yes |
| label | string | No (optional, comma-separated) |
| lyrics | string | Yes |
| cover_image | file (image/jpeg) | Yes |
| is_cover | boolean ("true"/"1" or "false"/"0") | Yes |

> ⚠️ `Is_cover` casing: Spec uses `Is_cover` (capital I) in body table. Resolve early: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover');` — use this resolved value for both the required check and parsing.

#### Logic
1. Find album (exclude soft-deleted) → not found: `Not Found` (404)
2. Resolve is_cover field: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover')`
3. Validate required fields (title, duration_seconds, lyrics, cover_image, and $isCoverRaw !== null) → `Validation failed` (400)
4. duration_seconds must be numeric → `Validation failed` (400)
5. Validate cover_image is JPEG via MIME type: `$request->file('cover_image')->getMimeType() === 'image/jpeg'` → `Invalid file type` (400)
6. Parse is_cover: $isCoverRaw "true"/"1" → true, else → false
7. If label is provided and non-empty: split by comma → deduplicate names → for each name, lookup in labels table by name (case-insensitive) → `Validation failed` (400) if any not found; collect label IDs for insertion; if label is absent or empty string → no labels (empty array)
8. If is_cover=true: check album's current is_cover count (exclude soft-deleted) < 3 → `Too many covers provided` (400) if would exceed 3
9. Calculate order: `SELECT MAX(order) FROM songs WHERE album_id = ?` (including soft-deleted) + 1, default 1 if null
10. INSERT song (cover_image_path = null temporarily) → get song_id
11. Save cover_image to `public_path('uploads/songs/{song_id}.jpg')` → on failure: DELETE inserted song → return 500
12. UPDATE songs SET cover_image_path = `uploads/songs/{song_id}.jpg` (relative to public/)
13. INSERT song_labels

#### Response (201)
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

---

### 20. Update Song Order

`PUT /api/albums/{album_id}/songs/order`

#### Request Body (application/json)

```json
{
  "song_ids": [302, 301]
}
```

#### Logic
1. Find album (exclude soft-deleted) → not found: `Not Found` (404)
2. Validate song_ids:
   - Must be array → `Validation failed` (400)
   - Must not contain duplicate IDs → `Validation failed` (400)
   - Each ID must exist and belong to album (exclude soft-deleted) → `Validation failed` (400)
   - Must contain ALL non-soft-deleted songs of the album → `Validation failed` (400)
3. Update order: song_ids[0] → order=1, song_ids[1] → order=2, etc.

#### Response (200)
```json
{
  "success": true
}
```

---

### 21. Update Song Details

`POST /api/albums/{album_id}/songs/{song_id}`

#### Request Body (multipart/form-data)

| Field | Type | Required |
|-------|------|----------|
| title | string | Yes |
| duration_seconds | number | Yes |
| label | string | Yes (comma-separated; empty string removes all labels) |
| lyrics | string | Yes |
| cover_image | file (image/jpeg) | No (keep existing if not provided) |
| is_cover | boolean ("true"/"1" or "false"/"0") | Yes |

> ⚠️ `Is_cover` casing: Spec uses `Is_cover` (capital I) in body table. Resolve early: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover');` — use this resolved value for both the required check and parsing.

#### Logic
1. Find album (exclude soft-deleted) → not found: `Not Found` (404)
2. Find song by song_id AND album_id (exclude soft-deleted) → not found: `Not Found` (404)
3. Resolve is_cover field: `$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover')`
4. Validate required fields (title, duration_seconds, lyrics, and $isCoverRaw !== null) → `Validation failed` (400)
5. duration_seconds must be numeric → `Validation failed` (400)
6. If cover_image provided: validate JPEG via MIME type (`getMimeType() === 'image/jpeg'`) → `Invalid file type` (400)
7. Parse is_cover: $isCoverRaw "true"/"1" → true, else → false
8. Parse labels: if label field absent (null) → `Validation failed` (400); if empty string → remove all labels (empty array); if non-empty string → split by comma → deduplicate names → for each name, lookup in labels table by name (case-insensitive) → `Validation failed` (400) if any not found; collect label IDs
9. If is_cover=true AND song was previously is_cover=false: check album's is_cover count (exclude soft-deleted) < 3 → `Too many covers provided` (400)
10. If cover_image provided: save to `public_path('uploads/songs/{song_id}.jpg')` (overwrite) → on failure: return 500 (DB not yet modified at this point, so no rollback needed)
11. UPDATE song fields
12. DELETE existing song_labels → INSERT new song_labels

#### Response (200)
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

---

### 22. Delete Song from Album

`DELETE /api/albums/{album_id}/songs/{song_id}`

#### Logic
1. Find album (exclude soft-deleted) → not found: `Not Found` (404)
2. Find song by song_id AND album_id (exclude soft-deleted) → not found: `Not Found` (404)
3. Soft-delete song: `UPDATE songs SET deleted_at = NOW()`

#### Response (200)
```json
{
  "success": true
}
```
