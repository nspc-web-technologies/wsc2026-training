# 実装チェックリスト

## 参照

- レビュー引き継ぎ: `review_handoff.md`
- 実装: `./app/`, `./routes/`, `./resources/views/`, `./database/migrations/`
- 課題: `../../tp/WSC2024_TP17_MB_actual_jp_final.md`
- 採点基準: `../../tp/WSC2024_TP17_MB_making_scheme.csv`
- 実装: `./implementation/src/`

## 方針

- セクションは依存関係順に並んでいる。マイグレーション → モデル → ルート → ミドルウェア → コントローラー → API → Blade
- 実装順序のヒント: 認証（ミドルウェア・AuthController）はルート定義時にコメントアウトしておき、他の機能が動いてから最後に有効化すると開発中のログイン手間を省ける
- ER 図 (`ER.png`) を確認しながらマイグレーションを書く

## 学習用コメント

コードを修正する時に、学習用のコメントとして、修正箇所の直上にコメントを追記する。

| タグ | 書く内容 |
|------|----------|
| `fix` | 修正前の挙動 → 何が問題か（仕様違反・ディスク不一致・null 上書き・主キー不整合）→ 修正後が正しい理由 |
| `add` | 何を追加したか → 採点基準・仕様のどの要件に対応するか → 修正前に何が欠けていたか |
| `remove` | 何を削除したか → なぜ不要か（無条件 null 代入・未使用 import・空メソッド） |
| `omit` | 何を省略したか → なぜ省略できるか（cascade で自動削除・デフォルト値で充足・Laravel が自動処理） |
| `tricky` | なぜ引っかかりやすいか → 一見別の書き方で良さそうだが動かない理由・知らないと詰まる罠 |
| `smart` | なぜ賢い書き方か → 知っていると作業量が減る・条件分岐や変数が不要になる理由 |

### 例

```php
// fix: store() では Storage::putFileAs() でディスク指定なしで保存していた
// → 現在の .env では FILESYSTEM_DISK=public のためたまたま動作するが、コード上で明示していない
// → update() と統一して storeAs('products', $filename, 'public') に変更
```

```php
// tricky: $primaryKey = 'gtin' を設定すると Eloquent は gtin をプライマリキーとして扱い、
// Route Model Binding も gtin で解決する。しかし DB の主キーは id のまま
// → 意図的なら $incrementing = false と $keyType = 'string' の両方が必要
// → 意図しないなら $primaryKey を削除して getRouteKeyName() で gtin を返す方が安全
```

## ステータス

- ✅ 実装済み・正しい: 129
- ☑️ バグ修正・機能追加済み: 15
- 🚧 実装したがバグあり（修正が必要）: 0
- ❌ 未実装（これから書く）: 0
- 👀 動作確認が必要（ブラウザで目視確認）: 10

## 実装手順・チェックリスト

- ✅ プロジェクト初期設定
  - ✅ `.env.example` を `.env` にコピーし、DB 接続情報を設定する
  - ✅ `.env` で `FILESYSTEM_DISK=public` を設定する（デフォルトのストレージディスクを public にする）
  - ✅ `php artisan key:generate` でアプリキーを生成する
  - ✅ `php artisan migrate` でテーブルを作成する
  - ✅ `php artisan storage:link` でシンボリックリンクを作成する（画像公開に必須）。`config/filesystems.php` の `links` が `17_module_b/storage → storage/app/public` にカスタマイズ済み
  - 👀 確認: `http://localhost:8082/17_module_b/login` でページが開く

- ✅ マイグレーション — `companies` テーブル
  - ✅ `id`, `company_name`(`string`)、`company_address`(`text`)、`company_telephone_number`(`string`)、`company_email_address`(`string`) を定義する
  - ✅ `owner_name`, `owner_mobile_number`, `owner_email_address` を定義する
  - ✅ `contact_name`, `contact_mobile_number`, `contact_email_address` を定義する
  - ✅ `is_active` を `boolean` + `default(true)` で定義する
  - ✅ `timestamps()` を定義する
  - ✅ companies マイグレーションのファイル名タイムスタンプが products より前であること（外部キー制約のため）

