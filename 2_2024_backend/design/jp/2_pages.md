# ページ設計 - WSC2024 モジュールB

## URL構成

### 認証ページ

| URL | 説明 |
|-----|------|
| `/login` | ログインページ |

### 管理ページ（認証必須）

| URL | 説明 |
|-----|------|
| `/companies` | 企業一覧（有効） |
| `/companies/deactivated` | 企業一覧（無効化済み） |
| `/companies/new` | 企業作成フォーム |
| `/companies/{id}` | 企業詳細 |
| `/companies/{id}/edit` | 企業編集フォーム |
| `/products` | 製品一覧 |
| `/products/new` | 製品作成フォーム |
| `/products/{gtin}` | 製品詳細 |
| `/products/{gtin}/edit` | 製品編集フォーム |

### ルート定義

```php
// 認証
Route::get('/login', [AuthController::class, 'showLogin']);
Route::post('/login', [AuthController::class, 'login']);

// 企業管理（認証必須）
Route::middleware('auth')->group(function () {
    Route::get('/companies', [CompanyController::class, 'index']);
    Route::get('/companies/deactivated', [CompanyController::class, 'deactivated']);
    Route::get('/companies/new', [CompanyController::class, 'create']);
    Route::post('/companies', [CompanyController::class, 'store']);
    Route::get('/companies/{id}', [CompanyController::class, 'show']);
    Route::get('/companies/{id}/edit', [CompanyController::class, 'edit']);
    Route::put('/companies/{id}', [CompanyController::class, 'update']);
    Route::post('/companies/{id}/deactivate', [CompanyController::class, 'deactivate']);

    // 製品管理（認証必須）
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/new', [ProductController::class, 'create']);
    Route::post('/products', [ProductController::class, 'store']);
    Route::get('/products/{gtin}', [ProductController::class, 'show']);
    Route::get('/products/{gtin}/edit', [ProductController::class, 'edit']);
    Route::put('/products/{gtin}', [ProductController::class, 'update']);
    Route::post('/products/{gtin}/hide', [ProductController::class, 'hide']);
    Route::delete('/products/{gtin}', [ProductController::class, 'destroy']);
});
```

## ログインページ

**URL:** `GET /login`

### フォームフィールド

| ラベル | name属性 | タイプ | 説明 |
|--------|----------|--------|------|
| Passphrase | `passphrase` | `password` | 入力フィールド |
| - | - | `submit` | ログインボタン |

### 送信

- **メソッド:** POST `/login`
- **成功時:** `/companies`にリダイレクト
- **失敗時:** エラーメッセージを表示

### 認証情報

- パスフレーズ: `"admin"`

## 企業一覧ページ（有効）

**URL:** `GET /companies`

フィルター: `is_active = TRUE`

### 表示フィールド

| 表示名 | DBカラム |
|--------|----------|
| Company Name | `name` |
| Address | `address` |
| Telephone | `telephone` |
| Email | `email` |
| Owner Name | `owner_name` |
| Contact Name | `contact_name` |

### リンク

- 詳細: `/companies/{id}`
- 新規作成: `/companies/new`
- 無効化済み企業: `/companies/deactivated`

## 企業一覧ページ（無効化済み）

**URL:** `GET /companies/deactivated`

フィルター: `is_active = FALSE`

### 表示フィールド

| 表示名 | DBカラム |
|--------|----------|
| Company Name | `name` |
| Address | `address` |
| Telephone | `telephone` |
| Email | `email` |
| Owner Name | `owner_name` |
| Contact Name | `contact_name` |

### リンク

- 詳細: `/companies/{id}`
- 有効企業: `/companies`

## 企業詳細ページ

**URL:** `GET /companies/{id}`

### 表示フィールド

| 表示名 | DBカラム |
|--------|----------|
| Company Name | `name` |
| Company Address | `address` |
| Company Telephone | `telephone` |
| Company Email | `email` |
| Owner Name | `owner_name` |
| Owner Mobile | `owner_mobile` |
| Owner Email | `owner_email` |
| Contact Name | `contact_name` |
| Contact Mobile | `contact_mobile` |
| Contact Email | `contact_email` |

### 関連製品一覧

この企業に属する製品を表示する。

| 表示名 | DBカラム |
|--------|----------|
| GTIN | `gtin` |
| English Name | `name_en` |
| French Name | `name_fr` |
| Brand | `brand` |
| Status | `is_hidden` (Visible / Hidden) |

- 各製品は`/products/{gtin}`にリンク

### リンク・ボタン

| 要素 | アクション |
|------|-----------|
| 編集リンク | `/companies/{id}/edit`に遷移 |
| 無効化ボタン | `window.confirm` → POST `/companies/{id}/deactivate` |

**注意:** 企業の削除機能なし（仕様上、削除は不可）

### 無効化処理

企業が無効化されると、関連する全製品が自動的に非表示になる（`is_hidden = TRUE`）。

```php
// 企業の無効化処理
$company->is_active = false;
$company->save();

// 関連する全製品を非表示にする
Product::where('company_id', $company->id)->update(['is_hidden' => true]);
```

## 企業作成ページ

**URL:** `GET /companies/new`

### フォームフィールド

全フィールド必須:

| ラベル | name属性 | タイプ |
|--------|----------|--------|
| Company Name | `name` | `text` |
| Company Address | `address` | `textarea` |
| Company Telephone | `telephone` | `text` |
| Company Email | `email` | `email` |
| Owner Name | `owner_name` | `text` |
| Owner Mobile | `owner_mobile` | `text` |
| Owner Email | `owner_email` | `email` |
| Contact Name | `contact_name` | `text` |
| Contact Mobile | `contact_mobile` | `text` |
| Contact Email | `contact_email` | `email` |

### 送信

