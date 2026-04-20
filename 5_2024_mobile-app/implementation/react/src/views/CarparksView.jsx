import { useState, useEffect, useMemo } from "react";
import { useSearchParams } from "react-router";
import { useAppContext } from "../AppContext";
import { getDistanceFromLatLonInKm } from "../assets/geolocation_distance";
import styles from "./CarparksView.module.css";

export default function CarparksView() {
  const { setHeaderH1, sortMode } = useAppContext();
  const [searchParams] = useSearchParams();
  const [carparks, setCarparks] = useState([]);
  const [position, setPosition] = useState({ latitude: null, longitude: null });
  const [isfocus, setIsfocus] = useState(false);
  const [focusCarparkName, setFocusCarparkName] = useState("");

  useEffect(() => {
    setHeaderH1("Carpark availability");
  }, []);

  useEffect(() => {
    (async () => {
      const url = "http://localhost:8080/module_d_api.php/carparks.json";
      try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`Response status: ${response.status}`);
        const result = await response.json();
        const pinnedCarparkNames = JSON.parse(localStorage.getItem("pinnedCarparkNames") ?? "[]");
        const list = [];
        for (const key in result) {
          if (!Object.hasOwn(result, key)) continue;
          list.push({
            name: key,
            isPinned: pinnedCarparkNames.includes(key),
            ...result[key],
          });
        }
        setCarparks(list);
      } catch (error) {
        console.error(error.message);
      }
    })();
  }, []);

  useEffect(() => {
    const lat = searchParams.get("latitude");
    const lon = searchParams.get("longitude");
    if (lat != null && lon != null) {
      setPosition({ latitude: Number(lat), longitude: Number(lon) });
    } else {
      navigator.geolocation.getCurrentPosition((pos) => {
        setPosition({ latitude: pos.coords.latitude, longitude: pos.coords.longitude });
      });
    }
  }, []);

  const sortedCarparks = useMemo(() => {
    switch (sortMode) {
      case 0:
        return carparks.toSorted((a, b) => a.name.localeCompare(b.name));
      case 1:
        return carparks.toSorted((a, b) =>
          getDistanceFromLatLonInKm(position.latitude, position.longitude, a.latitude, a.longitude)
          - getDistanceFromLatLonInKm(position.latitude, position.longitude, b.latitude, b.longitude)
        );
    }
  }, [carparks, sortMode, position]);

  const pinnedCarparks = useMemo(() => sortedCarparks.filter((c) => c.isPinned), [sortedCarparks]);
  const unpinnedCarparks = useMemo(() => sortedCarparks.filter((c) => !c.isPinned), [sortedCarparks]);

  const focusCarpark = useMemo(() => carparks.find((c) => c.name === focusCarparkName) || null, [carparks, focusCarparkName]);
  const focusCarparkDistance = useMemo(() => {
    if (!focusCarpark) return null;
    return getDistanceFromLatLonInKm(position.latitude, position.longitude, focusCarpark.latitude, focusCarpark.longitude);
  }, [focusCarpark, position]);

  function togglePin(name) {
    setCarparks((prev) => {
      const next = prev.map((c) => c.name === name ? { ...c, isPinned: !c.isPinned } : c);
      const pinnedNames = next.filter((c) => c.isPinned).map((c) => c.name);
      localStorage.setItem("pinnedCarparkNames", JSON.stringify(pinnedNames));
      return next;
    });
  }

  return (
    <div className={styles.carparksView}>
      {!isfocus ? (
        <ul className={styles.carparks}>
          {[...pinnedCarparks, ...unpinnedCarparks].map((carpark) => (
            <li key={carpark.name}>
              <div onClick={() => { setIsfocus(true); setFocusCarparkName(carpark.name); }}>
                <h2>{carpark.name}</h2>
                <p>availableSpaces : {carpark.availableSpaces}</p>
              </div>
              <p><label>pinned to top : <input type="checkbox" checked={carpark.isPinned} onChange={() => togglePin(carpark.name)} /></label></p>
            </li>
          ))}
        </ul>
      ) : (
        <div className={styles.carpark}>
          <button onClick={() => { setIsfocus(false); setFocusCarparkName(""); }}>Back</button>
          <p>name : {focusCarpark.name}</p>
          <p>distance : {focusCarparkDistance}km</p>
          <p>availableSpaces : {focusCarpark.availableSpaces}</p>
        </div>
      )}
    </div>
  );
}
