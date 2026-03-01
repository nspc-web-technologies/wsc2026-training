# 実装チェックリスト

## 参照

- 仕様書: `../tp/WSC2024_TP17_ME_actual_jp_final.md`
- 採点基準: `../tp/WSC2024_TP17_ME_making_scheme.csv`
- 実装: `./vue/src/`

## 方針

- セクションは依存関係順に並んでいる。`HomeView.vue` の `provide` が先、`inject` する子コンポーネントが後
- `HomeView.vue` は「骨格」「手動送り・CommandBar 開閉」「自動再生・並び替え」の3セクションに分割されており、後から追加する機能を後回しにできる
- `SlideShow.vue` と `LoadImage.vue` はテーマ CSS の動作確認に必要なため、テーマ CSS より前に配置
- テーマ CSS はコンポーネントが揃い画像をロードできるようになってから取り組む。Theme F を含む全6テーマを実装する

## 学習用コメント

コードを修正する時に、学習用のコメントとして、修正箇所の直上にコメントを追記する。

| タグ | 書く内容 |
|------|---------|
| `fix` | 修正前の挙動 → 何が問題か（仕様違反・CSS の無効・イベント競合・参照先の更新漏れ）→ 修正後が正しい理由 |
| `add` | 何を追加したか → 採点基準・仕様のどの要件に対応するか → 修正前に何が欠けていたか |
| `remove` | 何を削除したか → なぜ不要か（呼び出し元で保証済み・1箇所のみ・無効な CSS・何もしない case） |
| `omit` | 何を省略したか → なぜ省略できるか（デフォルト値・truthy・片側クランプ不要・中間変数不要） |
| `tricky` | なぜ引っかかりやすいか → 一見別の書き方で良さそうだが動かない理由・知らないと詰まる罠 |
| `smart` | なぜ賢い書き方か → 知っていると作業量が減る・条件分岐や変数が不要になる理由 |

### 例

// add: 検索クエリ用フラグを追加。採点基準「partially matched commands」に対応
// CommandBar は v-if で制御されているため、閉じると query は自動的に '' にリセットされる

## ステータス

- ✅ 実装済み・正しい: 78
- 🚧 実装したがバグあり（修正が必要）: 0
- ❌ 未実装（これから書く）: 0
- 👀 動作確認が必要（ブラウザで目視確認）: 31

## 実装手順・チェックリスト

- ✅ プロジェクト初期設定
  - ✅ Vue プロジェクトを作成する（Router のみ選択）
  - ✅ Vite の `base` にコンテスト番号付きパスを設定する
  - ✅ Router に `createWebHistory(import.meta.env.BASE_URL)` を使う（`base` 設定が自動反映される）
  - ✅ テーマ CSS ファイルを A〜F の 6 つ作成する（空ファイル）
  - ✅ `main.js` で 6 つのテーマ CSS を import する
  - 👀 確認: `http://localhost:5173/XX_module_e/` でページが開く

- ✅ `HomeView.vue` — data・provide・template 骨格
  - ✅ `toRef` を import する
  - ✅ `data()` を定義する
    - ✅ 画像リスト・現在のインデックス・次の ID を初期化する
    - ✅ テーマ一覧を `{ ja, en }` 配列で定義する（A〜F の 6 テーマ）
    - ✅ 再生モードインデックスを定義する（選択肢は data に持たず `<option>` 直書き）
    - ✅ タイマー ID・スライドカウント・ドラッグ用 ID・コマンドバー開閉フラグを初期化する
  - ✅ `provide()` を定義する
    - ✅ 各データを `toRef(this.$data, 'キー名')` で Ref として公開する
    - ✅ 公開するキー: 画像リスト・現在のインデックス・スライドカウント・テーマ関連・再生モード・コマンドバー開閉
    - ✅ 画像追加関数はそのまま渡す（`toRef` 不要）
  - ✅ `addImageList(name, base64)` メソッドを定義する（リストに push して ID をインクリメント）
  - ✅ template に `<SlideShow />`・`<LoadImage />`・設定パネル・`<CommandBar v-if>` を配置する
  - ✅ 操作モード選択の `<select>` を配置する — `<option>` を直接 3 件記述する（v-for 不要）
  - ✅ テーマ選択の `<select>` を配置する
  - 👀 確認: `<SlideShow>`・`<LoadImage>` がエラーなく表示される
  - 👀 確認: テーマ選択 `<select>` を変えると Vue DevTools で `currentThemeIndex` が変わる

