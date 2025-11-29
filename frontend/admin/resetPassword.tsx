/** @jsxImportSource react */

import { useState } from 'react'

import type { FormEvent } from 'react'

type ResetPasswordProps = {
    error?: string;
    success?: string;
    token?: string;
}

export const ResetPassword = (props: ResetPasswordProps) => {
    const [newPassword, setNewPassword] = useState('')
    const [confirmPassword, setConfirmPassword] = useState('')
    const [error, setError] = useState(props.error || '')
    const [isSubmitting, setIsSubmitting] = useState(false)
    const success = props.success || ''
    const token = props.token || ''

    const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault()

        // Prevent double submission
        if (isSubmitting) {
            return
        }

        // Validation
        if (newPassword.length < 6) {
            setError('New password must be at least 6 characters')
            return
        }

        if (newPassword !== confirmPassword) {
            setError('New passwords do not match')
            return
        }

        // Set submitting state
        setIsSubmitting(true)

        // 一時的なフォームを作成してサブミット（React Routerを完全にバイパス）
        const tempForm = document.createElement('form')
        tempForm.method = 'POST'
        tempForm.action = '/admin/reset-password'
        tempForm.style.display = 'none'

        const tokenInput = document.createElement('input')
        tokenInput.type = 'hidden'
        tokenInput.name = 'token'
        tokenInput.value = token
        tempForm.appendChild(tokenInput)

        const passwordInput = document.createElement('input')
        passwordInput.type = 'hidden'
        passwordInput.name = 'new_password'
        passwordInput.value = newPassword
        tempForm.appendChild(passwordInput)

        const confirmInput = document.createElement('input')
        confirmInput.type = 'hidden'
        confirmInput.name = 'confirm_password'
        confirmInput.value = confirmPassword
        tempForm.appendChild(confirmInput)

        document.body.appendChild(tempForm)

        // ネイティブのsubmitメソッドを直接呼び出し（Reactの干渉を回避）
        // requestAnimationFrameを使用して、確実にDOMが更新された後に実行
        requestAnimationFrame(() => {
            HTMLFormElement.prototype.submit.call(tempForm)
        })
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
            <div className="bg-white rounded-xl shadow-2xl p-8 w-full max-w-md">
                <h1 className="text-3xl font-bold text-center text-gray-800 mb-8">
                    Password Reset
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

                <form onSubmit={handleSubmit}>
                    <div className="mb-5">
                        <label className="block text-gray-700 font-medium mb-2" htmlFor="new_password">
                            New Password
                        </label>
                        <input
                            className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-gray-400 transition-colors text-gray-900"
                            id="new_password"
                            minLength={6}
                            name="new_password"
                            onChange={(e) => setNewPassword(e.target.value)}
                            required
                            type="password"
                            value={newPassword}
                        />
                    </div>

                    <div className="mb-6">
                        <label className="block text-gray-700 font-medium mb-2" htmlFor="confirm_password">
                            Confirm New Password
                        </label>
                        <input
                            className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-gray-400 transition-colors text-gray-900"
                            id="confirm_password"
                            minLength={6}
                            name="confirm_password"
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            required
                            type="password"
                            value={confirmPassword}
                        />
                    </div>

                    <button
                        className="w-full bg-gradient-to-r from-blue-500 to-blue-600 text-white font-semibold py-3 rounded-lg hover:from-blue-600 hover:to-blue-700 transition-all transform hover:-translate-y-0.5 shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none disabled:shadow-lg"
                        disabled={isSubmitting}
                        type="submit"
                    >
                        {isSubmitting ? 'Changing Password...' : 'Change Password'}
                    </button>
                </form>

                <div className="mt-4 text-center">
                    <a
                        className="text-gray-600 hover:text-gray-700 underline text-sm transition-colors"
                        href="/admin"
                    >
                        ← Back to Login
                    </a>
                </div>
            </div>
        </div>
    )
}

