<script setup>
import { ref, computed, provide } from "vue";

const headerH1 = ref("headerH1")
const themeMode = ref(0)
const sortMode = ref(0)

provide("headerH1", headerH1)
provide("themeMode", themeMode)
provide("sortMode", sortMode)

const theme = computed(() => {
  switch (themeMode.value) {
    case 0: return "dark"
    case 1: return "light"
    case 2: return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }
})
</script>

<template>
  <div :class="`${theme}-theme`">
    <header>
      <button @click="$router.back()">Back</button>
      <h1>{{ headerH1 }}</h1>
    </header>
    <main>
      <RouterView />
    </main>
    <footer>
      <ul>
        <li>
          <RouterLink to="/carparks">Carparks</RouterLink>
        </li>
        <li>
          <RouterLink to="/events">Events</RouterLink>
        </li>
        <li>
          <RouterLink to="/weathers">Weathers</RouterLink>
        </li>
        <li>
          <RouterLink to="/settings">Settings</RouterLink>
        </li>
      </ul>
    </footer>
  </div>
</template>

<style>
html:has(.dark-theme) {
  filter: invert(1) hue-rotate(180deg);
}

html:has(.dark-theme) img {
  filter: invert(1) hue-rotate(180deg);
}

header {
  height: 80px;
  display: flex;
  justify-content: space-evenly;
  align-items: center;
  position: absolute;
  width: 100%;
  top: 0;
  left: 0;
  background: #fff;
  border-bottom: 1px solid #acacac;
}

header button {
  border: none;
  background: royalblue;
  color: #fff;
}

main {
  height: 100vh;
  padding: 80px 0 53px;
}

footer {
  position: absolute;
  left: 0;
  bottom: 0;
  width: 100%;
  background: #fff;
  border-top: 1px solid #acacac;
}

footer ul {
  display: flex;
}

footer ul li {
  flex-grow: 1;
}

footer ul li a {
  width: 100%;
  text-align: center;
  padding: 16px;
}
</style>