- ✅ マイグレーション — `products` テーブル
  - ✅ `id`, `gtin`（`string(14)` + `unique` + `index`）を定義する
  - ✅ `name`(`string`)、`name_in_french`(`string`)、`description`(`text`)、`description_in_french`(`text`) を定義する
  - ✅ `brand_name`, `country_of_origin` を定義する
  - ✅ `gross_weight_with_packaging`, `net_content_weight` を `decimal(10,3)` で定義する
  - ✅ `weight_unit` を `string(10)` で定義する
  - ✅ `image_path` を `string(512)->nullable()` で定義する
  - ✅ `is_hidden` を `boolean` + `default(false)` で定義する
  - ✅ `foreignId('company_id')->constrained('companies')->onDelete('cascade')` で外部キーを定義する
  - ✅ `timestamps()` を定義する

- ✅ モデル — `Company`
  - ✅ `$fillable` に全カラム（`is_active` 含む）を設定する
  - ✅ `products()` リレーション（`hasMany`）を定義する

- ✅ モデル — `Product`
  - ✅ `$fillable` に全カラム（`image_path`, `is_hidden`, `company_id` 含む）を設定する
  - ✅ `company()` リレーション（`belongsTo`）を定義する
  - ☑️ `$primaryKey = 'gtin'` を削除し `getRouteKeyName()` で gtin を返すように修正した

- ✅ ルート — `routes/web.php`
  - ✅ ログイン画面（GET `/login`）を認証不要で定義する — クロージャで `response()->view()` + `cache-control: no-store` ヘッダ
  - ✅ ログイン処理（POST `/login`）を `AuthController@login` に接続する
  - ✅ ログアウト処理（POST `/logout`）を `AuthController@logout` に接続する
  - ✅ 公開 API（GET `/products.json`, GET `/products/{product}.json`）を認証不要で定義する
  - ✅ 認証必須ルートを `middleware(AuthMiddleware::class)->group()` でまとめる
  - ☑️ 企業 CRUD ルートを定義する — `POST /companies/store` → `POST /companies`、`PUT /companies/{company}/deactivated` → `POST /companies/{company}/deactivate` に修正済み（Blade 側の `@method('PUT')` も削除）
  - ☑️ 商品 CRUD ルートを定義する — `POST /products/store` → `POST /products`、`PUT /products/{product}/hide` → `POST /products/{product}/hide` に修正済み（Blade 側の `@method('PUT')` も削除）
  - ☑️ ミドルウェアクラス名 typo `AuthMiddreware` → `AuthMiddleware` に修正済み（ファイル名・クラス名・use 文を一括修正）

- ✅ ミドルウェア — `AuthMiddleware`
  - ✅ セッションから `passphrase` を取得し `admin` と比較する
  - ✅ 不一致時は `abort(401)` を返す
  - ✅ 一致時は `$next($request)` で次の処理へ進める

- ✅ `AuthController`
  - ✅ `login()`: パスフレーズを `validate` し `admin` と比較、セッションに保存して `companies.index` にリダイレクト
  - ✅ `login()`: 不正時は `back()->withErrors()` でエラーメッセージを返す
  - ✅ `logout()`: セッションから `passphrase` を `forget` し、ログイン画面にリダイレクトする

- ✅ `CompanyController`
  - ✅ `index()`: `Company::where('is_active', true)->get()` でアクティブ企業のみ取得する
  - ✅ `deactivatedIndex()`: `Company::where('is_active', false)->get()` で無効企業のみ取得する
  - ✅ `create()`: 新規作成フォームを表示する
  - ✅ `store()`: バリデーション後に `Company::create()` で保存する
  - ✅ `show()`: Route Model Binding で企業を取得して詳細を表示する
  - ✅ `edit()`: Route Model Binding で企業を取得して編集フォームを表示する
  - ✅ `update()`: バリデーション後に `$company->update()` で更新する
  - ✅ `deactivate()`: `is_active` を `false` に更新し、紐づく商品の `is_hidden` を `true` に一括更新する
  - ✅ ビューを返す全メソッドに `header('cache-control', 'no-store')` を付与する（`store`, `update`, `deactivate` は redirect のため不要）
  - 👀 確認: 企業の一覧表示・新規作成・詳細表示・編集・無効化が正しく動作する
  - 👀 確認: 無効化時に紐づく商品が非表示になる

