<script lang="js">
import { toRef } from "vue";
import SlideShow from "../components/SlideShow.vue";
import LoadImage from "../components/LoadImage.vue";
import CommandBar from "../components/CommandBar.vue";

export default {
  name: "HomeView",
  components: {
    SlideShow,
    LoadImage,
    CommandBar,
  },
  emits: [],
  inject: [],
  data() {
    return {
      // remove: playingModeList を削除。<option> を直接記述することで data 定義と v-for が不要になる。
      currentPlayingModeIndex: 0,

      themeList: [
        { ja: "テーマA", en: "themeA", },
        { ja: "テーマB", en: "themeB", },
        { ja: "テーマC", en: "themeC", },
        { ja: "テーマD", en: "themeD", },
        { ja: "テーマE", en: "themeE", },
        { ja: "テーマF", en: "themeF", },
      ],
      currentThemeIndex: 0,

      intervalId: null,
      // キーの重複防止
      slideCount: 0,

      imageList: [],
      curenntImageIndex: 0,
      nextImageListId: 1,

      isDragedId: null,

      isOpenCommandBar: false,
      // add: 採点基準「When config button is clicked, the config panel is displayed」に対応。
      // 修正前は設定パネルが常時表示されており、ボタンで開閉する仕様を満たしていなかった。
      // このフラグで template 側の v-show を制御する。
      isOpenConfigPanel: false,
    }
  },
  // tricky: provide() で toRef を使い reactivity を保持。
  // そのまま渡すと値のコピーになり、親の変更が子に伝わらない。
  provide() {
    return {
      currentPlayingModeIndex: toRef(this.$data, "currentPlayingModeIndex"),

      themeList: toRef(this.$data, "themeList"),
      currentThemeIndex: toRef(this.$data, "currentThemeIndex"),

      imageList: toRef(this.$data, "imageList"),
      curenntImageIndex: toRef(this.$data, "curenntImageIndex"),
      slideCount: toRef(this.$data, "slideCount"),
      addImageList: this.addImageList,

      isOpenCommandBar: toRef(this.$data, "isOpenCommandBar"),
    }
  },
  computed: {

  },
  created() {
    // omit: 非同期処理がないため async は不要。
  },
  mounted() {
    addEventListener("keydown", this.onKeydown);
  },
  beforeUnmount() {
    removeEventListener("keydown", this.onKeydown);
    clearInterval(this.intervalId);
  },
  watch: {
    // 再生モードの変更
    currentPlayingModeIndex(newVal) {
      clearInterval(this.intervalId);
      // remove: case 0 と default は break のみで何もしないため削除。
      switch (newVal) {
        case 1:
          this.intervalId = setInterval(this.autoSlideshow, 3000);
          break;
        case 2:
          this.intervalId = setInterval(this.randomSlideshow, 3000);
          break;
      }
    },
    // キーの重複防止
    curenntImageIndex() {
      this.slideCount++;
    },
  },
  methods: {
    // 画像の追加
    addImageList(name, base64) {
      // omit: 'id' のクォートを削除。id は予約語でも特殊文字でもないためクォート不要。
      this.imageList.push({
        id: this.nextImageListId,
        name,
        base64,
      });
      this.nextImageListId++;
    },
    // キー操作制御
    onKeydown(ev) {
      switch (ev.key) {
        case "ArrowLeft":
          // fix: !this.isOpenCommandBar を追加。
          // CommandBar 表示中でも ArrowLeft/ArrowRight を押すと HomeView のスライド送りが発火してしまっていた。
          // CommandBar が開いている間はスライド操作を無効にする。
          if (this.currentPlayingModeIndex === 0 && !this.isOpenCommandBar) {
            ev.preventDefault();
            this.manualSlideshow(-1);
          }
          break;
        case "ArrowRight":
          // fix: ArrowLeft と同様の理由で !this.isOpenCommandBar を追加。
          if (this.currentPlayingModeIndex === 0 && !this.isOpenCommandBar) {
            ev.preventDefault();
            this.manualSlideshow(1);
          }
          break;
        case "k":
          if (ev.ctrlKey) {
            ev.preventDefault();
            this.openCommandBar();
          }
          break;
        case "/":
          // fix: !this.isOpenCommandBar を追加。
          // 修正前は CommandBar が開いている状態でも ev.preventDefault() が呼ばれていたため、
          // CommandBar の input 欄に "/" を入力しようとしても文字が入らなかった。
          // CommandBar が閉じているときだけ preventDefault() + 開く動作をする。
          if (!this.isOpenCommandBar) {
            ev.preventDefault();
            this.openCommandBar();
          }
          break;
        case "Escape":
          ev.preventDefault();
          this.closeCommandBar();
          break;
        // omit: default: break は何もしないため削除。
      }
    },
    // 手動制御用 呼ばれるたび画像を変更 ループしない
    manualSlideshow(delta) {
      // omit: length !== 0 → length に短縮。0 以外は truthy のため同義。
      if (this.imageList.length) {
        this.curenntImageIndex = Math.min(Math.max(0, this.curenntImageIndex + delta), this.imageList.length - 1);
      }
    },
    // 自動再生用 setInterval前提 無限に再生
    autoSlideshow() {
      // omit: manualSlideshow と同様に length !== 0 → length に短縮。
      if (this.imageList.length) {
        // smart: % imageList.length で末尾判定なしに先頭へ折り返す無限ループを実現。
        this.curenntImageIndex = (this.curenntImageIndex + 1) % this.imageList.length;
      }
    },
    // ランダム再生用 setInterval前提 無限に再生
    randomSlideshow() {
      if (this.imageList.length > 1) {
        // omit: oldIndex 変数を削除。do...while の条件で this.curenntImageIndex を直接参照できる。
        // smart: do...while で前回と異なる index を選ぶ。if 再帰や while 初期化より簡潔。
        let newIndex;
        do {
          newIndex = Math.floor(Math.random() * this.imageList.length);
        } while (this.curenntImageIndex === newIndex);
        this.curenntImageIndex = newIndex;
      }
    },
    // 写真の並び替え制御
    // smart: 1箇所からしか呼ばれない1行の代入なのでインラインでも問題ないが、
    // open/close と同様、対になる操作（DragStart/Drop）はセットで関数化する。
    orderSlideShowOnDragStart(index) {
      this.isDragedId = index;
    },
    // 写真の並び替え制御
    orderSlideShowOnDrop(index) {
      const movedImage = this.imageList.splice(this.isDragedId, 1)[0];
      this.imageList.splice(index, 0, movedImage);
    },
    // smart: 1行の代入なのでインラインでも問題ないが、
    // open/close の対になる操作を分離することで、複数箇所（Ctrl+K, /）から呼び出しても意図が明確になる。
    openCommandBar() {
      this.isOpenCommandBar = true;
    },
    // smart: close も同様。1箇所（Escape）からしか呼ばれないがopen との対で関数化。
    closeCommandBar() {
      this.isOpenCommandBar = false;
    },
  },
}
</script>

