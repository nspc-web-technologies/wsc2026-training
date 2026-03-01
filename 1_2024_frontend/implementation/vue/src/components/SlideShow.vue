<script lang="js">
export default {
  name: "SlideShow",
  components: {

  },
  emits: [],
  inject: [
    "themeList",
    "currentThemeIndex",
    "imageList",
    "curenntImageIndex",
    "slideCount",
  ],
  data() {
    return {

    }
  },
  computed: {

  },
  created() {
    // omit: 非同期処理がないため async は不要。
  },
  mounted() {

  },
  beforeUnmount() {

  },
  watch: {

  },
  methods: {
    slideShowFullScreen() {
      if (!document.fullscreenElement) {
        this.$refs["slide-window"].requestFullscreen();
      } else {
        document.exitFullscreen?.();
      }
    },

  },
}
</script>

<template>
  <div class="slide-show" :class="`${themeList[currentThemeIndex].en}-slide-show`">
    <h1>スライドショー</h1>
    <div class="slide-window" ref="slide-window">
      <!-- smart: :name を動的バインドし、1つの <Transition> で全テーマに対応。
           知らなければテーマごとに v-if で <Transition> を6個書くことになる。 -->
      <Transition :name="`${themeList[currentThemeIndex].en}`">

        <template v-if="themeList[currentThemeIndex].en !== 'themeE'">
          <!-- fix: :style の * 10 を * 11 に変更。
               Math.floor(Math.random() * 10) は 0〜9 の整数を生成する。
               theme-d.css の rotate: calc(-5deg + calc(var(--r) * 1deg)) に代入すると -5deg〜+4deg になり、
               仕様「-5 degree to 5 degree」の +5deg に届かなかった。
               * 11 にすることで 0〜10 となり -5deg〜+5deg を実現できる。 -->
          <!-- tricky: curenntImageIndex だけだと同じ画像に戻ったとき key が同じになり Transition が発火しない。
               slideCount を加えることで常に異なる key になる。 -->
          <!-- smart: :style で CSS カスタムプロパティを注入。
               theme-d の var(--r) ランダム回転、theme-c の var(--i) 連鎖遅延を CSS 側の定義だけで実現。 -->
          <figure class="slide" :key="`${curenntImageIndex}-${slideCount}`"
            :style="`--r:${Math.floor(Math.random() * 11)};`">

            <img :src="imageList[curenntImageIndex]?.base64" :alt="imageList[curenntImageIndex]?.name">

            <figcaption>

              <template v-if="imageList[curenntImageIndex]?.name">
                <!-- remove: 元々は先頭以外の単語の前に <template v-if="index !== 0">&nbsp;</template> を挿入していたが、
                     {{ word }} の後ろにスペースを置くだけで同等の区切りを実現できる。
                     最後の単語の後ろにもスペースが付くが、figcaption の padding 内に収まるため視覚的に問題ない。 -->
                <span v-for="(word, index) in imageList[curenntImageIndex]?.name.split(' ')" :key="`${word}-${index}`"
                  :style="`--i:${index + 1}`">{{ word }} </span>
              </template>

              <template v-else>
                画像が設定されていません
              </template>

            </figcaption>
          </figure>
        </template>

        <template v-else>
          <div class="slide" :key="`${curenntImageIndex}-${slideCount}`">
            <img class="left" :src="imageList[curenntImageIndex]?.base64" :alt="imageList[curenntImageIndex]?.name">
            <img class="right" :src="imageList[curenntImageIndex]?.base64" :alt="imageList[curenntImageIndex]?.name">
          </div>
        </template>

      </Transition>
    </div>
    <!-- remove: button を包む <div> を削除。クラスもスタイルも付いていないため不要。 -->
    <button @click="slideShowFullScreen">フルスクリーン表示</button>
  </div>
</template>

<style scoped>
.slide-show {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.slide-window {
  width: 100%;
  height: 320px;
  border: 1px solid #acacac;
  background: #efefef;
  overflow: hidden;
  position: relative;
}

.slide {
  width: 100%;
  height: 100%;
  position: absolute;
}

.slide img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  position: absolute;
  z-index: 500;
}

.slide figcaption {
  position: absolute;
  background: #fff;
  bottom: 0;
  left: 0;
  padding: 8px;
  border-radius: 0 8px 0 0;
  z-index: 600;
}

/* tricky: inline 要素には transform が効かない。
 * inline-block にしないと Theme C の transform: translateY が動作しない。 */
.slide figcaption span {
  display: inline-block;
}
</style>