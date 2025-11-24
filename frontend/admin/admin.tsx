/** @jsxImportSource react */

import type { FormEvent } from 'react'

type User = {
    email: string;
    id: string;
    name: string;
}

type AdminProps = {
    message: string;
    user_email?: string;
    users?: User[];
}

export const Admin = (props: AdminProps) => {
    const users = props.users || []
    const userEmail = props.user_email || 'Unknown'

    const handleLogout = async (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        const formData = new FormData()
        try {
            const response = await fetch('/admin/logout', {
                body: formData,
                method: 'POST',
            })
            if (response.redirected) {
                window.location.href = response.url
            }
        } catch (err) {
            console.error('Logout failed:', err)
        }
    }

    return (
        <div className="min-h-screen bg-gray-100 p-6">
            <div className="max-w-7xl mx-auto">
                <div className="bg-white rounded-lg shadow-md p-6 mb-6">
                    <div className="flex justify-between items-center">
                        <h1 className="text-2xl font-bold text-gray-800">{props.message}</h1>
                        <div className="flex items-center gap-4">
                            <span className="text-gray-600">{userEmail}</span>
                            <div className="flex gap-2">
                                <a
                                    className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                                    href="/admin/change-password"
                                >
                                    Change Password
                                </a>
                                <form className="inline" onSubmit={handleLogout}>
                                    <button
                                        className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                                        type="submit"
                                    >
                                        Logout
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="bg-white rounded-lg shadow-md p-6">
                    <h2 className="text-xl font-bold text-gray-800 mb-4">User List</h2>
                    {users.length > 0 ? (
                        <div className="overflow-x-auto">
                            <table className="min-w-full bg-white border border-gray-300">
                                <thead className="bg-gray-100">
                                    <tr>
                                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider border-b">
                                            ID
                                        </th>
                                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider border-b">
                                            Name
                                        </th>
                                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider border-b">
                                            Email
                                        </th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-200">
                                    {users.map((user) => (
                                        <tr className="hover:bg-gray-50" key={user.id}>
                                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                                {user.id}
                                            </td>
                                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                                {user.name}
                                            </td>
                                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                                {user.email}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    ) : (
                        <div className="text-gray-500 text-center py-8">
                            No users found
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}
