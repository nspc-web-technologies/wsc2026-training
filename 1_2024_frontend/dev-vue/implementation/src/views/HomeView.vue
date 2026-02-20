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
      playingModeList: [
        "手動制御",
        "自動再生",
        "ランダム再生",
      ],
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
    }
  },
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
  async created() {

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
      switch (newVal) {
        case 0:
          break;
        case 1:
          this.intervalId = setInterval(this.autoSlideshow, 3000);
          break;
        case 2:
          this.intervalId = setInterval(this.randomSlideshow, 3000);
          break;
        default:
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
      this.imageList.push({
        'id': this.nextImageListId,
        name,
        base64,
      });
      this.nextImageListId++;
    },
    // キー操作制御
    onKeydown(ev) {
      switch (ev.key) {
        case "ArrowLeft":
          if (this.currentPlayingModeIndex === 0) {
            ev.preventDefault();
            this.manualSlideshow(-1);
          }
          break;
        case "ArrowRight":
          if (this.currentPlayingModeIndex === 0) {
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
          ev.preventDefault();
          this.openCommandBar();
          break;
        case "Escape":
          ev.preventDefault();
          this.closeCommandBar();
          break;
        default:
          break;
      }
    },
    // 手動制御用 呼ばれるたび画像を変更 ループしない
    manualSlideshow(delta) {
      if (this.imageList.length !== 0) {
        this.curenntImageIndex = Math.min(Math.max(0, this.curenntImageIndex + delta), this.imageList.length - 1);
      }
    },
    // 自動再生用 setInterval前提 無限に再生
    autoSlideshow() {
      if (this.imageList.length !== 0) {
        this.curenntImageIndex = (this.curenntImageIndex + 1) % this.imageList.length;
      }
    },
    // ランダム再生用 setInterval前提 無限に再生
    randomSlideshow() {
      if (this.imageList.length > 1) {
        let oldIndex = this.curenntImageIndex;
        let newIndex;
        do {
          newIndex = Math.floor(Math.random() * this.imageList.length);
        } while (oldIndex === newIndex);
        this.curenntImageIndex = newIndex;
      }
    },
    // 写真の並び替え制御
    orderSlideShowOnDragStart(index) {
      this.isDragedId = index;
    },
    // 写真の並び替え制御
    orderSlideShowOnDrop(index) {
      const movedImage = this.imageList.splice(this.isDragedId, 1)[0];
      this.imageList.splice(index, 0, movedImage);
    },
    // コマンドバー制御
    openCommandBar() {
      this.isOpenCommandBar = true;
    },
    // コマンドバー制御
    closeCommandBar() {
      this.isOpenCommandBar = false;
    },
  },
}
</script>

<template>
  <div class="home-view">
    <SlideShow></SlideShow>
    <LoadImage></LoadImage>
    <div class="config-panel">
      <h2>設定パネル</h2>
      <div>
        <label>
          操作モード：
          <select name="playing-mode" v-model="currentPlayingModeIndex">
            <option v-for="(playingModeListItem, index) in playingModeList" :value="index" :key="index">
              {{ playingModeListItem }}
            </option>
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
          <li v-for="(imageListItem, index) in imageList" :key="imageListItem.id" draggable="true"
            @dragstart="orderSlideShowOnDragStart(index)" @dragover.prevent @drop="orderSlideShowOnDrop(index)">
            <img :src="imageListItem.base64" alt="">
          </li>
        </TransitionGroup>
      </div>
    </div>
    <CommandBar v-if="isOpenCommandBar"></CommandBar>
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