<template>
  <div class="home-view">
    <!-- omit: 自己閉じタグに変更。内容のないコンポーネントは <SlideShow /> と書ける。 -->
    <SlideShow />
    <LoadImage />
    <!-- add: 設定ボタンを追加。クリックするたびに isOpenConfigPanel を反転して開閉する。 -->
    <button @click="isOpenConfigPanel = !isOpenConfigPanel">設定</button>
    <!-- add: v-show="isOpenConfigPanel" を追加。修正前は常時表示されていた。
         v-if ではなく v-show を使うことで DOM は残したまま表示/非表示を切り替える。 -->
    <div class="config-panel" v-show="isOpenConfigPanel">
      <h2>設定パネル</h2>
      <div>
        <label>
          操作モード：
          <!-- omit: playingModeList の v-for を削除。件数固定のため直接 <option> を記述する方がシンプル。 -->
          <select name="playing-mode" v-model="currentPlayingModeIndex">
            <option :value="0">手動制御</option>
            <option :value="1">自動再生</option>
            <option :value="2">ランダム再生</option>
          </select>
        </label>
      </div>
      <div>
        <label>
          テーマ：
          <select name="theme" v-model="currentThemeIndex">
            <option v-for="(themeListItem, index) in themeList" :value="index" :key="index">
              {{ themeListItem.ja }}
            </option>
          </select>
        </label>
      </div>
      <div class="order-slide-show">
        <span>写真の並び替え：</span>
        <TransitionGroup name="image-list" tag="ul">
          <!-- tricky: index を key にすると並び替え後に TransitionGroup が要素を誤追跡しアニメーションが崩れる。
               固有 id を使うことで正しく追跡できる。 -->
          <li v-for="(imageListItem, index) in imageList" :key="imageListItem.id" draggable="true"
            @dragstart="orderSlideShowOnDragStart(index)" @dragover.prevent @drop="orderSlideShowOnDrop(index)">
            <img :src="imageListItem.base64" alt="">
          </li>
        </TransitionGroup>
      </div>
    </div>
    <!-- tricky: v-show にすると閉じても DOM が残り query がリセットされない。
         v-if なら閉じると DOM ごと破棄され query が自動リセットされる。 -->
    <CommandBar v-if="isOpenCommandBar" />
  </div>
</template>

<style scoped>
.home-view {
  display: flex;
  flex-direction: column;
  gap: 16px;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
}

.config-panel {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.order-slide-show ul {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.order-slide-show ul li img {
  height: 300px;
  aspect-ratio: 1.618;
  object-fit: cover;
  user-select: none;
}

.image-list-move {
  transition: all 0.5s ease;
}
</style>
