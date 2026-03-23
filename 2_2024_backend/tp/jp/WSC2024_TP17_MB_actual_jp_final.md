# テストプロジェクト モジュール B 商品管理

## *Web Technologies*

Independent Test Project Designer: Thomas Seng Hin Mak SCM
Independent Test Project Validator: Fong Hok Kin

# 目次

1. [はじめに](#はじめに)
2. [プロジェクトとタスクの説明](#プロジェクトとタスクの説明)

   1. [管理者アクセス](#管理者アクセス)
   2. [企業管理](#企業管理)
   3. [商品管理](#商品管理)
   4. [JSON API出力](#json-api出力)
   5. [JSON API出力例](#json-api出力例)
   6. [公開ページ](#公開ページ)

3. [競技者への指示](#競技者への指示)

   1. [データベースとモデル作成の考慮事項](#データベースとモデル作成の考慮事項)

4. [その他](#その他)

# はじめに

オフィスの管理者（「admin」とも呼ばれる）がフランス製商品を管理するための管理システムを作成する。商品は企業に属する。管理者は関連する企業データも管理する。管理者のみがこれらの企業と商品の一覧表示・編集を閲覧・管理できる。

各商品レコードには一意の識別番号があり、これをGlobal Trade Item Number（GTIN）と呼ぶ。背景情報として、GTINは国際組織GS1によって開発された。

一方、公開ページもある:

* 公開GTIN一括検証ページ
* 公開商品ページ

# プロジェクトとタスクの説明

このプロジェクトでは、管理者がフランス製商品を管理するための企業・商品管理システムを作成する。

レコードの一覧表示・編集のための管理Webページと、データの照会・閲覧のためのJSON APIを含む。

このプロジェクトは http://wsXX.worldskills.org/XX\_module\_b/ でアクセス可能であること。XXは座席番号。

## 管理者アクセス

管理者ログインページはパス `/XX_module_b/login` にある。ログインページでは認証のためにパスフレーズの入力を求める。パスフレーズ "admin" を使用して管理システムにアクセスできる。

3時間の作業によるプロトタイプ製品として、堅牢な認証は要求しない。管理システムはシンプルなパスフレーズベースのチェックを使用する。

タスクは企業・商品管理システムの作成である。

時間が限られているため、企業・商品記録管理のプロトタイプと、公開ページでの商品表示の概念実証に集中する。

ログインせずに商品の編集・管理機能にアクセスすると401エラーとなる。

## 企業管理

管理者のみが企業を一覧表示・管理できる。

管理者は企業一覧から特定の企業をクリックして表示できる。

各企業ページでは、管理者は関連する商品を表示できる。

管理者は新しい企業の作成や既存の企業情報の更新も可能。

各企業について保存・管理するデータは以下の通り:

* 企業名
* 企業住所
* 企業電話番号
* 企業メールアドレス
* オーナー情報:

  * オーナーの名前
  * オーナーの携帯電話番号
  * オーナーのメールアドレス

* 連絡先情報

  * 連絡先の名前
  * 連絡先の携帯電話番号
  * 連絡先のメールアドレス

### 企業の無効化

管理者は企業を無効化としてマークできる。

企業が無効化されると、関連するすべての商品が非表示としてマークされる。

無効化された企業を一覧表示する別のリストがあるべきである。

Webインターフェースから企業レコードを削除することはできない。

## 商品管理

各商品にはさまざまなフィールドがあり、特に注目すべきはGTINである。

このプロジェクトでは、GTINを13桁または14桁の任意の数字に簡略化する。各商品に対して一意であれば、任意の数字の並びでよい。フォーム送信後にこのGTINフォーマットをサーバーサイドバリデーションで検証すること。

### 商品一覧表示

管理者は商品を一覧表示・管理できるべきである。

管理者が /XX\_module\_b/products にアクセスすると、すべての商品の一覧が表示される。

管理者はリストから商品レコードをクリックするか、以下のパスにアクセスすることで特定の商品にアクセス・管理できる: /XX\_module\_b/products/\[GTIN\]。\[GTIN\]はGTINフィールドのプレースホルダーである。

例えば、GTINが3000123456789の商品がある場合、/XX\_module\_b/products/3000123456789 にアクセスすると、この商品の管理ページとなる。

### 商品の非表示と削除

管理者は商品を非表示としてマークできる。

または、関連する企業が無効化としてマークされると商品は非表示になる。

管理者は非表示の商品を完全に削除できる。

### 新規商品の作成

管理者は /products/new にアクセスして商品作成フォームを表示し、新規作成した商品をデータベースに保存できる。

商品は英語とフランス語の2言語の情報を持つ。

商品について保存するデータは以下の通り:

* 名前
* フランス語の名前
* GTIN（Global Trade Item Number）
* 説明（複数行のテキスト可）
* フランス語の説明
* 商品ブランド名
* 商品原産国
* 商品総重量（パッケージ込み）
* 商品正味内容量
* 商品重量単位

### 商品画像のアップロード

各商品に1つの画像を関連付けることができる。管理者はこの画像をアップロード・変更でき、アップロードした画像を削除することもできる。

画像がアップロードされていない場合は、デフォルトのプレースホルダー画像が表示される。

## JSON API出力

GET /XX\_module\_b/products.json にアクセスすると、データをJSON形式で出力できる。商品を一覧表示する際、APIはページネーション構造を表示する。

GET /XX\_module\_b/products/\[GTIN\].json で単一の商品をJSONで照会できる。GTINは動的である。

存在しない商品または非表示の商品にアクセスすると、商品APIは404ネットワークステータスを返す。

商品一覧JSONはキーワードによる照会が可能で、GET /XX\_module\_b/products.json?query=KEYWORD で照会できる。一覧には、名前、フランス語の名前、説明、またはフランス語の説明にKEYWORDを含む商品が表示される。

## JSON API出力例

企業出力の例

{

  "companyName": "Euro Expo",

  "companyAddress": " Boulevard de l'Europe, 69680 Chassieu, France",

  "companyTelephone": "+33 1 41 56 78 00",

  "companyEmail": "mail.customerservice.hdq@example.com",

  "owner": {

    "name": "Benjamin Smith",

    "mobileNumber": "+33 6 12 34 56 78",

    "email": "b.smith@example.com "

  },

  "contact": {

    "name": "Marie Dubois",

    "mobileNumber": "+33 6 98 76 54 32",

    "email": "m.dubois@example.com "

  }

}

商品出力の例

{

    "name": {

      "en": "Organic Apple Juice",

      "fr": "Jus de pomme biologique"

    },

    "description": {

      "en": "Our organic apple juice is pressed from 100% fresh organic apples, with no added sugars or preservatives. Rich in vitamin C and antioxidants, it's an ideal choice for your daily healthy diet.",

      "fr": "Notre jus de pomme biologique est pressé à partir de 100% de pommes biologiques fraîches, sans sucre ajouté ni conservateurs. Riche en vitamine C et en antioxydants, c'est le choix idéal pour votre alimentation quotidienne saine."

    },

    "gtin": "03000123456789",

    "brand": "Green Orchard",

    "countryOfOrigin": "France",

    "weight": {

      "gross": 1.1,

      "net": 1.0,

      "unit": "L"

    },

    "company": {

      "companyName": "Euro Expo",

      "companyAddress": " Boulevard de l'Europe, 69680 Chassieu, France",

      "companyTelephone": "+33 1 41 56 78 00",

      "companyEmail": "mail.customerservice.hdq@example.com",

      "owner": {

        "name": "Benjamin Smith",

        "mobileNumber": "+33 6 12 34 56 78",

        "email": "b.smith@example.com "

      },

      "contact": {

        "name": "Marie Dubois",

        "mobileNumber": "+33 6 98 76 54 32",

        "email": "m.dubois@example.com "

      }

    }

}

商品一覧JSONの例

{

  "data": \[

    {

      (単一商品JSONと同じ構造)

    },

    {

      (単一商品JSONと同じ構造)

    },

  \],

  "pagination": {

    "current\_page": 1,

    "total\_pages": 5,

    "per\_page": 10,

    "next\_page\_url": "http://wsXX.worldskills.org/XX\_module\_b/products.json?page=2",

    "prev\_page\_url": null

  }

}

## 公開ページ

公開ページは2つあり、GTIN一括検証ページと公開商品ページである。

### 公開GTIN一括検証ページ

指定されたGTIN番号が登録済みかつ有効であるかを一括で検証するページがある。任意のユーザーが複数のGTINコードを入力して送信し、検証結果を確認できる。

GTINはデータベースに存在し、非表示でない場合に有効である。

ページではテキストエリアを使用してユーザーがGTIN番号を一括入力できる。これらの番号は改行で区切られる。ページは各GTIN番号を検証し、各GTIN番号が有効かどうかの結果リストを表示する。

すべてのGTIN番号が有効な場合、結果ページの上部に、別途「All valid」のテキストと緑のチェックマークが表示される。

![A close-up of a paperDescription automatically generated][image1]

### 公開商品ページ

商品の公開ページは /XX\_module\_b/01/\[GTIN\] にアクセスすることで表示できる。"01"は固定値である。

公開商品ページには以下の必須フィールドが表示される。モバイルフレンドリーなレイアウトであること。

表示必須フィールド: 企業名、商品名、GTIN番号、商品説明、商品画像、単位付き重量、単位付き正味内容量。

ユーザーは公開商品ページで英語とフランス語を切り替えることができる。ページ、フランス語部分、英語部分のlang属性が正しく設定されていること。

![A close-up of a product descriptionDescription automatically generated][image2]

# 競技者への指示

## データベースとモデル作成の考慮事項

企業と商品のデータをデータベースに保存する。

商品の多言語情報の柔軟性を考慮すること。

データベースダンプを提供すること。データベースダンプにはFK制約と正しいカラムを含めること。カラムの型定義は妥当であること。

ERダイアグラムスキーマを提供すること。

データベースの正規形を考慮すること。

GTINフィールドにはインデックスを設定すること。

サンプルデータが提供されている。それらを使用し、評価を容易にするためにデータベースにデータを入れておくこと。

# その他

プロジェクトをサブフォルダや別のポートに配置してもよい。wsXX.worldskills.org/XX\_module\_b/ のパスから目的地にリダイレクトすること。

このドキュメントで言及されているパスはサブフォルダからの相対パスである場合がある。例えば、ログインページが /XX\_module\_b/login と記載されている場合、実際のセットアップによっては /XX\_module\_b/public/login や /XX\_module\_b/index.php/login、あるいは [http://wsXX.worldskills.org:3000/XX\_module\_b/login](http://wsXX.worldskills.org:3000/XX_module_b/login) のように別のポートになる場合がある。

実行ガイドを含む `expert_readme.txt` というファイルも提供すること。デフォルトの実行パスを使用する場合でもこのファイルは必ず提供すること。

NodeJSを使用する場合、Windows（ワークステーション上）とLinux（サーバー上）の node\_modules ファイルは異なることに注意すること。誤った node\_modules フォルダを使用すると予期しないエラーが発生する可能性がある。

このプロジェクトはFirefox Developer Edition Webブラウザを使用して評価される。

### 採点サマリー

|  | サブクライテリア | 配点 |
| :---- | :---- | :---- |
| 1 | 管理者 | 1.25 |
| 2 | データベース | 2.50 |
| 3 | 企業（管理者） | 4.25 |
| 4 | 商品CRUD（管理者） | 7.75 |
| 5 | 商品API | 4.50 |
| 6 | GTIN照会と検証 | 1.75 |
| 7 | 公開商品ページ | 1.50 |

[image1]: ../images/b_1.png

[image2]: ../images/b_2.png
