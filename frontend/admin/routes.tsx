/** @jsxImportSource react */

import './index.css'

import { createRoot } from 'react-dom/client'
import {
    BrowserRouter,
    Route,
    Routes,
} from 'react-router-dom'

import { Admin } from './admin'
import { Login } from './login'
import { LogoutComplete } from './logoutComplete'
import { RequestPasswordReset } from './requestPasswordReset'
import { ResetPassword } from './resetPassword'


const AppRoutes = (props: any) => {  // eslint-disable-line @typescript-eslint/no-explicit-any
    return (
        <BrowserRouter>
            <Routes>
                <Route element={<Login {...props} />} path='/admin' />
                <Route element={<LogoutComplete {...props} />} path='/admin/logout-complete' />
                <Route element={<RequestPasswordReset {...props} />} path='/admin/change-password' />
                <Route element={<ResetPassword {...props} />} path='/admin/reset-password' />
                <Route element={<Admin {...props} />} path='/admin/dashboard' />
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
