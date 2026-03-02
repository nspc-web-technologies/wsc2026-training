import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  // add: 仕様書の「reachable at /XX_module_e/」に対応するため base を設定。
  // base を設定すると：
  //   1. ビルド後の JS/CSS の参照パスが /XX_module_e/assets/... になる
  //   2. router/index.js が createWebHistory(import.meta.env.BASE_URL) を使っているため、
  //      BASE_URL が自動的に /XX_module_e/ になり、ルーターも /XX_module_e/ 配下で動作する
  // base を設定しないと JS/CSS が /assets/... を参照してしまいサブパス配置で404になる
  base: '/XX_module_e/',
  plugins: [vue()],
})
