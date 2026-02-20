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
    }
  },
  computed: {

  },
  async created() {

  },
  mounted() {
    addEventListener("keydown", this.onKeydown);
  },
  beforeUnmount() {
    removeEventListener("keydown", this.onKeydown);
  },
  watch: {

  },
  methods: {
    // コマンドバー用キー操作
    onKeydown(ev) {
      switch (ev.key) {
        case "ArrowUp":
          ev.preventDefault();
          this.currentCommandIndex = Math.max(Math.min(--this.currentCommandIndex, this.commandList.length - 1), 0);
          break;
        case "ArrowDown":
          ev.preventDefault();
          this.currentCommandIndex = Math.max(Math.min(++this.currentCommandIndex, this.commandList.length - 1), 0);
          break;
        case "Enter":
          ev.preventDefault();
          this.executeCommand();
          break;
        default:
          break;
      }
    },
    executeCommand() {
      // 拡張性と保守性捨て 条件分岐
      switch (this.commandList[this.currentCommandIndex]) {
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
        default:
          break;
      }
      this.isOpenCommandBar = false;
    },
  },
}
</script>

<template>
  <div class="command-bar">
    <ul class="command-list">
      <li v-for="commandListItem, i in commandList" :class="{ currentCommand: currentCommandIndex === i }" :key="i">
        {{ commandListItem }}
      </li>
    </ul>
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

.command-list {
  padding-left: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  height: 100%;
  width: 450px;
  margin: 0 auto;
}

.command-list li {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
}

.command-list .currentCommand {
  color: #fff;
  background: royalblue;
  font-weight: bold;
  outline: 3px solid royalblue;
  outline-offset: 4px;
}
</style>