- ✅ `ProductController`
  - ☑️ `index()`: `Product::with('company')->get()` で Eager Loading に修正済み
  - ☑️ `create()`: `Company::where('is_active', true)->get()` でアクティブ企業のみ取得するよう修正済み
  - ☑️ `store()`: `$request->file('image')->storeAs('products', $filename, 'public')` で明示的に `public` ディスクを指定して `update()` と統一済み
  - ✅ `show()`: Route Model Binding で商品を取得して詳細を表示する
  - ☑️ `edit()`: `Company::where('is_active', true)->get()` でアクティブ企業のみ取得するよう修正済み
  - ☑️ `update()`: `$validated['image_path'] = null` を `else` ブロックに移動し、新画像がある場合はパスを保持、ない場合は null にする修正済み
  - ✅ `hide()`: `is_hidden` を `true` に更新する
  - ✅ `destroy()`: 画像があれば `Storage::disk('public')->delete()` で削除し、`$product->delete()` する
  - ✅ ビューを返す全メソッドに `header('cache-control', 'no-store')` を付与する（`store`, `update`, `hide`, `destroy` は redirect のため不要）
  - 👀 確認: 商品の一覧表示・新規作成・詳細表示・編集・非表示・削除が正しく動作する
  - 👀 確認: 画像アップロードが `storage/app/public/products/` に保存される
  - 👀 確認: 画像更新時に新画像のパスが正しく保存される（else ブロックで null 設定）

- ✅ `ProductApiController`
  - ☑️ `index()`: `when()` クロージャ内を `where(function($q2) { ... })` でグループ化し、`is_hidden` フィルタが外れないよう修正済み
  - ✅ `index()`: `with('company')` で Eager Loading し N+1 問題を回避する
  - ✅ `index()`: `paginate(10)` でページネーション、レスポンスに `pagination` 情報を含める
  - ✅ `index()`: DB カラム名から外部向け JSON 形式に変換する（`name.en/fr`, `description.en/fr`, `weight.gross/net/unit`, `company` ネスト）
  - ☑️ `show()`: `is_hidden` が `true` の場合は `abort(404)` を返すガードを追加済み
  - ☑️ `show()`: レスポンスから `data` ラップを除去し、設計通り直接オブジェクトを返すよう修正済み
  - ✅ `index()` と `show()` で同じレスポンス整形ロジックが重複している（競技用として許容。実務では private メソッドに切り出す）
  - 👀 確認: `/products.json` で公開商品のみ JSON で返る
  - 👀 確認: `/products/{gtin}.json` で単一商品の JSON が返る
  - 👀 確認: `?query=xxx` で検索フィルタが動作し、かつ非表示商品が混入しない
  - 👀 確認: 非表示商品が API に含まれない

- ✅ Blade — `layouts/app.blade.php`
  - ✅ `@yield('body')` でコンテンツを差し込む
  - ✅ `session('message')` でフラッシュメッセージを表示する（コントローラー側で `with('message', ...)` を使えば表示される。現在どのコントローラーも設定していないが、仕組みとしては正しい）

