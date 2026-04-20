import { createContext, useContext, useState } from "react";

const AppContext = createContext();

export function AppProvider({ children }) {
  const [headerH1, setHeaderH1] = useState("headerH1");
  const [themeMode, setThemeMode] = useState(0);
  const [sortMode, setSortMode] = useState(0);

  return (
    <AppContext.Provider value={{ headerH1, setHeaderH1, themeMode, setThemeMode, sortMode, setSortMode }}>
      {children}
    </AppContext.Provider>
  );
}

export function useAppContext() {
  return useContext(AppContext);
}