- ✅ `LoadImage.vue`
  - ✅ 画像追加関数のみ inject する（画像リスト自体は不要）
  - ✅ ドロップゾーンを実装する — `dataTransfer.files` をスプレッドし各ファイルを処理（`items` + `kind` フィルタでも同等だが `files` の方が簡潔）
  - ✅ ファイル選択 input（`multiple`）を実装する
  - ✅ サンプル読み込みボタンを実装する — `import.meta.env.BASE_URL` + パスで画像を追加する（base64 変換不要）。`base` 設定済みなので `BASE_URL` を使わないとパスがずれる
  - ✅ `readAndConvertImage` を実装する — `FileReader` で base64 変換してから追加する
  - ✅ ファイル名からキャプションを生成する: 区切り文字で分割 → 拡張子を除去 → 先頭大文字化 → スペース結合（`-` は文字クラス範囲 `[ -\.]` に含まれる点に注意）
  - ✅ ファイル input を CSS で非表示にする（CSS 無効時に表示される仕様）
  - 👀 確認: ファイル選択・ドロップ・サンプルボタンで `imageList` に画像が追加される
  - 👀 確認: キャプションがスラッグなし・先頭大文字で生成されている
  - 👀 確認: CSS を無効にすると `<input type="file">` が表示される

- ✅ `SlideShow.vue`
  - ✅ 必要なデータを inject する（テーマ・画像リスト・インデックス・スライドカウント）
  - ✅ `.slide-window` を relative + overflow hidden にする
  - ✅ `.slide` を absolute + 100% サイズにする
  - ✅ `.slide-show` にテーマ名ベースのクラスを動的に付与する（Theme D の CSS セレクタに必須）
  - ✅ `<Transition>` の `name` をテーマ英名に連動させる
  - ✅ Theme E 以外: `<figure>` に `key` としてインデックスとスライドカウントの組み合わせを設定する。`--r` に 0〜10 のランダム値を設定する（Theme D の ±5deg 傾斜用）
    - ✅ `<img>` と `<figcaption>` を内包する
    - ✅ `<figcaption>` 内の単語を `<span>` に分割し `--i` を付与する（Theme C の delay 用）
  - ✅ Theme E のみ: `<div class="slide">` + 同じ画像を 2 枚（左右 clip 用）。figcaption は不要
  - ✅ フルスクリーンボタンを実装する — `fullscreenElement` の有無で request / exit を切り替える
  - 👀 確認: サンプル読み込み後に画像がスライドに表示される
  - 👀 確認: フルスクリーンボタンで全画面になる
  - 👀 確認: `figcaption` の `<span>` に `--i` が付いている（DevTools で確認）

