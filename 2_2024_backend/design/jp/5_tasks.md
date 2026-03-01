# 実装タスク - WSC2024 モジュールB

## 1. プロジェクトセットアップ

- [ ] Laravelプロジェクトを作成
- [ ] 不要なファイルを削除
- [ ] .envを設定

## 2. データベース

- [ ] companiesマイグレーションを作成
- [ ] productsマイグレーションを作成
- [ ] マイグレーションを実行
- [ ] Companyモデルを作成
  - [ ] fillableを設定
  - [ ] castsを設定
  - [ ] リレーションを定義
- [ ] Productモデルを作成
  - [ ] fillableを設定
  - [ ] castsを設定
  - [ ] リレーションを定義
- [ ] CompanySeederを作成
- [ ] ProductSeederを作成
- [ ] schema.sqlをエクスポート

## 3. 認証

- [ ] AdminAuthミドルウェアを作成
- [ ] Kernel.phpにミドルウェアを登録
- [ ] AuthControllerを作成
  - [ ] showLogin()
  - [ ] login()
- [ ] login.blade.phpを作成
- [ ] ルートを定義

## 4. 企業管理

- [ ] CompanyControllerを作成
  - [ ] index()
  - [ ] deactivated()
  - [ ] create()
  - [ ] store()
  - [ ] show()
  - [ ] edit()
  - [ ] update()
  - [ ] deactivate()
    - [ ] 関連製品を非表示にする
- [ ] companies/index.blade.phpを作成
- [ ] companies/deactivated.blade.phpを作成
- [ ] companies/show.blade.phpを作成
  - [ ] 関連製品一覧
  - [ ] 無効化ボタン（window.confirm）
- [ ] companies/create.blade.phpを作成
- [ ] companies/edit.blade.phpを作成
- [ ] ルートを定義

## 5. 製品管理

- [ ] ProductControllerを作成
  - [ ] index()
  - [ ] create()
  - [ ] store()
    - [ ] 画像アップロード処理
    - [ ] 画像なしの場合はプレースホルダーを設定
    - [ ] GTINバリデーション（13-14桁）
  - [ ] show()
  - [ ] edit()
  - [ ] update()
    - [ ] 画像アップロード処理
    - [ ] 画像削除時にプレースホルダーを設定
  - [ ] hide()
  - [ ] destroy()
    - [ ] 画像ファイルを削除
- [ ] products/index.blade.phpを作成
- [ ] products/show.blade.phpを作成
  - [ ] 非表示ボタン（is_hidden=falseの場合、window.confirm）
  - [ ] 削除ボタン（is_hidden=trueの場合、window.confirm）
- [ ] products/create.blade.phpを作成
- [ ] products/edit.blade.phpを作成
- [ ] ルートを定義
- [ ] プレースホルダー画像を配置

## 6. 製品API

- [ ] ProductApiControllerを作成
  - [ ] index()
    - [ ] ページネーション
    - [ ] キーワード検索（OR検索）
  - [ ] show()
    - [ ] 404ハンドリング
- [ ] ルートを定義

## 7. 共通

- [ ] layouts/app.blade.phpを作成
- [ ] uploads/productsディレクトリを作成
- [ ] expert_readme.txtを作成
