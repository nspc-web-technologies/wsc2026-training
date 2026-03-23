import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import './style.css'

import './theme-a.css'
import './theme-b.css'
import './theme-c.css'
import './theme-d.css'
import './theme-e.css'
import './theme-f.css'

import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <BrowserRouter basename={import.meta.env.BASE_URL}>
    <App />
  </BrowserRouter>
)
