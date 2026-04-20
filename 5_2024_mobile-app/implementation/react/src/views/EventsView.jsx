import { useState, useEffect } from "react";
import { useAppContext } from "../AppContext";
import styles from "./EventsView.module.css";

export default function EventsView() {
  const { setHeaderH1 } = useAppContext();
  const [events, setEvents] = useState([]);
  const [beginningDate, setBeginningDate] = useState("");
  const [endingDate, setEndingDate] = useState("");

  useEffect(() => {
    setHeaderH1("Lyon Events");
  }, []);

  useEffect(() => {
    (async () => {
      const params = new URLSearchParams();
      if (beginningDate !== "") params.append("beginning_date", beginningDate);
      if (endingDate !== "") params.append("ending_date", endingDate);
      const url = `http://localhost:8080/module_d_api.php/events.json?${params}`;
      try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`Response status: ${response.status}`);
        const result = await response.json();
        setEvents(result);
      } catch (error) {
        console.error(error.message);
      }
    })();
  }, [beginningDate, endingDate]);

  async function addEvents() {
    if (events.pages?.next == null) return;
    const url = `http://localhost:8080${events.pages.next}`;
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error(`Response status: ${response.status}`);
      const result = await response.json();
      setEvents((prev) => ({
        ...prev,
        events: [...prev.events, ...result.events],
        pages: result.pages,
      }));
    } catch (error) {
      console.error(error.message);
    }
  }

  function onScroll(ev) {
    if (events.pages?.next == null) return;
    if (Math.abs(ev.target.scrollHeight - ev.target.clientHeight - ev.target.scrollTop) <= 500) {
      addEvents();
    }
  }

  return (
    <div className={styles.eventsView} onScroll={onScroll}>
      <div>
        <p><label>beginning date : <input type="date" value={beginningDate} onChange={(e) => setBeginningDate(e.target.value)} /></label></p>
        <p><label>ending date : <input type="date" value={endingDate} onChange={(e) => setEndingDate(e.target.value)} /></label></p>
      </div>
      <ul className={styles.events}>
        {events.events?.map((event) => (
          <li key={event.name}>
            <img src={`http://localhost:8080${event.image}`} alt={event.title} />
            <h2>{event.title}</h2>
            <p>date : {event.date}</p>
          </li>
        ))}
      </ul>
    </div>
  );
}
