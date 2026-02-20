<script lang="js">
export default {
  name: "LoadImage",
  components: {

  },
  emits: [],
  inject: [
    "imageList",
    "addImageList",
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
    // ドロップしたものを解体 ファイルのみを変換関数へ
    loadImageDropHandler(ev) {
      ev.preventDefault();
      if (ev.dataTransfer.items) {
        [...ev.dataTransfer.items].forEach((item) => {
          if (item.kind === "file") {
            const file = item.getAsFile();
            this.readAndConvertImage(file)
          }
        });
      }
    },
    // インプットしたものを解体 変換関数へ
    inputHandler(ev) {
      [...ev.target.files].forEach((file) => {
        this.readAndConvertImage(file);
      })
    },
    // ファイルを加工してスライドに追加
    readAndConvertImage(file) {
      const reader = new FileReader();
      reader.addEventListener(
        "load",
        () => {
          // ファイル名からキャプションを生成
          let fileNameSplitList = file.name.split(/[ -\._]/);
          fileNameSplitList.pop();
          let fileName = fileNameSplitList.map((name) => {
            return name.split("").map((char, index) => {
              return index === 0 ? char.toUpperCase() : char;
            }).join("");
            }).join(" ");
          // スライドに追加
          this.addImageList(fileName, reader.result);
        },
        false,
      );
      if (file) {
        reader.readAsDataURL(file);
      }
    },
    loadSampleImages() {
      // 拡張性捨て 直接追加
      this.addImageList("Basilique Notre Dame De Fourviere Lyon", "/dist/images/basilique-notre-dame-de-fourviere-lyon.jpg");
      this.addImageList("Beautiful View In Lyon", "/dist/images/beautiful-view-in-lyon.jpg");
      this.addImageList("Place Bellecour Lyon", "/dist/images/place-bellecour-lyon.jpg");
      this.addImageList("Tour Metalique Lyon", "/dist/images/tour-metalique-lyon.jpg");
    },
  },
}
</script>

<template>
  <div class="load-image">
    <h2>画像の読み込み</h2>

    <div @drop="loadImageDropHandler" @dragover.prevent class="drop-zone">
      <p>画像をドラッグアンドドロップ</p>
    </div>

    <div class="input-file">
      <input type="file" @input="inputHandler" multiple>
    </div>

    <div>
      <button @click="loadSampleImages">サンプルを読み込む</button>
    </div>
  </div>
</template>

<style scoped>
.load-image {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.drop-zone {
  border: 2px dashed #acacac;
  background: #efefef;
  width: fit-content;
  padding: 32px;
}

/* CSSが無効になった時出現 */
.input-file {
  display: none;
}
</style>
