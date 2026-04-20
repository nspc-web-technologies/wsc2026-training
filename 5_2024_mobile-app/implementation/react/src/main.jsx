import { createRoot } from "react-dom/client";
import { BrowserRouter, Routes, Route, Navigate } from "react-router";
import "./style.css";
import App from "./App";
import CarparksView from "./views/CarparksView";
import EventsView from "./views/EventsView";
import WeathersView from "./views/WeathersView";
import SettingsView from "./views/SettingsView";

createRoot(document.getElementById("app")).render(
  <BrowserRouter basename={import.meta.env.BASE_URL}>
    <Routes>
      <Route element={<App />}>
        <Route index element={<Navigate to="/carparks" replace />} />
        <Route path="carparks" element={<CarparksView />} />
        <Route path="events" element={<EventsView />} />
        <Route path="weathers" element={<WeathersView />} />
        <Route path="settings" element={<SettingsView />} />
      </Route>
    </Routes>
  </BrowserRouter>
);