- **メソッド:** POST `/companies`
- **成功時:** `/companies`にリダイレクト

## 企業編集ページ

**URL:** `GET /companies/{id}/edit`

### フォームフィールド

企業作成ページと同じフィールド（全て必須）

### 送信

- **メソッド:** PUT `/companies/{id}`
- **成功時:** `/companies`にリダイレクト

## 製品一覧ページ

**URL:** `GET /products`

全製品を1つのリストで表示（表示・非表示の両方）

### 表示フィールド

| 表示名 | DBカラム |
|--------|----------|
| GTIN | `gtin` |
| English Name | `name_en` |
| French Name | `name_fr` |
| Brand | `brand` |
| Company Name | `company.name` |

### アクション

- 詳細リンク: `/products/{gtin}`

### 製品削除処理

```php
// 画像ファイルも削除する
if ($product->image_path) {
    @unlink(public_path($product->image_path));
}

// データベースから削除
$product->delete();
```

### リンク

- 新規作成: `/products/new`

## 製品詳細ページ

**URL:** `GET /products/{gtin}`

### 表示フィールド

| 表示名 | DBカラム |
|--------|----------|
| GTIN | `gtin` |
| Company | `company.name` |
| English Name | `name_en` |
| French Name | `name_fr` |
| English Description | `description_en` |
| French Description | `description_fr` |
| Brand | `brand` |
| Country of Origin | `country_of_origin` |
| Gross Weight | `gross_weight` |
| Net Weight | `net_weight` |
| Weight Unit | `weight_unit` |
| Product Image | `image_path` |

### リンク・ボタン

| 要素 | 表示条件 | アクション |
|------|---------|-----------|
| 編集リンク | 常時 | `/products/{gtin}/edit`に遷移 |
| 非表示ボタン | `is_hidden = FALSE` | `window.confirm` → POST `/products/{gtin}/hide` |
| 削除ボタン | `is_hidden = TRUE` | `window.confirm` → DELETE `/products/{gtin}` |

## 製品作成ページ

**URL:** `GET /products/new`

### フォームフィールド

| ラベル | name属性 | タイプ | 備考 |
|--------|----------|--------|------|
| GTIN | `gtin` | `text` | 必須、13-14桁の数字 |
| Company | `company_id` | `select` | 必須、有効な企業のみ |
| English Name | `name_en` | `text` | 必須 |
| French Name | `name_fr` | `text` | 必須 |
| English Description | `description_en` | `textarea` | 必須 |
| French Description | `description_fr` | `textarea` | 必須 |
| Brand | `brand` | `text` | 必須 |
| Country of Origin | `country_of_origin` | `text` | 必須 |
| Gross Weight | `gross_weight` | `number` | 必須、step="0.001" |
| Net Weight | `net_weight` | `number` | 必須、step="0.001" |
| Weight Unit | `weight_unit` | `text` | 必須 |
| Product Image | `image` | `file` | 任意、jpg/jpeg/pngのみ |

### 送信

- **メソッド:** POST `/products`
- **Content-Type:** `multipart/form-data`
- **成功時:** `/products`にリダイレクト

### バリデーション

| フィールド | ルール |
|-----------|--------|
| GTIN | 13桁または14桁の数字のみ、一意であること |

### 実装: 画像アップロード

```php
if ($request->hasFile('image')) {
    $ext = $request->file('image')->extension();
    $filename = $product->gtin . '.' . $ext;
    $request->file('image')->move(public_path('uploads/products'), $filename);
    $product->image_path = '/uploads/products/' . $filename;
} else {
    $product->image_path = '/images/placeholder.png';
}
$product->save();
```

## 製品編集ページ

**URL:** `GET /products/{gtin}/edit`

### フォームフィールド

| ラベル | name属性 | タイプ | 備考 |
|--------|----------|--------|------|
| GTIN | `gtin` | `text` | 表示のみ（disabled） |
| Company | `company_id` | `select` | 必須、有効な企業のみ |
| English Name | `name_en` | `text` | 必須 |
| French Name | `name_fr` | `text` | 必須 |
| English Description | `description_en` | `textarea` | 必須 |
| French Description | `description_fr` | `textarea` | 必須 |
| Brand | `brand` | `text` | 必須 |
| Country of Origin | `country_of_origin` | `text` | 必須 |
| Gross Weight | `gross_weight` | `number` | 必須、step="0.001" |
| Net Weight | `net_weight` | `number` | 必須、step="0.001" |
| Weight Unit | `weight_unit` | `text` | 必須 |
| Product Image | `image` | `file` | 任意、jpg/jpeg/pngのみ、画像なしの場合はプレースホルダー |
| Delete Image | `delete_image` | `checkbox` | チェックで既存画像を削除 |

### 送信

- **メソッド:** PUT `/products/{gtin}`
- **Content-Type:** `multipart/form-data`
- **成功時:** `/products`にリダイレクト

### 実装: 画像処理

```php
// 画像削除
if ($request->input('delete_image')) {
    if ($product->image_path) {
        @unlink(public_path($product->image_path));
    }
    $product->image_path = null;
}

// 新しい画像のアップロード
if ($request->hasFile('image')) {
    $ext = $request->file('image')->extension();
    $filename = $product->gtin . '.' . $ext;
    $request->file('image')->move(public_path('uploads/products'), $filename);
    $product->image_path = '/uploads/products/' . $filename;
}
```

## 認証・アクセス制御

### 保護対象ページ

| パス | 未認証時 |
|------|---------|
| `/companies*` | 401 Unauthorized |
| `/products*` | 401 Unauthorized |

### 公開ページ

| パス |
|------|
| `/login` |

### セッション管理

1. ログイン成功時にセッションを設定
2. 管理ページアクセス時にセッションを確認
3. 未認証の場合は401エラーを返す
