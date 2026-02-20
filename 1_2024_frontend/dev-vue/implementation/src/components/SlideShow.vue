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
  async created() {

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
      <Transition :name="`${themeList[currentThemeIndex].en}`">

        <template v-if="themeList[currentThemeIndex].en !== 'themeE'">
          <figure class="slide" :key="`${curenntImageIndex}-${slideCount}`"
            :style="`--r:${Math.floor(Math.random() * 10)};`">

            <img :src="imageList[curenntImageIndex]?.base64" :alt="imageList[curenntImageIndex]?.name">

            <figcaption>

              <template v-if="imageList[curenntImageIndex]?.name">
                <span v-for="(word, index) in imageList[curenntImageIndex]?.name.split(' ')" :key="`${word}-${index}`"
                  :style="`--i:${index + 1}`">
                  <template v-if="index !== 0">&nbsp;</template>{{ word }}
                </span>
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
    <div><button @click="slideShowFullScreen">フルスクリーン表示</button></div>
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

.slide figcaption span {
  display: inline-block;
}
</style>