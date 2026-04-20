<script>
import { getDistanceFromLatLonInKm } from "../assets/geolocation_distance";
export default {
  name: "carparks-view",
  components: {

  },
  inject: [
    "headerH1",
    "sortMode",
  ],
  data() {
    return {
      carparks: [],
      position: {
        latitude: null,
        longitude: null,
      },
      isfocus: false,
      focusCarparkName: "",
    }
  },
  computed: {
    sortedCarparks() {
      switch (this.sortMode) {
        case 0:
          return this.carparks.toSorted((a, b) => a.name.localeCompare(b.name));
        case 1:
          return this.carparks.toSorted((a, b) => getDistanceFromLatLonInKm(this.position.latitude, this.position.longitude, a.latitude, a.longitude)
            - getDistanceFromLatLonInKm(this.position.latitude, this.position.longitude, b.latitude, b.longitude));
      }
    },
    pinnedCarparks() {
      return this.sortedCarparks.filter((carpark) => carpark.isPinned);
    },
    unpinnedCarparks() {
      return this.sortedCarparks.filter((carpark) => !carpark.isPinned);
    },
    focusCarpark() {
      return this.carparks.filter((carpark) => carpark.name === this.focusCarparkName)[0] || null;
    },
    focusCarparkDistance() {
      return getDistanceFromLatLonInKm(this.position.latitude, this.position.longitude, this.focusCarpark.latitude, this.focusCarpark.longitude);
    },
  },
  async created() {
    this.headerH1 = "Carpark availability";
    await this.getCarparks();
    await this.getLocaciton();
  },
  mounted() {

  },
  beforeUnmount() {

  },
  watch: {
    pinnedCarparks: {
      handler(nVal) {
        const pinnedCarparkNames = nVal.map((carpark) => carpark.name);
        localStorage.setItem("pinnedCarparkNames", JSON.stringify(pinnedCarparkNames));
      },
      deep: true,
    },
  },
  methods: {
    async getCarparks() {
      const url = "http://localhost:8080/module_d_api.php/carparks.json";
      try {
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`Response status: ${response.status}`);
        }
        const result = await response.json();
        for (const key in result) {
          if (!Object.hasOwn(result, key)) continue;
          const element = result[key];
          const pinnedCarparkNames = JSON.parse(localStorage.getItem("pinnedCarparkNames") ?? "[]");
          this.carparks.push({
            name: key,
            isPinned: pinnedCarparkNames.includes(key),
            ...element,
          });
        }
      } catch (error) {
        console.error(error.message);
      }
    },
    async getLocaciton() {
      return new Promise((resolve) => {
        if (this.$route.query.latitude != null && this.$route.query.longitude != null) {
          this.position.latitude = this.$route.query.latitude;
          this.position.longitude = this.$route.query.longitude;
          resolve();
        } else {
          navigator.geolocation.getCurrentPosition((position) => {
            this.position.latitude = position.coords.latitude;
            this.position.longitude = position.coords.longitude;
            resolve();
          });
        }
      });
    },
  },
}
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
