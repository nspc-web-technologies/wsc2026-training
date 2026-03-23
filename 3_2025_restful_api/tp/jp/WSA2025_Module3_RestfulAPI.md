![Logo 1](../media/image1.png) ![Logo 2](../media/image2.png)

![Overview Diagram](../media/image3.png)

# モジュール C — モジュール 3: RESTful API

## 目次

- [はじめに](#はじめに)
- [プロジェクトとタスクの説明](#プロジェクトとタスクの説明)
  - [初期データ](#初期データ)
- [Public API](#public-api)
- [User API](#user-api)
- [Admin API](#admin-api)
- [エラーメッセージ](#エラーメッセージ)
- [API](#api)
- [APIスキーマ](#apiスキーマ)
  - [1. ユーザーログイン](#1-ユーザーログイン)
  - [2. ユーザー登録](#2-ユーザー登録)
  - [3. 全アルバム取得](#3-全アルバム取得)
  - [4. アルバム詳細取得](#4-アルバム詳細取得)
  - [5. アルバムカバー取得](#5-アルバムカバー取得)
  - [6. アルバム内の曲取得](#6-アルバム内の曲取得)
  - [7. 全曲取得](#7-全曲取得)
  - [8. 曲カバー取得](#8-曲カバー取得)
  - [9. ユーザーログアウト](#9-ユーザーログアウト)
  - [10. 曲詳細取得](#10-曲詳細取得)
  - [11. 統計結果取得](#11-統計結果取得)
  - [12. 全ユーザー取得](#12-全ユーザー取得)
  - [13. ユーザーロール更新](#13-ユーザーロール更新)
  - [14. ユーザーBAN](#14-ユーザーban)
  - [15. ユーザーBAN解除](#15-ユーザーban解除)
  - [16. 新規アルバム作成](#16-新規アルバム作成)
  - [17. アルバム詳細更新](#17-アルバム詳細更新)
  - [18. アルバム削除](#18-アルバム削除)
  - [19. アルバムに曲を追加](#19-アルバムに曲を追加)
  - [20. 曲の順序更新](#20-曲の順序更新)
  - [21. 曲詳細更新](#21-曲詳細更新)
  - [22. アルバムから曲を削除](#22-アルバムから曲を削除)
- [採点サマリー](#採点サマリー)

## はじめに

オフィスの管理者（「admin」とも呼ばれる）が楽曲プロダクトを管理するためのアルバム管理システムを作成する。楽曲プロダクトはパブリッシャーに属する。パブリッシャーは関連するアルバムデータも管理する。管理者はこれらのパブリッシャーと楽曲プロダクトの一覧表示・編集を閲覧・管理することもできる。

各楽曲プロダクトのレコードには固有の識別番号があり、これをISRC（International Standard Recording Code）と呼ぶ。ISRCは12文字で、通常次のように表記される: `CC-XXX-YY-NNNNN`（例: `TW-XYZ-25-00821`）

- CC → 国コード（例: TWは台湾）
- XXX → 登録者コード（会社/レーベルコード）
- YY → 登録年（下2桁）
- NNNNN → 特定の録音に対する一意の番号

公開APIは以下の通り:

- ユーザーアクセス機能
- 公開アルバム・楽曲機能
- その他の機能

## プロジェクトとタスクの説明

このプロジェクトでは、パブリッシャーが楽曲プロダクトを管理するためのアルバム・楽曲プロダクト管理システムを作成する。

データのクエリと読み取り用のJSON APIも含まれる。

このプロジェクトは `http://wsXX.worldskills.org/XX_module_c/` でアクセス可能であること。`XX`は座席番号。

### 初期データ

#### Users テーブル

| Id | username | email           | Password   | role  |
|----|----------|-----------------|------------|-------|
| 1  | admin    | admin@web.wsa   | adminpass  | admin |
| 2  | user1    | user1@web.wsa   | user1pass  | user  |
| 3  | user2    | user2@web.wsa   | user2pass  | user  |

#### Labels テーブル

| Id | name       |
|----|------------|
| 1  | Pop        |
| 2  | Rock       |
| 3  | Hip-Hop    |
| 4  | Electronic |
| 5  | Jazz       |
| 6  | Classical  |
| 7  | Chill      |
| 8  | Country    |

## Public API

Public APIでは、誰でもすべてのアルバムと楽曲の情報をクエリできる。これらの機能を使用するための登録やログインは不要。

ユーザーはLogin APIを通じてログインできる。ログイン後、アクセストークンを受け取り、認証が必要なAPI機能にアクセスするために使用できる。アクセストークンは、ユーザーのusernameをMD5ハッシュし、小文字の16進数文字列に変換して生成される。

### カーソルベースページネーション

APIがページネーションを必要とする場合、カーソルベースページネーションを使用する。各返却結果には`next_cursor`フィールドが含まれる。ユーザーはこのフィールドの値を次のAPIリクエストに渡して、次のページのデータを取得できる。`next_cursor`が`null`の場合、これ以上クエリ可能なデータがないことを示す。

`next_cursor`の値は、前の結果セットの最後のアイテムの一意の識別子をJSONで囲み、Base64エンコードした文字列である。デフォルトではページあたり10件のレコードが返され、ユーザーは`limit`パラメータを使用してページあたりの返却レコード数を調整できる。

例: IDが1から100のレコードが100件あり、ページあたり10件返される場合、最初のリクエストはID 1〜10のデータを返す。また、`next_cursor`フィールドに`{"id":10}`（Base64エンコード済み）を返す。ユーザーが次のリクエストを行う際、この文字列を`cursor`パラメータに渡してID 11〜20のデータを取得する。`next_cursor`が`null`になるまで繰り返す。

### 年フィルター

アルバム一覧APIを取得する際、`year`パラメータを使用して特定の年でアルバムをフィルタリングできる。`year`パラメータは単一の年（例: `2020`）または年の範囲（例: `2018-2020`）をサポートする。`year`パラメータが指定されない場合、全年のアルバムを返す。

### アルバムカバーロジック

![Cover - 1 image](../media/image5.jpeg) ![Cover - 2 images](../media/image6.jpeg) ![Cover - 3 images](../media/image7.jpeg)

「アルバムカバー取得」のロジックは、そのアルバムの曲の`songs.is_cover`プロパティによって決定される。カバーは1枚、2枚、または3枚の曲の`cover_images`の組み合わせである（上の画像の通り）。

組み合わせの順序は、アルバム内の曲の順序（order）に従う必要がある。3曲を超えてカバーとしてマークされている場合、エラーメッセージ（`"Too many covers provided"`）が返される。

曲の追加、変更、削除、または並べ替え時に、`is_cover`ステータスに関連する場合、結果のカバーの組み合わせにも影響する。

例: アルバムに5曲ある場合:

| Song  | is_cover | order |
|-------|----------|-------|
| Song1 | true     | 1     |
| Song2 | false    | 2     |
| Song3 | false    | 3     |
| Song4 | true     | 4     |
| Song5 | true     | 5     |

この場合、アルバムカバーは: Song1、Song4、Song5のカバーをその順序で組み合わせた3枚の画像の組み合わせとなる。

## User API

ユーザーはLogin APIを通じて登録済みアカウントにログインできる。APIを呼び出す際、アクセストークンを`X-Authorization`ヘッダーに配置し、APIがアクセストークンによるユーザー認証を実行できるようにする。

ユーザーがログアウトすると、使用していたアクセストークンを削除（無効化）する必要があり、そのトークンでの再ログインを防ぐ。

認証が必要なAPIを呼び出す際にアクセストークンが提供されない場合、401エラーステータスと対応するエラーメッセージが返される。

ユーザーの機能:

- ユーザーは曲の詳細を閲覧できる
- ユーザーは統計結果を取得できる

パラメータが以下の場合:

- `?metrics=song`: 曲の一覧を返す。閲覧数の降順でソート。
- `?metrics=album`: アルバムの一覧を返す。合計閲覧数の降順でソート。
- `?metrics=label`: ラベルの一覧を返す。各ラベルには閲覧数の降順でソートされたトップ10の曲が含まれる。
  - （オプション）`labels`パラメータ（例: `labels=Pop,Rock`）と組み合わせて、特定のラベルでフィルタリングできる。

## Admin API

ユーザーのロールが`"admin"`の場合、他のユーザーを管理できる。全ユーザーの取得、ユーザーの更新、ユーザーのブロック/ブロック解除が含まれる。そのため、BANされたユーザーはUser APIへのアクセスが制限される。

## エラーメッセージ

エラーが発生した場合、状況に応じたエラーメッセージとHTTPステータスコードを返す必要がある。

エラーレスポンスの形式:

Response ( Unauthorized 401 )

Content-Type: `application/json`

```json
{
  "success": false,
  "message": "Access Token is required"
}
```

エラーメッセージ:

| Message | HTTPステータスコード | 説明 |
|---------|-----------------|------|
| Access Token is required | 401 | 保護されたAPIを呼び出す際に`X-Authorization`ヘッダーにアクセストークンが提供されていない。 |
| Invalid Access Token | 401 | 無効、期限切れ、または存在しないアクセストークンが提供された。 |
| Access denied | 403 | ログイン済みユーザーが自分に属さないリソースを操作しようとした（例: 他のユーザーのアルバムを更新または削除）。 |
| Admin access required | 403 | ロールが`'admin'`ではないユーザーがAdmin APIにアクセスしようとした（例: `GET /api/users`）。 |
| User is banned | 403 | アカウントがブロックされたユーザーがログインまたは保護された機能にアクセスしようとした。 |
| Not Found | 404 | リクエストされたAPIルートが存在しない。/リクエストされたリソース（例: アルバム、曲、ユーザー）が存在しない（例: `GET /api/albums/999`）。 |
| Cover Not Found | 404 | リクエストされたアルバムまたは曲のカバー画像が存在しない。 |
| Too many covers provided | 400 | 操作（例: 曲の追加/変更）により、アルバムのカバー画像が3枚を超える。 |
| Login failed | 400 | ログイン時に不正なusernameまたはpasswordが提供された。 |
| Username already taken | 409 | 登録時にusernameが既に使用されている。 |
| Email already taken | 409 | 登録時にメールアドレスが既に使用されている。 |
| Validation failed | 400 | リクエストに必須フィールドが不足している（例: 登録時にusernameが提供されていない）。/リクエストのフィールドの形式が不正（例: 無効なメール形式、`release_year`が数値ではない）。/曲の順序更新時に`song_ids`に無効なIDまたはアルバムに属さないIDが含まれている。/ユーザーのロールを無効な値に更新しようとした。 |
| Invalid parameter | 400 | 無効なクエリパラメータが提供された（例: `limit`が100を超えているまたは数値でない）。 |
| Invalid cursor | 400 | 不正または無効なカーソルが提供された。 |
| Invalid year format | 400 | `year`パラメータの形式が不正（例: `"abc"`または`"2000-1990"`）。 |
| Invalid file type | 400 | アップロードされた`cover_image`が許容される画像形式ではない。 |
| User not found | 404 | 管理者が存在しない`user_id`に対して操作を実行しようとした。 |
| Cannot ban self | 400 | 管理者が自分自身のアカウントをブロックしようとした。 |
| Last admin demotion forbidden | 403 | システムは常に少なくとも1人の管理者を維持する必要がある。 |
| Banned user update failed | 409 | BANされたユーザーのロールは更新できない。 |
| Cannot ban another admin | 403 | 管理者は他の管理者をBANできない。 |

## API

### Public API

| # | 項目 | メソッド | URL |
|---|------|---------|-----|
| 1 | ユーザーログイン | POST | `/api/login` |
| 2 | ユーザー登録 | POST | `/api/register` |
| 3 | 全アルバム取得 | GET | `/api/albums` |
| 4 | アルバム詳細取得 | GET | `/api/albums/{album_id}` |
| 5 | アルバムカバー取得 | GET | `/api/albums/{album_id}/cover` |
| 6 | アルバム内の曲取得 | GET | `/api/albums/{album_id}/songs` |
| 7 | 全曲取得 | GET | `/api/songs` |
| 8 | 曲カバー取得 | GET | `/api/songs/{song_id}/cover` |

### User API

| # | 項目 | メソッド | URL |
|---|------|---------|-----|
| 9 | ユーザーログアウト | POST | `/api/logout` |
| 10 | 曲詳細取得 | GET | `/api/songs/{song_id}` |
| 11 | 統計結果取得 | GET | `/api/statistics` |

### Admin API

| # | 項目 | メソッド | URL |
|---|------|---------|-----|
| 12 | 全ユーザー取得 | GET | `/api/users` |
| 13 | ユーザーロール更新 | PUT | `/api/users/{user_id}` |
| 14 | ユーザーBAN | PUT | `/api/users/{user_id}/ban` |
| 15 | ユーザーBAN解除 | PUT | `/api/users/{user_id}/unban` |
| 16 | 新規アルバム作成 | POST | `/api/albums` |
| 17 | アルバム詳細更新 | PUT | `/api/albums/{album_id}` |
| 18 | アルバム削除 | DELETE | `/api/albums/{album_id}` |
| 19 | アルバムに曲を追加 | POST | `/api/albums/{album_id}/songs` |
| 20 | 曲の順序更新 | PUT | `/api/albums/{album_id}/songs/order` |
| 21 | 曲詳細更新 | POST | `/api/albums/{album_id}/songs/{song_id}` |
| 22 | アルバムから曲を削除 | DELETE | `/api/albums/{album_id}/songs/{song_id}` |

## APIスキーマ

### 1. ユーザーログイン

`POST /api/login`

#### リクエスト

Content-Type: `application/json`

```json
{
  "username": "user1",
  "password": "user1pass"
}
```

#### レスポンス (Success 200)

Content-Type: `application/json`

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

#### リクエスト

Content-Type: `application/json`

```json
{
  "username": "user4",
  "email": "user4@web.wsa",
  "password": "user4pass"
}
```

#### レスポンス (Success 201 Created)

Content-Type: `application/json`

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

#### リクエスト

クエリパラメータ:

- `capital`: (string) 例: `"A"`
- `year`: (string) 例: `"1980-2000"`
- `limit`: (number) 例: `10`
- `cursor`: (string) 例: `"eyJpZCI6IDEwfQ"`

例: `/api/albums?filter=A&cursor=eyJpZCI6IDEwfQ`

#### レスポンス (Success 200)

Content-Type: `application/json`

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
    },
    {
      "id": 12,
      "title": "Abbey Road",
      "artist": "The Beatles",
      "release_year": 1969,
      "publisher": {
        "id": 2,
        "username": "user2",
        "email": "user2@web.wsa"
      }
    }
    // ... 残りの8件
  ],
  "meta": {
    "prev_cursor": "e2lkOiAxMH0K",
    "next_cursor": "e2lkOiAyMX0K"
  }
}
```

### 4. アルバム詳細取得

`GET /api/albums/{album_id}`

#### リクエスト

ルートパラメータ:

- `album_id`: (integer) 例: `12`

#### レスポンス (Success 200)

Content-Type: `application/json`

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

アルバムカバーは、アルバムの曲の`is_cover`ステータスに基づいて動的に生成される。

`GET /api/albums/{album_id}/cover`

#### リクエスト

ルートパラメータ:

- `album_id`: (integer) 例: `12`

#### レスポンス (Success 200)

Content-Type: `image/jpeg`

*(バイナリ画像データ)*

### 6. アルバム内の曲取得

`order`フィールドの昇順でソート。

`GET /api/albums/{album_id}/songs`

#### リクエスト

ルートパラメータ:

- `album_id`: (integer) 例: `12`

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true,
  "data": [
    {
      "id": 101,
      "album_id": 12,
      "title": "Come Together",
      "label": ["a", "b", "c"],
      "duration_seconds": 259,
      "order": 1,
      "is_cover": false,
      "cover_image_url": "/api/songs/101/cover"
    },
    {
      "id": 102,
      "album_id": 12,
      "title": "Something",
      "label": ["a", "b", "c"],
      "duration_seconds": 182,
      "order": 2,
      "is_cover": false,
      "cover_image_url": "/api/songs/102/cover"
    }
  ]
}
```

### 7. 全曲取得

`GET /api/songs`

#### リクエスト

クエリパラメータ:

- `keyword`: (string) 例: `"love"`
- `limit`: (number) 例: `10`
- `cursor`: (string) 例: `"eyJpZCI6IDIwMH0"`

例: `/api/songs?filter[keyword]=love`

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true,
  "data": [
    {
      "id": 102,
      "album_id": 12,
      "title": "Something",
      "label": ["a", "b", "c"],
      "duration_seconds": 182,
      "album_title": "Abbey Road",
      "cover_image_url": "/api/songs/102/cover"
    },
    {
      "id": 205,
      "album_id": 11,
      "title": "Love of My Life",
      "label": ["a", "b", "c"],
      "duration_seconds": 217,
      "album_title": "A Night at the Opera",
      "cover_image_url": "/api/songs/205/cover"
    }
  ],
  "meta": {
    "next_cursor": "eyJpZCI6IDIwNX0",
    "prev_cursor": "eyJpZCI6IDIwNH0="
  }
}
```

### 8. 曲カバー取得

`GET /api/songs/{song_id}/cover`

#### リクエスト

ルートパラメータ:

- `song_id`: (integer) 例: `101`

#### レスポンス (Success 200)

Content-Type: `image/jpeg`

*(バイナリ画像データ)*

### 9. ユーザーログアウト

`POST /api/logout`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true
}
```

### 10. 曲詳細取得

閲覧数がインクリメントされる。

`GET /api/songs/{song_id}`

#### リクエスト

ルートパラメータ:

- `song_id`: (integer) 例: `101`

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true,
  "data": {
    "id": 101,
    "album_id": 12,
    "title": "Come Together",
    "duration_seconds": 259,
    "order": 1,
    "label": ["a", "b", "c"],
    "view_count": 123,
    "is_cover": false,
    "lyrics": "Here come old flat top, he come grooving up slowly...",
    "cover_image_url": "/api/songs/101/cover",
    "created_at": "2025-10-20T10:01:00.000Z",
    "updated_at": "2025-10-20T10:01:00.000Z"
  }
}
```

### 11. 統計結果取得

metricsが`'label'`または`'album'`の場合: そのmetricsでグループ化し、`view_count`でソート。

metricsが`'song'`の場合: 1つ以上のラベル（例: Pop, Rock）でフィルタリングし、`view_count`でソート。

`GET /api/statistics`

#### リクエスト

クエリパラメータ:

- `metrics`: (string) `label` | `album` | `song` — 例: `"label"`
- `labels`: (string, optional) — 例: `"Pop"`

例: `/api/statistics?metrics=song`

#### レスポンス — `metrics=song` (Success 200)

Content-Type: `application/json`

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
      "label": ["a", "b", "c"],
      "view_count": 123,
      "is_cover": false,
      "lyrics": "Here come old flat top, he come grooving up slowly...",
      "cover_image_url": "/api/songs/101/cover",
      "created_at": "2025-10-20T10:01:00.000Z",
      "updated_at": "2025-10-20T10:01:00.000Z"
    },
    {
      "id": 100,
      "album_id": 10,
      "title": "Together",
      "duration_seconds": 248,
      "order": 1,
      "label": ["a"],
      "view_count": 12,
      "is_cover": false,
      "lyrics": "slowly...",
      "cover_image_url": "/api/songs/100/cover",
      "created_at": "2025-10-20T10:01:00.000Z",
      "updated_at": "2025-10-20T10:01:00.000Z"
    }
  ]
}
```

例: `/api/statistics?metrics=album`

```json
{
  "success": true,
  "data": [
    {
      "id": 13,
      "title": "My Updated Album Title",
      "artist": "My Band",
      "release_year": 2025,
      "genre": "Indie Rock",
      "description": "Updated description.",
      "publisher": {
        "id": 1,
        "username": "admin",
        "email": "admin@web.wsa"
      },
      "created_at": "2025-10-23T16:00:00.000Z",
      "updated_at": "2025-10-23T16:05:00.000Z",
      "total_view_count": 17
    },
    {
      "id": 12,
      "title": "My Updated Album Title 2",
      "artist": "My Band 2",
      "release_year": 2021,
      "genre": "Indie Rock",
      "description": "Updated description.",
      "publisher": {
        "id": 1,
        "username": "admin",
        "email": "admin@web.wsa"
      },
      "created_at": "2025-10-23T16:00:00.000Z",
      "updated_at": "2025-10-23T16:05:00.000Z",
      "total_view_count": 10
    }
  ]
}
```

例: `/api/statistics?metrics=label`

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
          "label": ["Rock", "b", "c"],
          "view_count": 4,
          "is_cover": false,
          "lyrics": "Here come old flat top...",
          "cover_image_url": "/api/songs/101/cover",
          "created_at": "2025-10-20T10:01:00.000Z",
          "updated_at": "2025-10-20T10:01:00.000Z"
        },
        {
          "id": 100,
          "album_id": 10,
          "title": "Together",
          "duration_seconds": 248,
          "order": 1,
          "label": ["Rock"],
          "view_count": 2,
          "is_cover": false,
          "lyrics": "slowly...",
          "cover_image_url": "/api/songs/100/cover",
          "created_at": "2025-10-20T10:01:00.000Z",
          "updated_at": "2025-10-20T10:01:00.000Z"
        }
      ]
    }
    // ...
  ]
}
```

### 12. 全ユーザー取得

`GET /api/users`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

クエリパラメータ:

- `cursor`: (string) 例: `"e2lkOiAxfQo="`
- `limit`: (number) 例: `10`

#### レスポンス (Success 200)

Content-Type: `application/json`

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
    },
    {
      "id": 2,
      "username": "user2",
      "email": "user2@web.wsa",
      "role": "user",
      "is_banned": false,
      "created_at": "2025-10-23T15:00:00.000Z"
    }
    // ... 残りの8件
  ],
  "meta": {
    "next_cursor": "e2lkOiAxMX0K",
    "prev_cursor": "e2lkOiAxMH0="
  }
}
```

### 13. ユーザーロール更新

システムは常に少なくとも1つの管理者アカウントを維持する必要がある。最後の管理者が自分のロールを非管理者ロール（例: `'user'`）に変更しようとした場合、エラーを返す必要がある。

BANされたユーザーのロールは更新できない。

`PUT /api/users/{user_id}`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

Content-Type: `application/json`

ルートパラメータ:

- `user_id`: (integer) 例: `2`

Body:

```json
{
  "role": "admin"
}
```

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true,
  "data": {
    "id": 2,
    "username": "user2",
    "email": "user2@web.wsa",
    "role": "user",
    "is_banned": false,
    "created_at": "2025-10-23T15:00:00.000Z",
    "updated_at": "2025-10-23T16:20:00.000Z"
  }
}
```

### 14. ユーザーBAN

自分自身をBANすることはできない。

`PUT /api/users/{user_id}/ban`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

ルートパラメータ:

- `user_id`: (integer) 例: `2`

#### レスポンス (Success 200)

Content-Type: `application/json`

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

#### リクエスト

Header: `X-Authorization: Bearer <token>`

ルートパラメータ:

- `user_id`: (integer) 例: `2`

#### レスポンス (Success 200)

Content-Type: `application/json`

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

> 自動採番が必要

`POST /api/albums`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

Content-Type: `multipart/form-data`

Body:

| フィールド    | 型     |
|--------------|--------|
| title        | string |
| artist       | string |
| release_year | number |
| genre        | string |
| description  | string |

#### レスポンス (Success 201 Created)

Content-Type: `application/json`

```json
{
  "success": true,
  "data": {
    "id": 13,
    "title": "My New Album",
    "artist": "My Band",
    "release_year": 2025,
    "genre": "Indie Rock",
    "description": "This is the description of my new album.",
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

#### リクエスト

Header: `X-Authorization: Bearer <token>`

Content-Type: `application/json`

ルートパラメータ:

- `album_id`: (integer) 例: `13`

Body:

| フィールド   | 型     |
|-------------|--------|
| title       | string |
| description | string |

#### レスポンス (Success 200)

Content-Type: `application/json`

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

この削除はソフトデリートである。

`DELETE /api/albums/{album_id}`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

ルートパラメータ:

- `album_id`: (integer) 例: `13`

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true
}
```

### 19. アルバムに曲を追加

ラベルはカンマ区切りで、初期データのラベルに存在する必要がある。

`POST /api/albums/{album_id}/songs`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

Content-Type: `multipart/form-data`

ルートパラメータ:

- `album_id`: (integer) 例: `13`

Body:

| フィールド        | 型                  |
|------------------|---------------------|
| title            | string              |
| duration_seconds | number              |
| label            | string, optional    |
| lyrics           | string              |
| cover_image      | file, image/jpeg    |
| Is_cover         | boolean             |

#### レスポンス (Success 201 Created)

Content-Type: `application/json`

```json
{
  "success": true,
  "data": {
    "id": 301,
    "album_id": 13,
    "title": "My First Song",
    "duration_seconds": 180,
    "lyrics": "Lyrics for the first song...",
    "order": 1,
    "view_count": 0,
    "label": ["a", "b", "c"],
    "is_cover": false,
    "cover_image_url": "/api/songs/301/cover",
    "created_at": "2025-10-23T16:10:00.000Z",
    "updated_at": "2025-10-23T16:10:00.000Z"
  }
}
```

### 20. 曲の順序更新

`PUT /api/albums/{album_id}/songs/order`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

Content-Type: `application/json`

ルートパラメータ:

- `album_id`: (integer) 例: `13`

Body:

```json
{
  "song_ids": [302, 301]
}
```

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true
}
```

### 21. 曲詳細更新

ラベルはカンマ区切りで、初期データのラベルに存在する必要がある。

`POST /api/albums/{album_id}/songs/{song_id}`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

Content-Type: `multipart/form-data`

ルートパラメータ:

- `album_id`: (integer) 例: `13`
- `song_id`: (integer) 例: `301`

Body:

| フィールド        | 型               |
|------------------|------------------|
| title            | string           |
| duration_seconds | number           |
| label            | string           |
| lyrics           | string           |
| cover_image      | file, image/jpeg |
| Is_cover         | boolean          |

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true,
  "data": {
    "id": 301,
    "album_id": 13,
    "title": "My First Song (Remix)",
    "duration_seconds": 190,
    "lyrics": "Lyrics for the first song...",
    "order": 2,
    "view_count": 0,
    "label": ["a", "b", "c"],
    "is_cover": false,
    "cover_image_url": "/api/songs/301/cover",
    "created_at": "2025-10-23T16:10:00.000Z",
    "updated_at": "2025-10-23T16:15:00.000Z"
  }
}
```

### 22. アルバムから曲を削除

この削除はソフトデリートである。

`DELETE /api/albums/{album_id}/songs/{song_id}`

#### リクエスト

Header: `X-Authorization: Bearer <token>`

ルートパラメータ:

- `album_id`: (integer) 例: `13`
- `song_id`: (integer) 例: `301`

#### レスポンス (Success 200)

Content-Type: `application/json`

```json
{
  "success": true
}
```

## 採点サマリー

| # | サブ基準 | 配点 |
|---|---------|------|
| 1 | Public API   | 8.75  |
| 2 | User API     | 4.5   |
| 3 | Admin API    | 10.75 |
| 合計 | | 24.00 |