- ✅ `HomeView.vue` — 手動送り・CommandBar 開閉
  - ✅ `mounted` でグローバル `keydown` リスナーを登録し、`beforeUnmount` で解除する
  - ✅ キーハンドラを実装する: `←`/`→`（手動送り）、`Ctrl+K`（開く）、`/`（閉じているときのみ開く）、`Escape`（閉じる）
  - ✅ `←`/`→` に「手動モードかつコマンドバーが閉じている」二重ガードを付ける。HomeView と CommandBar が両方グローバル keydown を登録しているため二重発火を防ぐ
  - ✅ `/` キーにコマンドバー閉時ガードを付ける。開いた状態で `preventDefault` されると input に `/` を入力できなくなるため
  - ✅ `manualSlideshow(delta)` を実装する — リスト長でガード後、`Math.min(Math.max(...))` でクランプする
  - ✅ コマンドバー開閉は `openCommandBar()` / `closeCommandBar()` メソッドで行う（`Ctrl+K` と `/` の 2 箇所から呼ぶため関数化）
  - ✅ `curenntImageIndex` の watcher でスライドカウントをインクリメントする
  - 👀 確認: `←``→` キーで画像が切り替わる
  - 👀 確認: `Ctrl+K` または `/` で `isOpenCommandBar` が true になる（DevTools で確認）

- ✅ `CommandBar.vue`
  - ✅ 必要なデータを inject する（コマンドバー開閉・テーマ・再生モード）
  - ✅ `data()` にコマンド一覧（モード切替 3 種 + テーマ切替 6 種）・選択インデックス・検索クエリを定義する
  - ✅ `filteredCommandList` computed を実装する — 部分一致フィルタ（`includes("")` は常に true のため空クエリの分岐不要）
  - ✅ `query` の watcher でインデックスを 0 にリセットする。フィルタ結果の件数が変わると旧インデックスが範囲外になり `undefined` 参照になるのを防ぐ
  - ✅ template に検索 input（`autofocus`）とコマンドリストを配置する
  - ✅ 選択中の項目に active クラスを付与する
  - ✅ 背景を `position: fixed; inset: 0` の半透明オーバーレイにする
  - ✅ `mounted` で `keydown` リスナーを登録し、`beforeUnmount` で解除する
  - ✅ `↑`/`↓` でインデックスを増減する（リスト長で上限制御）
  - ✅ `Enter` でコマンドを実行する
  - ✅ `executeCommand()` を実装する — 選択中のコマンド名で switch 分岐する
  - ✅ inject した Ref に直接代入して親の値を更新する（Vue 3 Options API では inject した Ref は自動アンラップされるため `.value` 不要）
  - ✅ コマンド実行後にコマンドバーを閉じる
  - 👀 確認: コマンドバーが閉じている状態で `Ctrl+K` または `/` を押すと開き、背景が暗くなる
  - 👀 確認: 文字を入力するとリストが絞り込まれる
  - 👀 確認: `↑↓` でハイライトが移動する
  - 👀 確認: `Enter` でテーマ・モードが切り替わりコマンドバーが閉じる
  - 👀 確認: `ESC` でコマンドバーが閉じる

