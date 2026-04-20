<script setup>
import { ref, inject, watch } from "vue";

const headerH1 = inject("headerH1")
const events = ref([])
const beginningDate = ref("")
const endingDate = ref("")

headerH1.value = "Lyon Events"

async function getEvents() {
  const params = new URLSearchParams();
  if (beginningDate.value !== "") params.append("beginning_date", beginningDate.value);
  if (endingDate.value !== "") params.append("ending_date", endingDate.value);
  const url = `http://localhost:8080/module_d_api.php/events.json?${params}`;
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Response status: ${response.status}`);
    events.value = await response.json();
  } catch (error) {
    console.error(error.message);
  }
}

async function addEvents() {
  const url = `http://localhost:8080${events.value.pages.next}`;
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Response status: ${response.status}`);
    const result = await response.json();
    events.value.events.push(...result.events);
    events.value.pages = result.pages;
  } catch (error) {
    console.error(error.message);
  }
}

function onscrollEvents(ev) {
  if (events.value.pages.next == null) return;
  if (Math.abs(ev.target.scrollHeight - ev.target.clientHeight - ev.target.scrollTop) <= 500) {
    addEvents();
  }
}

watch([beginningDate, endingDate], () => getEvents())

getEvents()
</script>

<template>
  <div class="events-view" @scroll="onscrollEvents">
    <div>
      <p><label>beginning date : <input type="date" name="beginningDate" id="beginningDate"
            v-model="beginningDate"></label></p>
      <p><label>ending date : <input type="date" name="endingDate" id="endingDate" v-model="endingDate"></label>
      </p>
    </div>
    <ul class="events">
      <li v-for="event in events.events" :key="event.name">
        <img :src="`http://localhost:8080${event.image}`" :alt="event.title">
        <h2>{{ event.title }}</h2>
        <p>date : {{ event.date }}</p>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.events-view {
  padding: 24px;
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 24px;
  height: 100%;
  overflow-y: auto;
}

.events-view>* {
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 24px;
}

.events-view>*>*,
.events-view>*>*>* {
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 8px;
}
</style>
