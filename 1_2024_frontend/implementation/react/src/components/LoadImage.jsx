import './LoadImage.css'

export default function LoadImage({ addImageList }) {
  // ファイルを加工してスライドに追加
  function readAndConvertImage(file) {
    const reader = new FileReader();
    reader.addEventListener("load", () => {
      // ファイル名からキャプションを生成
      let fileNameSplitList = file.name.split(/[ ._-]/);
      fileNameSplitList.pop();
      let fileName = fileNameSplitList.map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");
      addImageList(fileName, reader.result);
    });
    reader.readAsDataURL(file);
  }

  // ドロップしたものを解体 変換関数へ
  function loadImageDropHandler(ev) {
    ev.preventDefault();
    [...ev.dataTransfer.files].forEach(file => readAndConvertImage(file));
  }

  // インプットしたものを解体 変換関数へ
  function inputHandler(ev) {
    [...ev.target.files].forEach(file => readAndConvertImage(file));
  }

  function loadSampleImages() {
    const base = import.meta.env.BASE_URL;
    addImageList("Basilique Notre Dame De Fourviere Lyon", base + "images/basilique-notre-dame-de-fourviere-lyon.jpg");
    addImageList("Beautiful View In Lyon", base + "images/beautiful-view-in-lyon.jpg");
    addImageList("Place Bellecour Lyon", base + "images/place-bellecour-lyon.jpg");
    addImageList("Tour Metalique Lyon", base + "images/tour-metalique-lyon.jpg");
  }

  return (
    <div className="load-image">
      <h2>画像の読み込み</h2>

      <div
        onDrop={loadImageDropHandler}
        onDragOver={(e) => e.preventDefault()}
        className="drop-zone"
      >
        <p>画像をドラッグアンドドロップ</p>
      </div>

      <div className="input-file">
        <input type="file" onChange={inputHandler} multiple />
      </div>

      <button onClick={loadSampleImages}>サンプルを読み込む</button>
    </div>
  )
}
