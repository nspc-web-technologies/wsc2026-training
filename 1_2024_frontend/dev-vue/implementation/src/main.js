import { createApp } from 'vue'
import './style.css'

// メンテナンスしやすいように分離
import './theme-a.css'
import './theme-b.css'
import './theme-c.css'
import './theme-d.css'
import './theme-e.css'
import './theme-f.css'

import router from "./router";
import App from './App.vue'

createApp(App).use(router).mount('#app')
