import { useState, useRef, useEffect, useCallback } from 'react'
import SlideShow from '../components/SlideShow.jsx'
import LoadImage from '../components/LoadImage.jsx'
import CommandBar from '../components/CommandBar.jsx'
import { useFlip } from '../hooks/useFlip.js'
import './HomeView.css'

const themeList = [
  { ja: "テーマA", en: "themeA" },
  { ja: "テーマB", en: "themeB" },
  { ja: "テーマC", en: "themeC" },
  { ja: "テーマD", en: "themeD" },
  { ja: "テーマE", en: "themeE" },
  { ja: "テーマF", en: "themeF" },
];

export default function HomeView() {
  const [currentPlayingModeIndex, setCurrentPlayingModeIndex] = useState(0);
  const [currentThemeIndex, setCurrentThemeIndex] = useState(0);
  const [imageList, setImageList] = useState([]);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [slideCount, setSlideCount] = useState(0);
  const [isOpenCommandBar, setIsOpenCommandBar] = useState(false);
  const [isOpenConfigPanel, setIsOpenConfigPanel] = useState(false);

  const intervalIdRef = useRef(null);
  const nextImageListIdRef = useRef(1);
  const isDragedIdRef = useRef(null);
  const orderListRef = useRef(null);
  const recordRects = useFlip(orderListRef, [imageList]);

  // stale closure 対策: state を ref に同期
  const imageListRef = useRef(imageList);
  imageListRef.current = imageList;
  const currentImageIndexRef = useRef(currentImageIndex);
  currentImageIndexRef.current = currentImageIndex;
  const isOpenCommandBarRef = useRef(isOpenCommandBar);
  isOpenCommandBarRef.current = isOpenCommandBar;
  const currentPlayingModeIndexRef = useRef(currentPlayingModeIndex);
  currentPlayingModeIndexRef.current = currentPlayingModeIndex;

  // キーの重複防止: currentImageIndex が変わったら slideCount++ をレンダー中に同期実行
  // useEffect だと1フレーム遅れて slideKey が重複する可能性がある
  const prevImageIndexRef = useRef(currentImageIndex);
  if (prevImageIndexRef.current !== currentImageIndex) {
    prevImageIndexRef.current = currentImageIndex;
    setSlideCount(prev => prev + 1);
  }

  // 画像の追加
  const addImageList = useCallback((name, base64) => {
    setImageList(prev => [...prev, {
      id: nextImageListIdRef.current++,
      name,
      base64,
    }]);
  }, []);

  // 手動制御用 呼ばれるたび画像を変更 ループしない
  function manualSlideshow(delta) {
    if (imageListRef.current.length) {
      setCurrentImageIndex(prev =>
        Math.min(Math.max(0, prev + delta), imageListRef.current.length - 1)
      );
    }
  }

  // 自動再生用 setInterval前提 無限に再生
  function autoSlideshow() {
    if (imageListRef.current.length) {
      setCurrentImageIndex(prev =>
        (prev + 1) % imageListRef.current.length
      );
    }
  }

  // ランダム再生用 setInterval前提 無限に再生
  function randomSlideshow() {
    if (imageListRef.current.length > 1) {
      setCurrentImageIndex(prev => {
        let newIndex;
        do {
          newIndex = Math.floor(Math.random() * imageListRef.current.length);
        } while (prev === newIndex);
        return newIndex;
      });
    }
  }

  // 再生モードの変更 → setInterval の切り替え
  useEffect(() => {
    clearInterval(intervalIdRef.current);
    intervalIdRef.current = null;
    switch (currentPlayingModeIndex) {
      case 1:
        intervalIdRef.current = setInterval(autoSlideshow, 3000);
        break;
      case 2:
        intervalIdRef.current = setInterval(randomSlideshow, 3000);
        break;
    }
    return () => clearInterval(intervalIdRef.current);
  }, [currentPlayingModeIndex]);

  // キーボードリスナー
  useEffect(() => {
    function onKeydown(ev) {
      switch (ev.key) {
        case "ArrowLeft":
          if (currentPlayingModeIndexRef.current === 0 && !isOpenCommandBarRef.current) {
            ev.preventDefault();
            manualSlideshow(-1);
          }
          break;
        case "ArrowRight":
          if (currentPlayingModeIndexRef.current === 0 && !isOpenCommandBarRef.current) {
            ev.preventDefault();
            manualSlideshow(1);
          }
          break;
        case "k":
          if (ev.ctrlKey) {
            ev.preventDefault();
            setIsOpenCommandBar(true);
          }
          break;
        case "/":
          if (!isOpenCommandBarRef.current) {
            ev.preventDefault();
            setIsOpenCommandBar(true);
          }
          break;
        case "Escape":
          ev.preventDefault();
          setIsOpenCommandBar(false);
          break;
      }
    }
    addEventListener("keydown", onKeydown);
    return () => removeEventListener("keydown", onKeydown);
  }, []);

  // 写真の並び替え制御
  function orderSlideShowOnDragStart(index) {
    isDragedIdRef.current = index;
  }

  function orderSlideShowOnDrop(index) {
    recordRects();
    setImageList(prev => {
      const next = [...prev];
      const [movedImage] = next.splice(isDragedIdRef.current, 1);
      next.splice(index, 0, movedImage);
      return next;
    });
  }

  return (
    <div className="home-view">
      <SlideShow
        themeList={themeList}
        currentThemeIndex={currentThemeIndex}
        imageList={imageList}
        currentImageIndex={currentImageIndex}
        slideCount={slideCount}
      />
      <LoadImage addImageList={addImageList} />
      <button onClick={() => setIsOpenConfigPanel(prev => !prev)}>設定</button>
      <div className="config-panel" style={{ display: isOpenConfigPanel ? '' : 'none' }}>
        <h2>設定パネル</h2>
        <div>
          <label>
            操作モード：
            <select
              name="playing-mode"
              value={currentPlayingModeIndex}
              onChange={(e) => setCurrentPlayingModeIndex(Number(e.target.value))}
            >
              <option value={0}>手動制御</option>
              <option value={1}>自動再生</option>
              <option value={2}>ランダム再生</option>
            </select>
          </label>
        </div>
        <div>
          <label>
            テーマ：
            <select
              name="theme"
              value={currentThemeIndex}
              onChange={(e) => setCurrentThemeIndex(Number(e.target.value))}
            >
              {themeList.map((themeListItem, index) => (
                <option value={index} key={index}>
                  {themeListItem.ja}
                </option>
              ))}
            </select>
          </label>
        </div>
        <div className="order-slide-show">
          <span>写真の並び替え：</span>
          <ul ref={orderListRef}>
            {imageList.map((imageListItem, index) => (
              <li
                key={imageListItem.id}
                data-id={String(imageListItem.id)}
                draggable="true"
                onDragStart={() => orderSlideShowOnDragStart(index)}
                onDragOver={(e) => e.preventDefault()}
                onDrop={() => orderSlideShowOnDrop(index)}
              >
                <img src={imageListItem.base64} alt="" />
              </li>
            ))}
          </ul>
        </div>
      </div>
      {isOpenCommandBar && (
        <CommandBar
          setIsOpenCommandBar={setIsOpenCommandBar}
          setCurrentThemeIndex={setCurrentThemeIndex}
          setCurrentPlayingModeIndex={setCurrentPlayingModeIndex}
        />
      )}
    </div>
  )
}
