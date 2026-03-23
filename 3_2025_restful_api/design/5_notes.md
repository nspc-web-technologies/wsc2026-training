# Implementation Notes - WSC Module C

## Response Field Order

### Album `publisher` position differs between endpoints

- API #4 (Get Album Details): `..., description, created_at, updated_at, publisher` (publisher AFTER timestamps)
- API #16/#17 (Create/Update Album): `..., description, publisher, created_at, updated_at` (publisher BEFORE timestamps)
- API #11 metrics=album: `..., description, publisher, created_at, updated_at, total_view_count`

### Song detail field order differs between endpoints

- API #10/#11: `id, album_id, title, duration_seconds, order, label, view_count, is_cover, lyrics, cover_image_url, created_at, updated_at`
- API #19/#21: `id, album_id, title, duration_seconds, lyrics, order, view_count, label, is_cover, cover_image_url, created_at, updated_at`

### Simplified list responses

- API #3 (album list): only `id, title, artist, release_year, publisher`
- API #6 (album songs): `id, album_id, title, label, duration_seconds, order, is_cover, cover_image_url`
- API #7 (all songs): `id, album_id, title, label, duration_seconds, album_title, cover_image_url`

### User response field differences

- API #12 (Get All Users): `{id, username, email, role, is_banned, created_at}` — NO `updated_at`
- API #13 (Update User Role): `{id, username, email, role, is_banned, created_at, updated_at}` — has BOTH
- API #14 (Ban User): `{id, username, email, role, is_banned, updated_at}` — NO `created_at`
- API #15 (Unban User): `{id, username, email, role, is_banned, updated_at}` — NO `created_at`

## Laravel Gotchas

### `cover_image_url` generation

Always plain string: `'/api/songs/' . $song->id . '/cover'`

Do NOT use `url()` or `asset()` — absolute URL fails scoring.

### `order` column

MySQL reserved word. Wrap in backticks in raw queries: `` `order` ``. Eloquent's `orderBy('order')` handles this automatically.

### `Is_cover` casing

Spec uses `Is_cover` (capital I) in body tables for API #19 and #21. Resolve early:
`$isCoverRaw = $request->input('is_cover') ?? $request->input('Is_cover');`

### `helpers.php` registration

Must add `"autoload": { "files": ["app/helpers.php"] }` in `composer.json` and run `composer dump-autoload`.

### `bootstrap/app.php`

Must configure `withRouting` (api routes), `withMiddleware` (aliases), `withExceptions` (JSON error handler). Without these, routes won't load, middleware aliases won't resolve, and `abort()` returns HTML instead of JSON.
