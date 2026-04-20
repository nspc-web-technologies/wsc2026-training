import { useMemo } from "react";
import { Outlet, NavLink, useNavigate } from "react-router";
import { AppProvider, useAppContext } from "./AppContext";
import styles from "./App.module.css";

function AppLayout() {
  const { headerH1, themeMode } = useAppContext();
  const navigate = useNavigate();

  const theme = useMemo(() => {
    switch (themeMode) {
      case 0:
        return "dark";
      case 1:
        return "light";
      case 2:
        return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }
  }, [themeMode]);

  return (
    <div className={`${theme}-theme`}>
      <header className={styles.header}>
        <button onClick={() => navigate(-1)}>Back</button>
        <h1>{headerH1}</h1>
      </header>
      <main className={styles.main}>
        <Outlet />
      </main>
      <footer className={styles.footer}>
        <ul>
          <li><NavLink to="/carparks">Carparks</NavLink></li>
          <li><NavLink to="/events">Events</NavLink></li>
          <li><NavLink to="/weathers">Weathers</NavLink></li>
          <li><NavLink to="/settings">Settings</NavLink></li>
        </ul>
      </footer>
    </div>
  );
}

export default function App() {
  return (
    <AppProvider>
      <AppLayout />
    </AppProvider>
  );
}
