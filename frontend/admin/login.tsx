/** @jsxImportSource react */


import { useState } from 'react'

type LoginProps = {
    error?: string;
    success?: string;
}

export const Login = (props: LoginProps) => {
    const [loginId, setLoginId] = useState('')
    const [password, setPassword] = useState('')
    const error = props.error || ''
    const success = props.success || ''

    const handleSubmit = () => {
        // バリデーションはHTML5のrequired属性で処理
        // バリデーションが通った場合、通常のフォーム送信を許可
        // e.preventDefault()を呼ばないことで、通常のフォーム送信が実行される
        // React Routerの干渉を回避するため、フォームのactionとmethodを設定済み
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
            <div className="bg-white rounded-xl shadow-2xl p-8 w-full max-w-md">
                <h1 className="text-3xl font-bold text-center text-gray-800 mb-8">
                    Admin Login
                </h1>

                {error && (
                    <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4">
                        {error}
                    </div>
                )}

                {success && (
                    <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg mb-4">
                        {success}
                    </div>
                )}

                <form action="/admin" method="POST" onSubmit={handleSubmit} target="_self">
                    <div className="mb-5">
                        <label className="block text-gray-700 font-medium mb-2" htmlFor="login_id">
                            Login ID
                        </label>
                        <input
                            className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-gray-400 transition-colors text-gray-900"
                            id="login_id"
                            name="login_id"
                            onChange={(e) => setLoginId(e.target.value)}
                            required
                            type="text"
                            value={loginId}
                        />
                    </div>

                    <div className="mb-6">
                        <label className="block text-gray-700 font-medium mb-2" htmlFor="password">
                            Password
                        </label>
                        <input
                            className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-gray-400 transition-colors text-gray-900"
                            id="password"
                            name="password"
                            onChange={(e) => setPassword(e.target.value)}
                            required
                            type="password"
                            value={password}
                        />
                    </div>

                    <button
                        className="w-full bg-gradient-to-r from-blue-500 to-blue-600 text-white font-semibold py-3 rounded-lg hover:from-blue-600 hover:to-blue-700 transition-all transform hover:-translate-y-0.5 shadow-lg hover:shadow-xl"
                        type="submit"
                    >
                        Login
                    </button>
                </form>

                <div className="mt-4 text-center">
                    <a
                        className="text-gray-600 hover:text-gray-700 underline text-sm transition-colors"
                        href="/admin/change-password"
                    >
                        Change Password
                    </a>
                </div>
            </div>
        </div>
    )
}

