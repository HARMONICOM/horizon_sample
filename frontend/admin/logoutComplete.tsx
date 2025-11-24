/** @jsxImportSource react */

import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

type LogoutCompleteProps = {
    error?: string;
    success?: string;
}

export const LogoutComplete = (props: LogoutCompleteProps) => {
    const navigate = useNavigate()
    const message = props.success || 'Logged out successfully'

    useEffect(() => {
        // Redirect to login page after 3 seconds
        const timer = setTimeout(() => {
            navigate('/admin')
        }, 3000)

        return () => clearTimeout(timer)
    }, [navigate])

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
            <div className="bg-white rounded-xl shadow-2xl p-8 w-full max-w-md">
                <h1 className="text-3xl font-bold text-center text-gray-800 mb-8">
                    Logout Complete
                </h1>

                {props.success && (
                    <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg mb-4">
                        {message}
                    </div>
                )}

                {props.error && (
                    <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4">
                        {props.error}
                    </div>
                )}

                <p className="text-gray-600 mb-6 text-center">
                    Redirecting to login page in 3 seconds
                </p>

                <a
                    className="w-full block bg-gradient-to-r from-blue-500 to-blue-600 text-white font-semibold py-3 rounded-lg hover:from-blue-600 hover:to-blue-700 transition-all transform hover:-translate-y-0.5 shadow-lg hover:shadow-xl text-center"
                    href="/admin"
                >
                    Back to Login
                </a>
            </div>
        </div>
    )
}

