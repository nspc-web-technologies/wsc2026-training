# Test Project  Module B Products Management

## *Web Technologies*

Independent Test Project Designer: Thomas Seng Hin Mak SCM  
Independent Test Project Validator: Fong Hok Kin

# **Contents**

1. [**Introduction	3**](#introduction)  
> 2. [**Description of project and tasks	3**](#各製品レコードには、一意の識別番号があります。これをグローバル商品番号\(gtin\)と呼びます。背景情報として、gtinはgs1という国際機関によって開発されたものです。)

   1. [Admin access	3](#admin-access)  
   2. [Managing Companies	3](#managing-companies)  
   > 3. [Managing Products	4](#企業の無効化)  
   > 4. [JSON API Outputs	5](#製品画像のアップロード)  
   > 5. [JSON API Example Outputs	6](#get-/xx_module_b/products.jsonにアクセスすると、データがjson形式で出力されます。製品一覧表示の際には、apiはページネーション構造を示します。)  
   6. [Public-facing Pages	7](#public-facing-pages)

3. [**Instructions to the Competitor	9**](#heading)

   1. [Database and model creation consideration	9](#database-and-model-creation-consideration)

> 4. [**Other	9**](#データベースとモデルの作成について)

# **Introduction**  {#introduction}

We are going to create a management system for an office administrator (as known as "admin") to manage some made-in-France products. Products belongs to companies. The administrator will also manage the associated company data as well. Only admin can view and manage these companies and products listing and editing views.

> 私たちは、いくつかのフランス製の製品を管理するために、オフィス管理者(「admin」とも呼ばれる)のための管理システムを作成します。製品は企業に属しています。管理者は関連する企業データの管理も行います。管理者のみが、これらの企業と製品の一覧と編集ビューを表示および管理できます。

Each product record comes with a unique identifier number, we call it Global Trade Item Number (GTIN). As a background information, the GTIN is developed by the international organization GS1.

On the other hand, there are public-facing pages. They are:

* Public GTIN bulk verification page  
* Public Product page

> 各製品レコードには、一意の識別番号があります。これをグローバル商品番号(GTIN)と呼びます。背景情報として、GTINはGS1という国際機関によって開発されたものです。

> 一方で、一般公開ページもあります。それらは以下の通りです:

> * 一般向けGTIN一括検証ページ

> * 一般向け製品ページ

# **Description of project and tasks**

In this project, we create a companies and products management system for an admin to manage these made-in-France products.

It contains management web pages for listing and editing the records. And JSON API for querying and reading the data as well.

This project should be reachable at http://wsXX.worldskills.org/XX\_module\_b/, where XX is the seat number.

> このプロジェクトでは、管理者がフランス製の製品を管理できる企業及び製品管理システムを作成します。

> それには、記録の一覧表示と編集用の管理ウェブページと、データの照会と読み取りのためのJSON APIが含まれています。

> このプロジェクトは、http://wsXX.worldskills.org/XX\_*module\_*b/で公開されるべきです。ここで、XXは座席番号です。

## ****Admin access** {#admin-access}** **[1.25点]**

Admin login page is at path \`/XX\_module\_b/login\`. The login page asks for a passphrase to proceed the authentication. A passphrase "admin" can be used to access the admin management system.

As a prototype product for a 3 hours' work. We do not require robust authentication. The management system uses simple passphrase-based checking.

The task is to create a companies and products management system. 

Given that the time constant, we focus on the prototype of the companies and products recording management and the proof-of-concept of displaying the product in a public page.

Accessing product editing and management functions without login results in 401 error.

> ## **管理者アクセス** 

> 管理者ログインページは、/XX\_*module\_*b/loginのパスにあります。ログインページでは、認証を進めるためにパスフレーズの入力を求めます。パスフレーズ「admin」を使用して、管理システムにアクセスできます。

> 3時間の作業のためのプロトタイプ製品として、堅牢な認証は必要ありません。管理システムは、単純なパスフレーズベースのチェックを使用します。

> この課題は、企業と製品の管理システムを作ることです。

> 時間が限られているため、企業と商品の記録管理のプロトタイプと、商品を公開ページに表示する概念の実証に焦点を当てます。

> ログインせずに商品編集・管理機能にアクセスすると401エラーになります。

## ****Managing Companies** {#managing-companies}** **[4.25点]**

Only admin can list and manage the companies. 

Admin can click and view a particular company from the companies list.

In each company page, admin can view the associated products.

Admin can also create new companies or update existing companies’ information.

> ## **企業の管理** 

> 管理者のみが、企業の一覧表示と管理を行えます。

> 管理者は、企業一覧から特定の企業をクリックして表示できます。

> 各企業ページでは、管理者は関連する製品を表示できます。

> 管理者は、新しい企業の作成や既存企業の情報更新も行えます。

Here are the data we would like to store and manage for each company:

* company name  
* company address  
* company telephone number  
* company email address  
* owner information:

  * owner's name  
  * owner's mobile number  
  * owner's email address

* contact information

  * contact's name  
  * contact's mobile number  
  * contact's email address

> 保存及び管理したい企業の情報は以下の通りです:

> * 企業名

> * 企業の住所

> * 企業の電話番号

> * 企業のメールアドレス

> * 所有者情報

  > * 所有者の名前

  > * 所有者の携帯番号

  > * 所有者のメールアドレス

> * 連絡先情報

  > * 連絡先の名前

  > * 連絡先の携帯番号

  > * 連絡先のメールアドレス

### **Deactivating companies**

Admin can mark a company as deactivated.

When a company is deactivated, all the associated products are marked as hidden.

There should be a separated list for listing deactivated companies.

No one should be able to delete any company records from the web interface.

> **企業の無効化**

> 管理者は、企業を無効化できます。

> 企業が無効化されると、関連する全ての製品が非表示になります。 

> 無効化された企業を一覧表示するため、別のリストが必要です。

> ウェブインターフェイスからは、誰も企業記録を削除できません。

## ****Managing Products**** **[7.75点]**

There are different fields in each product, one worth remark is the GTIN. 

In this project, we simplify the GTIN to be any number with 13 or 14 digits. It could be any sequence of number, as long as they are unique for each product. Please validate this GTIN format after form submissions, via server-side validation.

> ## **製品の管理** 

> 各製品には様々なフィールドがありますが、GTINは特に重要です。

> このプロジェクトでは、GTINを13桁または14桁の数字として簡略化します。任意の数字の並びでかまいませんが、各製品に対して一意である必要があります。フォーム送信後、サーバー側でこのGTIN形式を検証してください。

### **Listing products**

Admin should be able to list and manage products.

When admin access the /XX\_module\_b/products, admin can see the list of all products. 

Admin can access and manage a particular product by clicking on the product record from the list, or by accessing the following path: /XX\_module\_b/products/\[GTIN\]. \[GTIN\] is the placeholder of the GTIN field. 

For example, given a product with GTIN 3000123456789, accessing the /XX\_module\_b/products/3000123456789 will be the product management page for this given product. 

> **製品の一覧表示**

> 管理者は、製品の一覧表示と管理ができます。

> 管理者が、/XX\_module\_b/productsにアクセスすると、全ての製品の一覧が表示されます。 

> 管理者は、一覧から製品記録をクリックするか、/XX\_module\_b/products/\[GTIN\]にアクセスすることで、特定の製品にアクセスして管理できます。\[GTIN\]は、GTINフィールドのプレースホルダーです。 

> 例えば、GTIN が 3000123456789 の製品の場合、/XX\_module\_b/products/3000123456789 にアクセスすると、その製品の製品管理ページが表示されます。

### **Hiding and deleting products**

Admin can mark products as hidden.

Or a product becomes hidden when the associated company is marked as deactivated.

Admin can permanently delete hidden products.

> **製品の非表示と削除** 

> 管理者は、製品を非表示にできます。 

> また、関連企業が無効化された場合、製品も非表示になります。 

> 非表示の製品は、管理者が完全に削除できます。

### **Creating new products**

Admin can view the create product form by accessing the /products/new, and can save newly created products to database.

Products has two languages of information, English and French.

> **新製品の作成**

> 管理者は、/products/newにアクセスして、作成製品フォームを表示し、新たに作られた製品をデータベースに保存できます。 

> 製品には、英語とフランス語の2つの言語情報があります。

For products, we have the following data to store:

* name  
* name in French  
* GTIN (Global Trade Item Number)  
* description, can be multiple lines of text.  
* description in French  
* product brand name  
* product country of origin  
* product gross weight (with packaging)  
* product net content weight  
* product weight unit

> 製品に対して保存する情報は、以下の通りです:

> * 名称

> * フランス語の名称

* GTIN(Global Trade Item Number)

> * 説明(複数行のテキストでも可)

> * フランス語の説明

> * 製品ブランド名

> * 製品原産国

> * 製品総重量(包装込み)

> * 製品純重量

> * 製品重量の単位

### **Product Images Uploading**

There could be one image associated to each product. Admin can upload and change this image, or admin can remove the uploaded images. 

When no image is uploaded, there is a default placeholder image.

> **製品画像のアップロード**

> 各製品に1つの画像を関連付けられます。管理者は、この画像をアップロードしたり変更したり、アップロードされた画像を削除できます。 

> 画像がアップロードされていない場合は、デフォルトのプレースホルダー画像が表示されます。

## ****JSON API Outputs**** **[4.50点]**

The data can be output as JSON format when accessing GET /XX\_module\_b/products.json. When listing the products, the API will show a pagination structure.

A single product can be queried via JSON by GET /XX\_module\_b/products/\[GTIN\].json, where the GTIN is dynamic.

The product API returns 404 network status when accessing a non-exist product, or a hidden product.

The products list JSON allows querying by using keyword, by GET /XX\_module\_b/products.json?query=KEYWORD. The list should show products with name, or name in French, or description, or description in French, that contains the KEYWORD.

> ## **JSON API 出力** 

> GET /XX\_module\_b/products.jsonにアクセスすると、データがJSON形式で出力されます。製品一覧表示の際には、APIはページネーション構造を示します。

> 単一の製品は、GTINが動的であるGET /XX\_module\_b/products/\[GTIN\].jsonでJSONで照会することができます。

> 製品APIは、存在しない製品または非表示の製品にアクセスした場合、404ネットワークステータスを返します。

> 製品一覧のJSONでは、GET /XX\_module\_b/products.json?query=KEYWORDでキーワード検索ができます。一覧は、名称、フランス語名称、説明、フランス語説明のいずれかにKEYWORDが含まれる製品が表示されます。

> JSON API Example Outputs　JSON API 出力例

> Example company output　企業出力例

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

> Example product output　製品出力例

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

> **Example Products JSON　製品JSONの例**

{

  "data": \[

    {

      (Same as single product JSON structure)

    },

    {

      (Same as single product JSON structure)

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

## ****Public-facing Pages** {#public-facing-pages}** **[1.50点]**

There are two public facing pages, they are GTIN bulk verification page, and public product page.

> **一般公開ページ**

> 一般向けのページが2つあります。GTIN一括検証ページと、一般向け製品ページです。

### **Public GTIN bulk verification page**

There is a page for bulk validating if given GTIN numbers are registered and valid. Any user can input multiple GTIN codes and submit to see the validation result.

A GTIN is valid when it exists in the database and is not hidden.

The page uses a text area to allow user to bulk inputting GTIN numbers. These numbers are separated by line breaks. Then the page should check each GTIN number and display a list of results, showing if each GTIN number is valid.

If all the given GTIN numbers are valid, a separated "All valid" text and green tick is displayed on the top of the result page.

> ### **一般向けGTIN一括検証ページ**

> 指定したGTIN番号が登録されていて有効であれば、一括検証ページがあります。ユーザーは複数のGTINコードを入力して送信し、検証結果を確認できます。

> GTINが有効であるのは、データベースに存在し、かつ非表示になっていない場合です。

> このページでは、テキストエリアを使用して、ユーザーが複数のGTIN番号を入力できるようにしています。この番号は、改行で区切られています。そして、このページは、入力された各GTIN番号を1つずつ確認し、各GTIN番号が有効な場合には、結果を一覧表示します。

> 全ての指定したGTIN番号が有効な場合は、結果ページの上部に別の"All valid"のテキストと緑のチェックマークが表示されます。

![A close-up of a paperDescription automatically generated][image1]

### **Public Product Page**

A product's public page can be reached by accessing the /XX\_module\_b/01/\[GTIN\]. Where the "01" is static.

The public product page shows the following required field. And is in mobile-friendly layout.

The required field to display: company name, product name, GTIN number, product description, product image, weight with unit, net content weight with unit.

User can choose between English and French for the public product page The lang attribute for the page, French part and English part is correctly configured.

> ### **一般向け製品ページ**

> 製品の一般向けページは、/XX\_module\_b/01/\[GTIN\]にアクセスすることで表示できます。ここで、"01"は固定値です。

> 一般向け製品ページには、以下の必須情報が表示されます。モバイル対応のレイアウトになっています。

> 必須表示項目: 企業名、製品名、GTIN番号、製品説明、製品画像、重量と単位、純重量と単位

> ユーザーは、英語とフランス語のどちらかを選択できます。ページ全体、フランス語部分と英語部分のlang属性が正しく設定されています。

![A close-up of a product descriptionDescription automatically generated][image2]

# **Instructions to the Competitor**

## ****Database and model creation consideration** {#database-and-model-creation-consideration}** **[2.25点]**

We would like to store the companies and products data in database.

Please consider the flexibility of multi-lingual information for products.

Please provide the database dump. The database dump should contain FK-constraints and correct columns. The columns type definition shall be reasonable.

Please provide the ER diagram schema.

Please consider the normal form of database.

The GTIN field should be indexed.

Some sample data has been provided. Please use them and have some data in database for easier assessment.

> ### **データベースとモデルの作成について**  {#データベースとモデルの作成について}

> 企業と製品のデータをデータベースに保存したいと思っています。

> 製品の多言語情報の柔軟性を考慮してください。

> データベースのダンプを提供してください。データベースダンプには、FK制約と適切な列が含まれている必要があります。列の型定義も合理的なものでなければなりません。

> ERダイアグラムのスキーマも提供してください。

> データベースの正規化も考慮してください。

> GTINフィールドにはインデックスを付けてください。

> サンプルデータを提供しましたので、それらを使用し、評価しやすいようにデータベースに一定量のデータを入れてください。

# **Other**

You may put your project in a sub-folder or different port. Please redirect to your destination from the path wsXX.worldskills.org/XX\_module\_b/

The path mentioned in this document may be relative to your sub-folder. For example, when mentioning the login page as /XX\_module\_b/login — dependent to your actual setup — it may be actually /XX\_module\_b/public/login, or /XX\_module\_b/index.php/login or at different port such as [http://wsXX.worldskills.org:3000/XX\_module\_b/login](http://wsXX.worldskills.org:3000/XX_module_b/login).

> サブフォルダや別のポートにプロジェクトを置いても構いません。wsXX.worldskills.org/XX\_module\_b/から行き先にリダイレクトしてください。

> このドキュメントで言及しているパスは、サブフォルダの相対パスになる可能性があります。例えば、実際のセットアップに応じて、ログインページが/XX\_module\_b/loginと記述されていても、実際には/XX\_module\_b/public/loginや/XX\_module\_b/index.php/loginになる、あるいは別のポート、例えばhttp://wsXX.worldskills.org:3000/XX\_module\_b/loginになる可能性があります。

Please also provide a file named \`expert\_readme.txt\` to include executing guide. You must provide this file even if you use the default executing path.

Note if you are using NodeJS, please be aware of the node\_modules files for Windows (on workstation) and Linux (on server) is different. Using a wrong node\_modules folder may result in unexpected error.

This project will be assessed by using Firefox Developer Edition web browser.

> さらに、expert\_readme.txtというファイルを提供し、実行ガイドを含めてください。このファイルは、デフォルト実行パスを使う場合にあっても、必ず提供する必要があります。

> NodeJSを使用する場合、Windows(ワークステーション)とLinux(サーバー)のnode\_modulesファイルが異なることに注意してください。間違ったnode\_modulesフォルダを使用すると、予期せぬエラーが発生する可能性があります。

> このプロジェクトは、Firefox Developer Editionウェブブラウザを使用して評価されます。

### **Marking Summary**

|  | Sub-Criteria | Marks |
| :---- | :---- | :---- |
| 1 | Admin | 1.25 |
| 2 | Database | 2.50 |
| 3 | Companies (Admin) | 4.25 |
| 4 | Products CRUD (Admin) | 7.75 |
| 5 | Products API | 4.50 |
| 6 | GTIN Query and Verification | 1.75 |
| 7 | Public facing product page | 1.50 |

[image1]: images/b_1.png

[image2]: images/b_2.png
---

## **採点基準サマリー - Module B**

**総合点数: 23.50点**

### **セクション別配点**

- **B1: 管理者** - 1.25点
- **B2: データベース** - 2.25点
- **B3: 企業（管理者）** - 4.25点
- **B4: 製品CRUD（管理者）** - 7.75点
- **B5: 製品API** - 4.50点
- **B6: GTINクエリーと検証** - 1.75点
- **B7: 一般向け製品ページ** - 1.50点