- ✅ Blade — `auth/login.blade.php`
  - ✅ `@extends('layouts.app')` でレイアウトを継承する
  - ✅ パスフレーズ入力フォーム（`type="password"`）を配置する
  - ✅ `@csrf` を付与する
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `companies/index.blade.php`
  - ✅ ログアウト・商品一覧・新規作成・無効企業リストへのナビゲーションボタンを配置する
  - ✅ `@foreach` で企業一覧をテーブル表示する
  - ✅ 企業名に詳細ページへのリンクを付ける
  - ✅ 各行に編集ボタン・無効化ボタンを配置する
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `companies/create.blade.php`
  - ✅ 全フィールドの入力フォームを配置する
  - ✅ `old()` で入力値を復元する
  - ✅ `@csrf` を付与する
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `companies/edit.blade.php`
  - ✅ 全フィールドの入力フォームを配置する（既存値をセット）
  - ✅ `old('field', $company->field)` で入力値を復元する（第2引数に既存値）
  - ✅ `@csrf` と `@method('put')` を付与する
  - ☑️ `contact_email_address` のラベル typo「連絡先名」→「連絡先メールアドレス」に修正済み
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `companies/show.blade.php`
  - ✅ 戻るボタンで企業一覧に遷移する
  - ✅ 企業情報をテーブルで表示する
  - ☑️ 関連製品（`$company->products`）を一覧表示する — 各製品の GTIN・名前に詳細ページへのリンクを追加済み
  - ✅ 画像がある場合は `Storage::disk('public')->url()` でリンクを表示、ない場合は placeholder を表示する
  - ✅ 編集・無効化ボタンを配置する（`window.confirm` は不要）
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `companies/deactivated.blade.php`
  - ✅ 戻るボタンで企業一覧に遷移する
  - ✅ 無効企業をテーブルで一覧表示する
  - ✅ 企業名に詳細ページへのリンクを付ける
  - ✅ 各行に編集ボタンを配置する
  - ☑️ `contact_email_address` のヘッダー typo「連絡先名」→「連絡先メールアドレス」に修正済み
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `products/index.blade.php`
  - ✅ 企業一覧・新規作成へのナビゲーションボタンを配置する
  - ✅ `@foreach` で商品一覧をテーブル表示する
  - ✅ 商品名に詳細ページへのリンクを付ける（`$product->gtin` でルーティング）
  - ✅ 画像の有無で表示を切り替える（`Storage::disk('public')->url()` / placeholder）
  - ✅ `$product->company->company_name` でリレーション経由の企業名を表示する
  - ✅ 各行に編集ボタンを配置する
  - ✅ `is_hidden` の状態で削除ボタン（`@method('DELETE')`）と非表示ボタン（POST）を切り替える
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `products/create.blade.php`
  - ✅ 全フィールドの入力フォームを配置する
  - ✅ `enctype="multipart/form-data"` を設定する（画像アップロードに必須）
  - ✅ 企業選択の `<select>` を `@foreach` で描画する
  - ✅ `old()` で入力値を復元する
  - ✅ `@csrf` を付与する
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `products/edit.blade.php`
  - ✅ 全フィールドの入力フォームを配置する
  - ✅ `enctype="multipart/form-data"` を設定する
  - ✅ 企業選択の `<select>` で `old('company_id', $product->company_id)` と比較して `selected` を付与する
  - ✅ `@csrf` と `@method('PUT')` を付与する
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

- ✅ Blade — `products/show.blade.php`
  - ✅ 戻るボタンで商品一覧に遷移する
  - ✅ 商品情報をテーブルで表示する
  - ✅ 画像の有無で表示を切り替える
  - ✅ `$product->company->company_name` でリレーション経由の企業名を表示する
  - ✅ 編集ボタン・削除/非表示ボタンを `is_hidden` の状態で切り替える
  - ✅ 削除/非表示ボタンを配置する（`window.confirm` は不要）
  - ✅ `@if ($errors->any())` でエラーメッセージを表示する

## 忘れやすいポイント

| 箇所 | 内容 |
|------|------|
| マイグレーション順序 | Company を先に作らないと Product の外部キーが失敗する |
| `enctype="multipart/form-data"` | 画像アップロードフォームに必須 |
| `@csrf` と `@method('PUT')` | Blade 作成時に必ず確認 |
| `cache-control: no-store` | ビューを返す全メソッドに付与（ログアウト後に戻るボタンで画面が見えるのを防止。redirect には不要） |
| `storage:link` | 画像公開に必須、忘れやすい |
| ディスクの統一 | `store()` と `update()` で同じ `public` ディスクを明示的に指定する。`.env` の `FILESYSTEM_DISK` 任せにしない |
| `$primaryKey` と DB 主キー | モデルの設定と DB の実際の主キーを一致させる |
| `catch` の `dd($th)` | デバッグ中はコメントアウトを外す。本番では `dd()` を消すか `Log::error()` に置換 |
| `orWhere` のスコープ | `where()->orWhere()` は OR がトップレベルに昇格する。検索条件はネストした `where(function($q) { ... })` で囲む |
| カラム長 | companies の `telephone_number`/`mobile_number` 系は `string(50)`、`company_email_address` は `string(50)`、`owner_email_address`/`contact_email_address` は `string(255)`、`address` は `text`。products の `gtin` は `string(14)`。ER 図と照合する |