- ✅ テーマ CSS（`←``→` で切り替えながら1テーマずつ確認）
  - ✅ Theme A
    - ✅ 空ファイルのままでよい（トランジションなし、キャプションは SlideShow の scoped CSS で定義済み）
    - 👀 確認: キャプションが表示されている
  - ✅ Theme B
    - ✅ 入場・退場に 0.5s ease のトランジションを設定する
    - ✅ 入場は左から、退場は右へ（`translateX`）。仕様書と採点基準が矛盾する場合は仕様書優先
    - ✅ figcaption は 300ms 遅延で入場させる（`transition-delay`）
    - ✅ figcaption の入場も左から（写真と同方向）
    - 👀 確認: 左から入り・右に出る
    - 👀 確認: キャプションが少し遅れて入場する
  - ✅ Theme C
    - ✅ 入場・退場に 0.5s ease のトランジションを設定する
    - ✅ 入場は下から、退場は上へ（`translateY`）
    - ✅ figcaption も下から入場させる
    - ✅ figcaption の各 `<span>` に `--i` を使った連鎖 delay を設定する（`calc(300ms * var(--i))`）
    - ✅ 各 span の入場は下から少し余白付きで（`calc(100% + 8px)`）
    - 👀 確認: 下から入り・上に出る
    - 👀 確認: キャプションの単語が1つずつ時間差で入場する
  - ✅ Theme D
    - ✅ 入場に 0.5s ease のトランジションを設定する
    - ✅ 退場に 0.5s ease + 300ms 遅延を設定する（仕様書の `30s` はタイプミス、`300ms` が正しい）
    - ✅ スライドを中央配置し、`--r` に応じてランダム傾斜させる。白枠・角丸・85% サイズ。中央寄せには `translate` 個別プロパティを使う（`transform` のトランジションと競合しないため）
    - ✅ 入場は左から、退場も左へ（仕様「Go out to left」に対応。`opacity` フェードアウトは誤り）
    - ✅ figcaption を写真幅いっぱいにする（`width: 100%; border-radius: 0`）
    - 👀 確認: 写真が中央に表示されランダムに傾いている
    - 👀 確認: 左から入り・左に出る
    - 👀 確認: 前の写真が即座に消える（30s delay になっていない）
  - ✅ Theme E（※ SlideShow の `<div class="slide">` 構造を使う）
    - ✅ 入場・退場に 0.5s ease のトランジションを設定し、`z-index: 400` を付ける
    - ✅ 入場時に `z-index` を退場中スライドより低くする（下に潜り込む入場アニメーション）
    - ✅ 左半分を `clip-path: inset(0 49% 0 0)` で切り出し、`transform-origin` を左端にする
    - ✅ 右半分を `clip-path: inset(0 0 0 49%)` で切り出し、`transform-origin` を右端にする
    - ✅ 左右それぞれに 0.5s ease のトランジションを設定する（同内容なので 1 ルールに結合可）
    - ✅ 退場時に左を `rotateY(90deg)`、右を `rotateY(-90deg)` で開く
    - 👀 確認: 退場時に左右に開いて消える
    - 👀 確認: 入場スライドが退場スライドの下から現れる
  - ✅ Theme F
    - ✅ 入場・退場に 1s ease のトランジションを設定する
    - ✅ 入場を `clip-path: circle(0)` から広がる円形にする
    - ✅ 退場を `clip-path: circle(0)` へ縮む円形にする
    - ✅ figcaption は写真入場完了後に 1s 遅延で登場させる（`transition-delay: 1s`）
    - ✅ figcaption は下から入場させる（`translateY`）
    - 👀 確認: テーマ選択に Theme F が表示され、入場・退場ともにアニメーションが動く
    - 👀 確認: キャプションが写真入場後に遅れて下から登場する

- ✅ `HomeView.vue` — 自動再生・並び替え
  - ✅ `beforeUnmount` に `clearInterval` を追加する
  - ✅ `currentPlayingModeIndex` の watcher で `clearInterval` → モードに応じて `setInterval` を再設定する（何もしない case は不要）
  - ✅ `autoSlideshow()` を実装する — リスト長でガード後、剰余で先頭に戻るループ送りにする
  - ✅ `randomSlideshow()` を実装する — リスト長 > 1 でガード後、do-while で前回と異なるインデックスを選ぶ
  - ✅ `isOpenConfigPanel` フラグを追加し、Config ボタンでトグルする
  - ✅ 設定パネルを `v-show` で開閉制御する
  - ✅ 並び替えリストを実装する — `<TransitionGroup>` + `v-for` + `draggable` + ドラッグイベント（move トランジション 0.5s ease を scoped CSS に追加）
  - ✅ `@dragstart` でドラッグ元のインデックスを保存する（1 行のみのためメソッド化不要、インライン記述）
  - ✅ `orderSlideShowOnDrop(index)` を実装する — `splice` で要素を取り出してドロップ先に挿入する
  - 👀 確認: 自動再生モードに切り替えると 3 秒ごとに画像が進む
  - 👀 確認: ランダム再生モードで同じ画像が連続しない
  - 👀 確認: Config ボタンで設定パネルが開閉する
  - 👀 確認: 並び替えリストのドラッグで順序が変わり、スライドの順序も変わる
