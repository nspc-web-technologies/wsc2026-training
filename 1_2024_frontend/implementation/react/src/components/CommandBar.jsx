import { useState, useMemo, useEffect, useRef } from 'react'
import './CommandBar.css'

const commandList = [
  "手動再生モードに切り替える",
  "自動再生モードに切り替える",
  "ランダム再生モードに切り替える",
  "テーマAに切り替える",
  "テーマBに切り替える",
  "テーマCに切り替える",
  "テーマDに切り替える",
  "テーマEに切り替える",
  "テーマFに切り替える",
];

export default function CommandBar({ setIsOpenCommandBar, setCurrentThemeIndex, setCurrentPlayingModeIndex }) {
  const [query, setQuery] = useState('');
  const [currentCommandIndex, setCurrentCommandIndex] = useState(0);

  const filteredCommandList = useMemo(() => {
    return commandList.filter(cmd => cmd.includes(query));
  }, [query]);

  // query が変わったら currentCommandIndex を 0 にリセット
  const prevQueryRef = useRef(query);
  if (prevQueryRef.current !== query) {
    prevQueryRef.current = query;
    if (currentCommandIndex !== 0) {
      setCurrentCommandIndex(0);
    }
  }

  // stale closure 対策: 最新値を ref に同期
  const filteredRef = useRef(filteredCommandList);
  filteredRef.current = filteredCommandList;
  const indexRef = useRef(currentCommandIndex);
  indexRef.current = currentCommandIndex;

  function executeCommand() {
    switch (filteredRef.current[indexRef.current]) {
      case "手動再生モードに切り替える":
        setCurrentPlayingModeIndex(0);
        break;
      case "自動再生モードに切り替える":
        setCurrentPlayingModeIndex(1);
        break;
      case "ランダム再生モードに切り替える":
        setCurrentPlayingModeIndex(2);
        break;
      case "テーマAに切り替える":
        setCurrentThemeIndex(0);
        break;
      case "テーマBに切り替える":
        setCurrentThemeIndex(1);
        break;
      case "テーマCに切り替える":
        setCurrentThemeIndex(2);
        break;
      case "テーマDに切り替える":
        setCurrentThemeIndex(3);
        break;
      case "テーマEに切り替える":
        setCurrentThemeIndex(4);
        break;
      case "テーマFに切り替える":
        setCurrentThemeIndex(5);
        break;
    }
    setIsOpenCommandBar(false);
  }

  useEffect(() => {
    function onKeydown(ev) {
      switch (ev.key) {
        case "ArrowUp":
          ev.preventDefault();
          setCurrentCommandIndex(prev => prev > 0 ? prev - 1 : prev);
          break;
        case "ArrowDown":
          ev.preventDefault();
          setCurrentCommandIndex(prev => prev < filteredRef.current.length - 1 ? prev + 1 : prev);
          break;
        case "Enter":
          ev.preventDefault();
          executeCommand();
          break;
      }
    }
    addEventListener("keydown", onKeydown);
    return () => removeEventListener("keydown", onKeydown);
  }, []);

  return (
    <div className="command-bar">
      <div className="command-bar-inner">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          autoFocus
          placeholder="コマンドを検索..."
        />
        <ul className="command-list">
          {filteredCommandList.map((item, i) => (
            <li key={i} className={currentCommandIndex === i ? 'currentCommand' : ''}>
              {item}
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}
