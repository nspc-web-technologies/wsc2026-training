import { useEffect } from "react";
import { useAppContext } from "../AppContext";
import styles from "./SettingsView.module.css";

export default function SettingsView() {
  const { setHeaderH1, themeMode, setThemeMode, sortMode, setSortMode } = useAppContext();

  useEffect(() => {
    setHeaderH1("Setting");
  }, []);

  return (
    <div className={styles.settingsView}>
      <p><label>theme : <select value={themeMode} onChange={(e) => setThemeMode(Number(e.target.value))}>
        <option value={0}>dark theme</option>
        <option value={1}>light theme</option>
        <option value={2}>option to follow the system's</option>
      </select></label></p>
      <p><label>Carpark Sorting method : <select value={sortMode} onChange={(e) => setSortMode(Number(e.target.value))}>
        <option value={0}>alphabet</option>
        <option value={1}>distance between the current location to each carpark</option>
      </select></label></p>
    </div>
  );
}
