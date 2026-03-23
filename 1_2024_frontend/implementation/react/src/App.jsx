import { Routes, Route } from 'react-router-dom'
import HomeView from './views/HomeView.jsx'

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<HomeView />} />
    </Routes>
  )
}
