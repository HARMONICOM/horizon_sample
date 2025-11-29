/** @jsxImportSource react */

import { useState } from 'react'

import type { FormEvent } from 'react'

type RequestPasswordResetProps = {
    error?: string;
    success?: string;
}

export const RequestPasswordReset = (props: RequestPasswordResetProps) => {
    const [isSubmitting, setIsSubmitting] = useState(false)
    const error = props.error || ''
    const success = props.success || ''

    const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
        // Prevent double submission
        if (isSubmitting) {
            e.preventDefault()
            return
        }
        setIsSubmitting(true)
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

                <form action="/admin/change-password/submit" method="POST" onSubmit={handleSubmit}>
                    <div className="mb-5">
                        <label className="block text-gray-700 font-medium mb-2" htmlFor="email">
                            Email Address
                        </label>
                        <input
                            className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-gray-400 transition-colors text-gray-900"
                            id="email"
                            name="email"
                            readOnly={isSubmitting}
                            required
                            type="email"
                        />
                        <p className="mt-2 text-sm text-gray-600">
                            Please enter your registered email address. We will send a password reset link.
                        </p>
                    </div>

                    <button
                        className="w-full bg-gradient-to-r from-blue-500 to-blue-600 text-white font-semibold py-3 rounded-lg hover:from-blue-600 hover:to-blue-700 transition-all transform hover:-translate-y-0.5 shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none disabled:shadow-lg"
                        disabled={isSubmitting}
                        type="submit"
                    >
                        {isSubmitting ? 'Sending...' : 'Send Reset Email'}
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

