import { useRef, useMemo } from 'react'
import { TransitionGroup, CSSTransition } from 'react-transition-group'
import './SlideShow.css'

const themeTimeouts = {
  themeA: 0,
  themeB: 800,
  themeC: 2000,
  themeD: 800,
  themeE: 500,
  themeF: 1500,
};

export default function SlideShow({ themeList, currentThemeIndex, imageList, currentImageIndex, slideCount }) {
  const slideWindowRef = useRef(null);

  const currentTheme = themeList[currentThemeIndex].en;
  const slideKey = `${currentImageIndex}-${slideCount}`;
  const timeout = themeTimeouts[currentTheme] || 0;

  // key 変更ごとに新しい ref を生成
  // TransitionGroup は前回レンダーの要素を内部 state に保持し、exit 時にそれを clone する。
  // そのため exit 中の CSSTransition は前回レンダー時の ref オブジェクトをそのまま持ち、
  // .current が旧 DOM ノードを指し続けるので exit アニメーションは正常に動作する。
  const nodeRef = useMemo(() => ({ current: null }), [slideKey]);

  // --r のランダム値をスライドごとに1回だけ生成
  const randomR = useMemo(() => Math.floor(Math.random() * 11), [slideKey]);

  function slideShowFullScreen() {
    if (!document.fullscreenElement) {
      slideWindowRef.current?.requestFullscreen();
    } else {
      document.exitFullscreen?.();
    }
  }

  const currentImage = imageList[currentImageIndex];
  const isThemeE = currentTheme === 'themeE';

  return (
    <div className={`slide-show ${currentTheme}-slide-show`}>
      <h1>スライドショー</h1>
      <div className="slide-window" ref={slideWindowRef}>
        <TransitionGroup component={null}>
          <CSSTransition
            key={slideKey}
            classNames={currentTheme}
            timeout={timeout}
            nodeRef={nodeRef}
          >
            {isThemeE ? (
              <div className="slide" ref={nodeRef}>
                <img className="left" src={currentImage?.base64} alt={currentImage?.name} />
                <img className="right" src={currentImage?.base64} alt={currentImage?.name} />
              </div>
            ) : (
              <figure className="slide" ref={nodeRef} style={{ '--r': randomR }}>
                <img src={currentImage?.base64} alt={currentImage?.name} />
                <figcaption>
                  {currentImage?.name ? (
                    currentImage.name.split(' ').map((word, index) => (
                      <span key={`${word}-${index}`} style={{ '--i': index + 1 }}>{word} </span>
                    ))
                  ) : (
                    '画像が設定されていません'
                  )}
                </figcaption>
              </figure>
            )}
          </CSSTransition>
        </TransitionGroup>
      </div>
      <button onClick={slideShowFullScreen}>フルスクリーン表示</button>
    </div>
  )
}
