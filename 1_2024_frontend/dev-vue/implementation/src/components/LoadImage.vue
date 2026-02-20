<script lang="js">
export default {
  name: "LoadImage",
  components: {

  },
  emits: [],
  inject: [
    // remove: 元々 "imageList" も inject していたが、LoadImage では imageList を参照しない。
    // 未使用の inject は冗長なため、不要なものは除外する。
    "addImageList",
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
    // ドロップしたものを解体 変換関数へ
    // omit: 元々は ev.dataTransfer.items を経由して item.kind === "file" チェック → getAsFile() していたが、
    // ev.dataTransfer.files を直接使えば FileList（ファイルのみ）が得られるため同等の結果で短く書ける。
    // FileList の各要素は必ず File オブジェクトで null や undefined が混入することはない。
    loadImageDropHandler(ev) {
      ev.preventDefault();
      [...ev.dataTransfer.files].forEach(file => this.readAndConvertImage(file));
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
      // omit: addEventListener の第3引数 false を削除。false はデフォルト値のため省略可。
      reader.addEventListener(
        "load",
        () => {
          // ファイル名からキャプションを生成
          // omit: 元々は二重ネストの map（外側で単語分割、内側で charAt(0).toUpperCase()）だったが、
          // charAt(0).toUpperCase() + slice(1) を使えば 1つの map でまとめて書ける。
          // split(/[ ._-]/) でスペース・ドット・アンダースコア・ハイフンを区切り文字として分割する。
          // ハイフンは文字クラスの末尾に置くことでリテラルとして扱われる。
          // pop() で拡張子部分（最後の要素）を除去してからキャプション文字列に結合する。
          // 例: "beautiful-view_in.lyon.jpg"
          //   → split → ["beautiful", "view", "in", "lyon", "jpg"]
          //   → pop  → ["beautiful", "view", "in", "lyon"]
          //   → map  → ["Beautiful", "View", "In", "Lyon"]
          //   → join → "Beautiful View In Lyon"
          let fileNameSplitList = file.name.split(/[ ._-]/);
          fileNameSplitList.pop();
          let fileName = fileNameSplitList.map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");
          // スライドに追加
          this.addImageList(fileName, reader.result);
        },
      );
      // remove: if (file) ガードを削除。
      // FileList の各要素は必ず File オブジェクトで null や undefined が混入することはないため不要。
      reader.readAsDataURL(file);
    },
    loadSampleImages() {
      // 拡張性捨て 直接追加
      // fix: 元々は "/dist/images/..." とハードコードしていたが、2点修正。
      // 1. import.meta.env.BASE_URL をプレフィックスに使う。
      //    vite.config.js の base を設定しても JS 内のパス文字列には自動付与されないため。
      // 2. 画像の配置先を public/dist/images/ → public/images/ に変更。
      //    dist はビルド出力のディレクトリ名と紛らわしいため。
      const base = import.meta.env.BASE_URL;
      this.addImageList("Basilique Notre Dame De Fourviere Lyon", base + "images/basilique-notre-dame-de-fourviere-lyon.jpg");
      this.addImageList("Beautiful View In Lyon", base + "images/beautiful-view-in-lyon.jpg");
      this.addImageList("Place Bellecour Lyon", base + "images/place-bellecour-lyon.jpg");
      this.addImageList("Tour Metalique Lyon", base + "images/tour-metalique-lyon.jpg");
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

    <!-- remove: button を包む <div> を削除。クラスもスタイルも付いていないため不要。 -->
    <button @click="loadSampleImages">サンプルを読み込む</button>
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
