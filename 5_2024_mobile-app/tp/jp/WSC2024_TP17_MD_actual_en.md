# Test Project Module D Lyon Mobile Web Service

## Web Technologies

Independent Test Project Designer: Thomas Seng Hin Mak SCM

Independent Test Project Validator: Fong Hok Kin

## 目次

- [はじめに](#introduction)
- [ProjectとTaskの説明](#description-of-project-and-tasks)
  - [Mobile Web Layout](#mobile-web-layout)
  - [Navigation Bar](#navigation-bar)
  - [The Data API](#the-data-api)
  - [Paging](#paging)
  - [Carpark Availability](#carpark-availability)
  - [Lyon Events](#lyon-events)
  - [Weather](#weather)
  - [Setting](#setting)
- [競技者へのInstructions](#instructions-to-the-competitor)
- [その他](#other)
- [採点Summary](#marking-summary)

## はじめに

このprojectでは、Lyonの主要なservices dataを提供するmobile webを作成します。webはmock API serverを通じてdynamic dataをqueryします。このAPI serverはpre-builtで提供されます。

serverはPHP-basedです。dl.worldskills.org/module_d_api_server.zipにあります。zip fileを解凍するとmodule_d_api.phpという単一のfileが表示されます。

このmock API PHP fileをwsXX.worldskills.org/module_d_api.phpに配置してください。

## ProjectとTaskの説明

### Mobile Web Layout

- header bar、main content、navigation barがあります。
- header barは常にscreenのtopに固定されます。
- navigation barは常にscreenのbottomに固定されます。
- main contentがviewportより長い場合、scrollingはmain contentのみに発生します。header barとnavigation barは固定されたままです。
- header barは現在のview titleを表示する場合があり、backへのnavigationを提供します。

### Navigation Bar

navigation barには4つのbuttonがあります：

1. Carparks
2. Events
3. Weather
4. Setting

### The Data API

API serverには3つの主要partがあります：

- wsXX.worldskills.org/module_d_api.php/carparks.json
- wsXX.worldskills.org/module_d_api.php/events.json
- wsXX.worldskills.org/module_d_api.php/weather.json

### Paging

events APIにはpaginationがあります。

次のpage URLは以下のstructureで確認できます：

```json
{
  "pages": {
    "next": "xxxxx",
    "prev": "xxxxx"
  }
}
```

### Carpark Availability

navigation barの最初のbuttonはcarpark availabilityです。

mobile web pageはcarparkのrecord listを表示します。各recordにはavailability countがあります。

#### Sorting

alphabetでのsortingと、current locationから各carparkまでのdistanceでのsortingを切り替えるtoggleがあります。toggle settingはsetting view（navigation barの4番目のbutton）内にあります。

#### GeolocationとそのSimulation

locationをsimulateする必要があります。

2つのmethodがあります：手動でgeolocationを設定するか、ChromeのgeolocationのDev Toolを使用します。

- geolocationはURL queryのlatitudeとlongitudeで手動設定できます。例えば、userは`?latitude=45.755051&longitude=4.846358`をURLに追加してgeolocationをsimulateできます。
- geolocation distanceを計算するJavaScript codeが提供されます。
- mobile webはdefault methodとしてcurrent geolocationをrequestできる必要があります。security policyとcompetition environmentの制限により、geolocationを取得するJavaScript codeがcompetition environmentの制限でweb browserからblockされた場合、geolocation implementationのsource codeを評価する場合があります。

#### Carparkへのfocusing

- userはlist内のcarparkをclickしてひとつのcarparkにfocusできます。
- carparkにfocusしている時、viewにはcarpark name、distance、availability numberのみが表示されます。
- userはこのviewからcarpark listにback可能です。

#### CarparkをTopにpin可能

- carparkはsorting methodに関係なく、listのtopにpinおよびunpinできます。
- pinされたstatusはlocal storageに保存され、page refreshで復元される必要があります。

### Lyon Events

2番目のnavigation buttonはEvent Listにlinkします。

listはdefault APIのreturning dataに基づいて、初期のeventsを表示します。eventsはtopからbottomにlistされます。各event recordには、image、event title、event dateがあります。

#### Events Dataのquerying

- event listはbeginning dateとending dateでfilter可能です。
- beginning dateを選択するinputと、ending dateを選択するinputがあります。
- beginning dateやending dateが選択されると、event listがrefreshされ、更新されたquery resultが表示されます。
- API endpoint: `/module_d_api.php/events.json?beginning_date=YYYY-MM-DD&ending_date=YYYY-MM-DD`

#### Infinite Scrolling

- userがbottomまでscrollすると、web pageはさらなるevent dataをloadし、userにさらなるeventsを表示します。これはinfinite scrollingとも呼ばれます。
- infinite scrollingのtimingとsmoothnessをfine-tuneしてください。further contentのloadingが遅すぎたり、早すぎたりしてはいけません。つまり、infinite scrollがlaggyに感じられず、eagerlyに多くのdataをloadしすぎないようにする必要があります。
- data loadingが正しいことを確認してください。同じrecordの複数instanceが表示されたり、表示すべきrecordが欠落したりしてはいけません。

### Weather

3番目のnavigation buttonはweather用です。

upcoming weekのweatherを表示します。7日間のweatherがあります。

#### Horizontal Scrolling

- week weatherはhorizontalにalignされます。horizontalにscrollingすると、weatherがdayにsnapします。
- media file内のweather mockupを参照してください。

#### SVG

各dayにSVG iconがあります。

- SVG iconはdayのweather statusに基づきます。responseされたJSON dataがどのiconを使用するかを定義しています。
- SVG icon上にmouse hoverすると、SVGにanimated stroke effectが発生します。
- SVGはstroke color `#1c3e60`、stroke width `1`、`none` fillです。
- `stroke-dasharray` styleが`50`から`200`へ2秒間、`stroke-dashoffset` styleが`200`から`0`へ変化します。
- media files内のsvg-icon-animation.mp4を参照してください。

### Setting

navigation barの4番目のbuttonはsetting viewです。

#### Dark Theme

dark theme、light theme、およびsystemのlight/dark theme settingに追従するoptionの間でthemeを切り替えるconfigurationがあります。

#### Carpark Sorting Method

alphabetでのsortingと、current locationから各carparkまでのdistanceでのsortingを切り替えるtoggleがあります。

## 競技者へのInstructions

### Mobile Web App Configuration

- manifest.jsonとAndroidおよびiOS mobile web system向けの必須meta tagsを設定してください。
- viewportもmobile web friendlyな表示のために設定する必要があります。

### Accessibility

- 良いaccessibilityを確保してください。Chrome Lighthouse accessibilityのscoreで評価します。
- maintainしやすいJavaScript codeの作成も確保してください。

## その他

- このprojectはGoogle Chrome web browserを使用して評価されます。
- 必要に応じて実行guideのREADME fileを提供できます。
- Node.jsを使用する場合、Windows（workstation上）とLinux（server上）のnode_modules filesが異なることに注意してください。間違ったnode_modules folderを使用すると、予期しないerrorが発生する可能性があります。

## 採点Summary

|   | Sub-Criteria | Marks |
|:--|:-------------|:------|
| 1 | Mobile Web General | 2.5 |
| 2 | Carpark | 3.0 |
| 3 | Events | 3.25 |
| 4 | Weather | 1.75 |
| 5 | Settings & General | 2.25 |
