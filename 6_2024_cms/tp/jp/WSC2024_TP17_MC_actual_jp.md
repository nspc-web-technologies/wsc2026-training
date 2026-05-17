# テストプロジェクト Module C: Lyon 遺産サイト

Web Technologies

Independent Test Project Designer: Thomas Seng Hin Mak SCM
Independent Test Project Validator: Fong Hok Kin

## 目次

- [はじめに](#はじめに)
- [プロジェクトとタスクの説明](#プロジェクトとタスクの説明)
  - [URL Route とマッピング](#url-route-とマッピング)
  - [ファイル名の規則](#ファイル名の規則)
  - [コンテンツの一覧表示](#コンテンツの一覧表示)
    - [コンテンツ一覧の並び順](#コンテンツ一覧の並び順)
  - [コンテンツページへのアクセス](#コンテンツページへのアクセス)
    - [Front-matter](#front-matter)
  - [遺産サイト Web ページのレンダリング](#遺産サイト-web-ページのレンダリング)
    - [Cover Image](#cover-image)
    - [Cover Image のスタイリング](#cover-image-のスタイリング)
    - [Title の抽出について](#title-の抽出について)
    - [Title セクションのスタイリング](#title-セクションのスタイリング)
    - [Aside 情報](#aside-情報)
    - [Main Content のレンダリング](#main-content-のレンダリング)
  - [Tags](#tags)
    - [検索](#検索)
- [競技者への指示](#競技者への指示)
  - [採点サマリー](#採点サマリー)

## はじめに

Lyon へようこそ。この活気ある都市は、その歴史的重要性と建築美で知られています。このプロジェクトでは、いくつかの editors が France の Lyon にある注目すべき遺産サイトを紹介する記事を書きました。各記事は `.html` または `.txt` 形式で書かれており、メタ情報のための front-matter が各記事の冒頭に埋め込まれています。これらのファイルは `content-pages` と呼ばれる folder に保存されています。一部の記事ファイルは sub-folder、または nested sub-folder に保存されている場合があります。

`content-pages` folder の下には1つの `images` folder があります。これらの記事で言及されているすべての image path はこの images folder からの相対パスです。つまり、nested sub-folder の中に images folder はありません。sub-folder 内の記事で image 名を参照する場合、それらの image はすべて `content-pages` folder 直下の images folder を参照します。

あなたはこれらの記事をホストする website を作成するよう求められています。各記事は「page」となり、以降の document ではそのように呼びます。現在の記事執筆 workflow を維持するため、`content-pages` folder の既存の構造は変更しないままにします。

このモジュールでは、これらのファイルと sub-folder を一覧表示してロードするサイトを作成します。サイトは `content-pages` folder からこれらの static ファイルを読み取り、コンテンツを web page として表示します。page のファイル名の規則は `YYYY-MM-DD-title.txt` または `YYYY-MM-DD-title.html` です。

website には `http://wsXX.worldskills.org/XX_module_C/` でアクセスできます。

XX はあなたの座席番号です。

## プロジェクトとタスクの説明

このプロジェクトでは database を使用する必要はありません。コンテンツは `content-pages` folder、またはその中の sub-folder に保存されています。誰でも home page および遺産サイトの page にアクセスできます。home page にアクセスすると、すべての page と sub-folder の一覧が表示される必要があります。

### URL Route とマッピング

コンテンツ folder、page、および tags のクエリを一覧表示するための URL route の定義があります。

各 page または sub-folder への URL は以下のように定義されます。XX はあなたの座席番号です。

- `/XX_module_c/` は index listing を表示します。
- `/XX_module_c/heritages/2024-09-01-example-page` は `2024-09-01-example-page.html` または `2024-09-01-example-page.txt` の page を表示します。
- `/XX_module_c/heritages/sub-folder-name` は特定の sub-folder の page と folder を一覧表示します。
- `/XX_module_c/heritages/sub-folder-name/2024-09-10-welcome-to-lyon` は `sub-folder-name` folder 内の `2024-09-10-welcome-to-lyon.html` または `2024-09-10-welcome-to-lyon.txt` の page を表示します。
- `/XX_module_c/heritages/sub-folder-1/sub-folder-2/2024-09-10-welcome-to-lyon` は `sub-folder-1/sub-folder-2/` folder 内の `2024-09-10-welcome-to-lyon.html` または `2024-09-10-welcome-to-lyon.txt` の page を表示します。

tags クエリの URL は以下のように定義されます。

- `/XX_module_c/tags/tag-name-here` は指定された tag `tag-name-here` を含むすべての page を一覧表示します。

注意: 上記のパスは `http://wsXX.worldskills.org` からの相対パスです。

### ファイル名の規則

ファイル名には日付と slug 形式の title が含まれます。`YYYY-MM-DD-title-in-lower-case-with-hyphens.html` または `.txt` です。

ファイル名の最初の部分は `YYYY-MM-DD` 形式で、YYYY は4桁の年、MM は2桁の月、DD は2桁の日です。

ファイル名の2番目の部分はファイルの title を slug 形式にしたものです。すなわち、title を小文字にしてすべてのスペースをハイフンに置き換えたものです。

サンプルファイル名を以下に示します。

- `2024-09-01-example-page.html`
- `2024-10-20-greatest-lyon-heritage-site.html`
- `2025-01-01-a-post-for-future-posting.txt`

### コンテンツの一覧表示

コンテンツを一覧表示する際、リストには title と summary が表示されます。title または summary のいずれかをクリックすると、その単一のコンテンツにリンクします。

一覧には未来の page（日付が今日より後の page）を表示してはなりません。

一覧には draft 状態の page（ファイルの front-matter で `draft` が `"true"` に定義されている page）も表示してはなりません。

一覧は日付が定義されていない page も非表示にする必要があります。すなわち、最初の11文字が `YYYY-MM-DD-` の形式でない場合です。

page に加えて、一覧には sub-folder も表示してリンクします。sub-folder 名をクリックすると、web はその sub-folder 内のコンテンツ（その sub-folder 内の page と sub-folder）を一覧表示します。

#### コンテンツ一覧の並び順

一覧では最初に sub-folder を表示し、次に content page を表示します。sub-folder はアルファベット順に並べられます。content page は逆アルファベット順に並べられます。これにより、最新の page が上部に、最古の page が下部に表示されます。

### コンテンツページへのアクセス

`content-pages` folder 内の各ファイルには1つの遺産コンテンツが含まれています。cover image へのパス、tags、summary が含まれており、title が含まれている場合もあります。

各ファイルには2つの部分があります：Front-matter とメインコンテンツです。

front-matter はオプションです。front-matter がある場合は、front-matter セクションの先頭と末尾が `---` で示されます。

以下は front-matter が埋め込まれた `.html` 拡張子のコンテンツの例です。

```
---
title: This is an Example Page
tags: example, test
cover: example-cover.jpeg
summary: This is a sample summary.
---
<h1>Example Page</h1>
<p>Here is the rest of the content.</p>
<p>And some other paragraph.</p>
<img src="hello-world.jpg" alt="Sample photo">
<footer>That is all</footer>
```

以下は `.txt` 拡張子形式のコンテンツの例です。

```
---
title: This is another sample page
tags: example, test, plain-text
cover: another-cover.jpeg
summary: This is a sample page in txt format.
---
This is sample main content.
Each line of content is turned into <p></p> paragraph.
sample-image.jpeg
The image path / image name with individual line are turned into <img> tag.
This is footer paragraph.
```

`content-pages` folder 内のファイルは sub-folder に nested できます。

#### Front-matter

コンテンツファイルの先頭に front-matter がある場合があります。

front-matter セクションでは、さまざまな key-value ペアが定義されている場合があります。それらは次のとおりです。

- `title`（オプション）
- `tags`（オプション）: comma または comma-space で区切る
- `draft`（オプション）: `true`、またはその他の値。`"true"` 以外の値はすべて false とみなされます。
- `summary`（オプション）: 1行のみ。page の一覧表示に使用されます。

### 遺産サイト Web ページのレンダリング

レンダリングされた page には以下のセクションがあります。

- Cover image
- Title
- Aside 情報
- Main content

#### Cover Image

各コンテンツ page の cover image へのパスは、デフォルトで front-matter に定義されています。

front-matter に cover image が定義されていない場合、cover image は images folder に保存されている同じファイル名のものになります。このプロジェクトでは、cover image が存在しない場合を考慮する必要はありません。

#### Cover Image のスタイリング

cover image には subtle spotlight effect があります。

cover image には radial gradient mask が適用されます。mask はマウスポインターの位置を中心点として追跡する円で、`black` から `rgba(255,255,255,0)` まで `300px` で gradient します。

media ファイル内の `cover-image-styling.mp4` を参照してください。

#### Title の抽出について

cover image の後に Title セクションがあります。title のコンテンツは以下の基準に従って決定されます。

title は以下の順序で抽出されます。

1. front-matter に `title` が定義されている場合、Title セクションのコンテンツはその front-matter の値を使用します。
2. front-matter に `title` が定義されていない場合、Title セクションのコンテンツは最初の `<h1></h1>` のテキストコンテンツを使用します（シンプルなテキストコンテンツで、h1 はリッチな HTML を含みません）。
3. front-matter に `title` もなく、コンテンツに `<h1>` タグもない場合、Title セクションのコンテンツはファイル名を大文字化したもの（拡張子と `YYYY-MM-DD` 日付部分を除く）を使用します。また、すべての hyphen slug（`-`）を削除してスペースに置き換えます。

#### Title セクションのスタイリング

title のスタイリングには `common-ligatures` の typography setting を使用してください。

#### Aside 情報

aside 情報エリアには以下の情報があります。

- date
- tags
- draft（`draft` が `true` の場合）

サイドの meta 情報はスクロール時に上部に固定されます。

#### Main Content のレンダリング

main content はファイルから動的にロードされる必要があります。

ファイルロードの方針は以下のとおりです。

- ファイルの拡張子が `.html` の場合、main content と HTML タグはそのままレンダリングされます。parse または処理する必要はありません（image path を除く）。それらは単に HTML としてレンダリングされます。
- ファイルの拡張子が `.txt` の場合、テキストの行と image path を含む個別の行の2種類のコンテンツのみになります。各テキスト行は HTML paragraph に変換されます。
- image path の個別行は image タグに変換されます。これらはスペースのない行で、末尾に image 拡張子があります。
- `.html` と `.txt` の両方について、image path はサーバー上で機能する最終的な image path に置き換えられる必要があります。

content エリアの写真は main content コンテナの full-width で表示されます。main content エリアの写真はユーザーがクリックすると拡大できます。拡大された写真をクリックすると閉じて main content に戻ります。写真が拡大されている間にスクロールしても、拡大された写真が閉じて main content に戻ります。

最初の paragraph の先頭文字は3行分の drop cap を持ちます。

### Tags

コンテンツ page は tags でフィルタリングできます。tags クエリの URL は以下のように定義されます。

`http://wsXX.worldskills.org/XX_module_c/tags/tag-name-here` は指定された tag `tag-name-here` を含むすべての page を一覧表示します。

#### 検索

web page は page を検索できる必要があります。search input を提供し、ユーザーが title またはコンテンツを検索できるようにしてください。検索クエリが与えられると、web page は title またはコンテンツにクエリ文字列が含まれる page を一覧表示します。

`/` を使用して複数の keyword を定義できます。page は title またはコンテンツにいずれかの keyword が含まれる page を OR logic で一覧表示します。

## 競技者への指示

プロジェクトを sub-folder または別のポートに配置することができます。`wsXX.worldskills.org/XX_module_c/` のパスから目的地に redirect してください。

例えば、`/XX_module_c/heritages/sub-folder-name` は `/XX_module_c/public/heritages/sub-folder-name` または `/XX_module_c/index.php/heritages/sub-folder-name` または `:3000/XX_module_c/heritages/sub-folder-name` でもかまいません。

注意: Node.js を使用している場合、Windows（ワークステーション上）と Linux（サーバー上）の `node_modules` ファイルは異なります。誤った `node_modules` folder を使用すると、予期しないエラーが発生する可能性があります。

必要に応じて実行ガイドのための README ファイルを提供することができます。

アクセシビリティをより良くすることを考慮してください。aXe accessibility dev tool を使用して full page scan が実施されます。

各遺産 page のシェアに適した social sharing meta tag を定義してください。

`node_modules` folder やその他の temporary folder または built folder を除外するための `.gitignore` ファイルを定義してください。

このプロジェクトは Google Chrome web browser を使用して評価されます。

### 採点サマリー

| # | Sub-Criteria | 点数 |
|---|---|---|
| 1 | Files and Listing | 7.0 |
| 2 | Search and Tags | 2.0 |
| 3 | Loading files | 5.5 |
| 4 | Layout | 6.75 |

合計: 21.25 点
