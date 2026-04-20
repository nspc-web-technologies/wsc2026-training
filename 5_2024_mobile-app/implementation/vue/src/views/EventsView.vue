<script>
export default {
  name: "events-view",
  components: {

  },
  inject: [
    "headerH1",
  ],
  data() {
    return {
      events: [],
      beginningDate: "",
      endingDate: "",
    }
  },
  computed: {

  },
  async created() {
    this.headerH1 = "Lyon Events";
    await this.getEvents();
  },
  mounted() {

  },
  beforeUnmount() {

  },
  watch: {
    beginningDate(){
        this.getEvents();
    },
    endingDate(){
        this.getEvents();
    },
  },
  methods: {
    async getEvents() {
      const params = new URLSearchParams();
      if (this.beginningDate !== ""){
        params.append("beginning_date", this.beginningDate);
      }
      if (this.endingDate !== ""){
        params.append("ending_date", this.endingDate);
      }
      const url = `http://localhost:8080/module_d_api.php/events.json?${params}`;
      try {
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`Response status: ${response.status}`);
        }
        const result = await response.json();
        this.events = result;
      } catch (error) {
        console.error(error.message);
      }
    },
    async addEvents() {
      const url = `http://localhost:8080${this.events.pages.next}`;

      try {
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`Response status: ${response.status}`);
        }
        const result = await response.json();
        this.events.events.push(...result.events);
        this.events.pages = result.pages;
      } catch (error) {
        console.error(error.message);
      }
    },
    onscrollEvents(ev) {
      if (this.events.pages.next == null) return;
      if (Math.abs(ev.target.scrollHeight - ev.target.clientHeight - ev.target.scrollTop) <= 500) {
        this.addEvents();
      }
    },
  },
}
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
