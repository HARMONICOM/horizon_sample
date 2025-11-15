/** @jsxImportSource react */
import './index.css'

import { createRoot } from 'react-dom/client'
import {
    BrowserRouter,
    Route,
    Routes,
} from 'react-router-dom'

import { Admin } from './admin'

import { Index } from './index'

const AppRoutes = (props: any) => {  // eslint-disable-line @typescript-eslint/no-explicit-any
    return (
        <BrowserRouter>
            <Routes>
                <Route element={<Index {...props} />} path='/' />
                <Route element={<Admin {...props} />} path='/admin' />
            </Routes>
        </BrowserRouter>
    )
}

const start = () => {
    const root = document.getElementById('root')!
    const props = JSON.parse(root.dataset.props || '{}')
    const reactRoot = createRoot(root)
    reactRoot.render(<AppRoutes {...props} />)
}

window.onload = start
