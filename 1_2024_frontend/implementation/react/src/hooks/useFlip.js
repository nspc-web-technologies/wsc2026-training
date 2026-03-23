import { useRef, useLayoutEffect } from 'react'

// FLIP アニメーション用カスタムフック
// listRef: <ul> 等の親要素の ref
// deps: アニメーション発火の依存配列（例: [imageList]）
// 戻り値: recordRects — DOM 更新前に呼び出して各子要素の位置を記録する関数
export function useFlip(listRef, deps) {
  const rectsRef = useRef(new Map());

  function recordRects() {
    if (!listRef.current) return;
    for (const child of listRef.current.children) {
      rectsRef.current.set(child.dataset.id, child.getBoundingClientRect());
    }
  }

  useLayoutEffect(() => {
    if (!listRef.current || rectsRef.current.size === 0) return;
    for (const child of listRef.current.children) {
      const oldRect = rectsRef.current.get(child.dataset.id);
      if (!oldRect) continue;
      const newRect = child.getBoundingClientRect();
      const dy = oldRect.top - newRect.top;
      if (dy === 0) continue;
      child.style.transform = `translateY(${dy}px)`;
      child.style.transition = 'none';
      // reflow を強制して transform を即適用
      child.getBoundingClientRect();
      child.style.transform = '';
      child.style.transition = 'transform 0.5s ease';
    }
    rectsRef.current.clear();
  }, deps);

  return recordRects;
}
