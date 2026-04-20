<script setup>
import { ref, reactive, computed, watch, inject } from "vue";
import { useRoute } from "vue-router";
import { getDistanceFromLatLonInKm } from "../assets/geolocation_distance";

const route = useRoute()
const headerH1 = inject("headerH1")
const sortMode = inject("sortMode")

const carparks = ref([])
const position = reactive({ latitude: null, longitude: null })
const isfocus = ref(false)
const focusCarparkName = ref("")

headerH1.value = "Carpark availability"

const sortedCarparks = computed(() => {
  switch (sortMode.value) {
    case 0:
      return carparks.value.toSorted((a, b) => a.name.localeCompare(b.name));
    case 1:
      return carparks.value.toSorted((a, b) =>
        getDistanceFromLatLonInKm(position.latitude, position.longitude, a.latitude, a.longitude)
        - getDistanceFromLatLonInKm(position.latitude, position.longitude, b.latitude, b.longitude));
  }
})

const pinnedCarparks = computed(() => sortedCarparks.value.filter((c) => c.isPinned))
const unpinnedCarparks = computed(() => sortedCarparks.value.filter((c) => !c.isPinned))
const focusCarpark = computed(() => carparks.value.find((c) => c.name === focusCarparkName.value) || null)
const focusCarparkDistance = computed(() =>
  getDistanceFromLatLonInKm(position.latitude, position.longitude, focusCarpark.value.latitude, focusCarpark.value.longitude))

watch(pinnedCarparks, (nVal) => {
  const pinnedCarparkNames = nVal.map((c) => c.name);
  localStorage.setItem("pinnedCarparkNames", JSON.stringify(pinnedCarparkNames));
}, { deep: true })

async function getCarparks() {
  const url = "http://localhost:8080/module_d_api.php/carparks.json";
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Response status: ${response.status}`);
    const result = await response.json();
    const pinnedCarparkNames = JSON.parse(localStorage.getItem("pinnedCarparkNames") ?? "[]");
    for (const key in result) {
      if (!Object.hasOwn(result, key)) continue;
      carparks.value.push({
        name: key,
        isPinned: pinnedCarparkNames.includes(key),
        ...result[key],
      });
    }
  } catch (error) {
    console.error(error.message);
  }
}

async function getLocation() {
  return new Promise((resolve) => {
    if (route.query.latitude != null && route.query.longitude != null) {
      position.latitude = route.query.latitude;
      position.longitude = route.query.longitude;
      resolve();
    } else {
      navigator.geolocation.getCurrentPosition((pos) => {
        position.latitude = pos.coords.latitude;
        position.longitude = pos.coords.longitude;
        resolve();
      });
    }
  });
}

getCarparks().then(() => getLocation())
</script>

<template>
  <div class="carparks-view">
    <ul v-if="!isfocus" class="carparks">
      <li v-for="carpark in [...pinnedCarparks, ...unpinnedCarparks]" :key="carpark.name">
        <div @click="isfocus = true; focusCarparkName = carpark.name;">
          <h2>{{ carpark.name }}</h2>
          <p>availableSpaces : {{ carpark.availableSpaces }}</p>
        </div>
        <p><label>pinned to top : <input type="checkbox" v-model="carpark.isPinned"></label></p>
      </li>
    </ul>
    <div v-else class="carpark">
      <button @click="isfocus = false; focusCarparkName = '';">Back</button>
      <p>name : {{ focusCarpark.name }}</p>
      <p>distance : {{ focusCarparkDistance }}km</p>
      <p>availableSpaces : {{ focusCarpark.availableSpaces }}</p>
    </div>
  </div>
</template>

<style scoped>
.carparks-view {
  padding: 24px;
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 24px;
  height: 100%;
  overflow-y: auto;
}

.carparks-view>* {
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 24px;
}

.carparks-view>*>*,
.carparks-view>*>*>* {
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 4px;
}

.carpark button {
  background: teal;
  color: #fff;
  border: none;
}
</style>
