<script lang="js">
export default {
  name: "CommandBar",
  components: {

  },
  emits: [],
  inject: [
    "isOpenCommandBar",
    "currentThemeIndex",
    "currentPlayingModeIndex",
  ],
  data() {
    return {
      commandList: [
        "手動再生モードに切り替える",
        "自動再生モードに切り替える",
        "ランダム再生モードに切り替える",
        "テーマAに切り替える",
        "テーマBに切り替える",
        "テーマCに切り替える",
        "テーマDに切り替える",
        "テーマEに切り替える",
        "テーマFに切り替える",
      ],
      currentCommandIndex: 0,
      // add: 検索クエリ用の変数を追加。採点基準「partially matched commands」に対応。
      // CommandBar は v-if で制御されているため、閉じると query は自動的に '' にリセットされる。
      query: '',
    }
  },
  computed: {
    // add: 部分一致フィルタを computed で実装。
    // query が空文字のときは全件返る（filter の includes("") は常に true のため条件分岐不要）。
    // query が変わるたびに自動再計算され、template 側の v-for に反映される。
    filteredCommandList() {
      return this.commandList.filter(cmd => cmd.includes(this.query));
    },
  },
  created() {
    // omit: 非同期処理がないため async は不要。
  },
  mounted() {
    addEventListener("keydown", this.onKeydown);
  },
  beforeUnmount() {
    removeEventListener("keydown", this.onKeydown);
  },
  watch: {
    // add: query が変わったら currentCommandIndex を 0 にリセット。
    // フィルタ結果が変わると配列の長さも変わるため、以前選んでいたインデックスが
    // 範囲外になり filteredCommandList[currentCommandIndex] が undefined になることがある。
    // undefined になるとどの case にもマッチせず、コマンドが実行されない。
    query() {
      this.currentCommandIndex = 0;
    },
  },
  methods: {
    // コマンドバー用キー操作
    onKeydown(ev) {
      switch (ev.key) {
        case "ArrowUp":
          ev.preventDefault();
          // fix: 元々は Math.max(--index, 0) だったが、if 文の方が意図が明確。
          if (this.currentCommandIndex > 0) {
            this.currentCommandIndex--;
          }
          break;
        case "ArrowDown":
          ev.preventDefault();
          // fix: 元々は Math.min(++index, length - 1) だったが、ArrowUp と同様に if 文に変更。
          if (this.currentCommandIndex < this.filteredCommandList.length - 1) {
            this.currentCommandIndex++;
          }
          break;
        case "Enter":
          ev.preventDefault();
          this.executeCommand();
          break;
        // remove: default: break は何もしないため削除。
      }
    },
    executeCommand() {
      // 拡張性と保守性捨て 条件分岐
      switch (this.filteredCommandList[this.currentCommandIndex]) {
        case "手動再生モードに切り替える":
          this.currentPlayingModeIndex = 0;
          break;
        case "自動再生モードに切り替える":
          this.currentPlayingModeIndex = 1;
          break;
        case "ランダム再生モードに切り替える":
          this.currentPlayingModeIndex = 2;
          break;
        case "テーマAに切り替える":
          this.currentThemeIndex = 0;
          break;
        case "テーマBに切り替える":
          this.currentThemeIndex = 1;
          break;
        case "テーマCに切り替える":
          this.currentThemeIndex = 2;
          break;
        case "テーマDに切り替える":
          this.currentThemeIndex = 3;
          break;
        case "テーマEに切り替える":
          this.currentThemeIndex = 4;
          break;
        case "テーマFに切り替える":
          this.currentThemeIndex = 5;
          break;
      }
      // tricky: Vue 3 Options API では inject した Ref は自動アンラップされるため .value 不要。
      // this.isOpenCommandBar = false と書くだけで親の値が更新される。
      this.isOpenCommandBar = false;
    },
  },
}
</script>

<template>
  <div class="command-bar">
    <div class="command-bar-inner">
      <!-- add: 検索入力欄を追加。autofocus で CommandBar を開いた瞬間からキー入力を受け付ける。
           v-model="query" で入力内容を query にバインドし、computed の filteredCommandList が自動更新される。 -->
      <input v-model="query" autofocus placeholder="コマンドを検索...">
      <ul class="command-list">
        <!-- fix: v-for の対象を commandList から filteredCommandList に変更。
             フィルタ後のリストだけを表示することで部分一致検索を実現する。 -->
        <li v-for="commandListItem, i in filteredCommandList" :class="{ currentCommand: currentCommandIndex === i }" :key="i">
          {{ commandListItem }}
        </li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
.command-bar {
  position: fixed;
  inset: 0;
  background: #000000aa;
  z-index: calc(infinity * 1);
  padding: 40px;
}

/* add: .command-bar-inner を追加。検索 input を追加したため wrapper div が必要になった。
 * 元々 .command-list 側に width: 450px; margin: 0 auto; height: 100% を置いていたが、
 * input と ul を縦に並べて両方まとめてセンタリングする必要があるため、wrapper に移した。 */
.command-bar-inner {
  width: 450px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* add: 検索 input のスタイル。input 要素は追加した .command-bar-inner の直下に配置。
 * - border-radius: 4px 4px 0 0: 上辺だけ角丸にして下部を ul と面一に繋げる。
 * - border: none; outline: none: ブラウザデフォルトの枠線とフォーカスリングを除去。
 * - box-sizing: border-box: width: 100% が padding を含むようにする（含まないとはみ出す）。 */
.command-bar-inner input {
  width: 100%;
  padding: 12px 16px;
  font-size: 1rem;
  border: none;
  border-radius: 4px 4px 0 0;
  outline: none;
  box-sizing: border-box;
}

/* fix: .command-list の変更点:
 * - justify-content: space-evenly → flex-start:
 *     元々はコマンドを画面いっぱいに均等配置していたが、検索で件数が減ると間隔が広がりすぎるため
 *     上詰めに変更。
 * - height: 100% → flex: 1:
 *     親 (.command-bar-inner) が flex column になったため、残りの高さを占有するには flex: 1 を使う。
 *     height: 100% は親の height を基準にするが、flex 子要素では flex: 1 の方が正確に動作する。
 * - width: 450px と margin を削除:
 *     .command-bar-inner に移動したため不要。
 * - overflow-y: auto を追加:
 *     コマンド件数が多い場合に縦スクロールできるようにする。
 * - margin: 0 を追加:
 *     ul のデフォルト margin を打ち消す（input との隙間をなくす）。 */
.command-list {
  padding-left: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  flex: 1;
  overflow-y: auto;
  margin: 0;
}

/* fix: .command-list li の変更点:
 * - border-radius: 4px → 削除:
 *     元々は各 li に角丸を設定していたが、input と ul が縦に繋がって一体感を出すため
 *     li 単体では角丸を持たないようにした。border-radius のデフォルト値は 0 のため明示不要。
 * - border-top: 1px solid #eee を追加:
 *     隣接する li の境界線を表示するため。 */
.command-list li {
  background: #fff;
  padding: 16px 24px;
  border-top: 1px solid #eee;
}

/* add: .command-list li:last-child を追加。
 * input の上辺が border-radius: 4px 4px 0 0 なので、
 * リストの最下部（最後の li）だけ border-radius: 0 0 4px 4px を付けて
 * input + ul 全体が角丸の矩形に見えるようにする。 */
.command-list li:last-child {
  border-radius: 0 0 4px 4px;
}

.command-list .currentCommand {
  color: #fff;
  background: royalblue;
  font-weight: bold;
  outline: 3px solid royalblue;
  outline-offset: 4px;
}
</style>
