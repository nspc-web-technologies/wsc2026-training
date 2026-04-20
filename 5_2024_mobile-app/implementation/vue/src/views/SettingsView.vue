<script>
export default {
  name: "settings-view",
  components: {

  },
  inject: [
    "headerH1",
    "themeMode",
    "sortMode",
  ],
  data() {
    return {

    }
  },
  computed: {

  },
  async created() {
    this.headerH1 = "Setting";
  },
  mounted() {

  },
  beforeUnmount() {

  },
  watch: {

  },
  methods: {

  },
}
</script>

<template>
  <div class="settings-view">
    <p><label>theme : <select name="themeMode" id="themeMode" v-model.number="themeMode">
      <option value="0">dark theme</option>
      <option value="1">light theme</option>
      <option value="2">option to follow the system's</option>
    </select></label></p>
    <p><label>Carpark Sorting method : <select name="sortMode" id="sortMode" v-model.number="sortMode">
      <option value="0">alphabet</option>
      <option value="1">distance between the current location to each carpark</option>
    </select></label></p>
  </div>
</template>

<style scoped>
.settings-view {
  padding: 24px;
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 24px;
  height: 100%;
  overflow-y: auto;
}

.settings-view>* {
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 24px;
}

.settings-view>*>* {
  display: flex;
  flex-direction: column;
  align-items: start;
  gap: 8px;
}
</style>
