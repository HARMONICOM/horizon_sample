/** @jsxImportSource react */

import { useState, type FormEvent } from 'react'

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
    const [userList, setUserList] = useState<User[]>(users)
    const userEmail = props.user_email || 'Unknown'

    const [editingUser, setEditingUser] = useState<User | null>(null)
    const [editName, setEditName] = useState('')
    const [editEmail, setEditEmail] = useState('')
    const [isEditOpen, setIsEditOpen] = useState(false)

    const [deletingUser, setDeletingUser] = useState<User | null>(null)
    const [isDeleteOpen, setIsDeleteOpen] = useState(false)

    const [isCreateOpen, setIsCreateOpen] = useState(false)
    const [createName, setCreateName] = useState('')
    const [createEmail, setCreateEmail] = useState('')
    const [createLoginId, setCreateLoginId] = useState('')
    const [createPassword, setCreatePassword] = useState('')

    const [isSubmitting, setIsSubmitting] = useState(false)

    const handleLogout = async (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        const formData = new FormData()
        try {
            const response = await fetch('/admin/logout', {
                body: formData,
                method: 'POST',
                credentials: 'same-origin',
            })
            if (response.redirected) {
                window.location.href = response.url
            }
        } catch (err) {
            console.error('Logout failed:', err)
        }
    }

    // Open edit dialog with user data
    const openEditDialog = (user: User) => {
        setEditingUser(user)
        setEditName(user.name)
        setEditEmail(user.email)
        setIsEditOpen(true)
    }

    // Close edit dialog and reset state
    const closeEditDialog = () => {
        setIsEditOpen(false)
        setEditingUser(null)
        setEditName('')
        setEditEmail('')
    }

    // Open delete confirmation dialog
    const openDeleteDialog = (user: User) => {
        setDeletingUser(user)
        setIsDeleteOpen(true)
    }

    // Close delete confirmation dialog
    const closeDeleteDialog = () => {
        setIsDeleteOpen(false)
        setDeletingUser(null)
    }

    // Open create user dialog
    const openCreateDialog = () => {
        setIsCreateOpen(true)
        setCreateName('')
        setCreateEmail('')
        setCreateLoginId('')
        setCreatePassword('')
    }

    // Close create user dialog
    const closeCreateDialog = () => {
        setIsCreateOpen(false)
        setCreateName('')
        setCreateEmail('')
        setCreateLoginId('')
        setCreatePassword('')
    }

    // Handle save edit: send update request to backend
    const handleSaveEdit = async (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        if (!editingUser) return
        setIsSubmitting(true)
        // Use URLSearchParams for application/x-www-form-urlencoded format
        const params = new URLSearchParams()
        params.append('id', editingUser.id)
        params.append('name', editName)
        params.append('email', editEmail)
        try {
            const response = await fetch('/admin/dashboard/users/update', {
                body: params.toString(),
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                method: 'POST',
                credentials: 'same-origin',
            })
            if (!response.ok) {
                const errorText = await response.text()
                console.error('Failed to update user:', response.status, errorText)
                alert(`Failed to update user: ${response.status} ${errorText}`)
                return
            }
            // Update user list with new data
            setUserList((prev) =>
                prev.map((u) =>
                    u.id === editingUser.id ? { ...u, email: editEmail, name: editName } : u,
                ),
            )
            closeEditDialog()
        } catch (err) {
            console.error('Update failed:', err)
            alert(`Update failed: ${err instanceof Error ? err.message : 'Unknown error'}`)
        } finally {
            setIsSubmitting(false)
        }
    }

    // Handle delete confirmation: send delete request to backend
    const handleConfirmDelete = async () => {
        if (!deletingUser) return
        setIsSubmitting(true)
        // Use URLSearchParams for application/x-www-form-urlencoded format
        const params = new URLSearchParams()
        params.append('id', deletingUser.id)
        try {
            const response = await fetch('/admin/dashboard/users/delete', {
                method: 'POST',
                body: params.toString(),
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                credentials: 'same-origin',
            })
            if (!response.ok) {
                const errorText = await response.text()
                console.error('Failed to delete user:', response.status, errorText)
                alert(`Failed to delete user: ${response.status} ${errorText}`)
                return
            }
            // Remove deleted user from list
            setUserList((prev) => prev.filter((u) => u.id !== deletingUser.id))
            closeDeleteDialog()
        } catch (err) {
            console.error('Delete failed:', err)
            alert(`Delete failed: ${err instanceof Error ? err.message : 'Unknown error'}`)
        } finally {
            setIsSubmitting(false)
        }
    }

    // Handle create user: send create request to backend
    const handleCreateUser = async (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        setIsSubmitting(true)
        // Use URLSearchParams for application/x-www-form-urlencoded format
        const params = new URLSearchParams()
        params.append('name', createName)
        params.append('email', createEmail)
        params.append('login_id', createLoginId)
        params.append('password', createPassword)
        try {
            const response = await fetch('/admin/dashboard/users/create', {
                method: 'POST',
                body: params.toString(),
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                credentials: 'same-origin',
            })
            if (!response.ok) {
                const errorText = await response.text()
                console.error('Failed to create user:', response.status, errorText)
                alert(`Failed to create user: ${response.status} ${errorText}`)
                return
            }
            const responseData = await response.json()
            // Reload the page to show the new user
            window.location.reload()
        } catch (err) {
            console.error('Create failed:', err)
            alert(`Create failed: ${err instanceof Error ? err.message : 'Unknown error'}`)
        } finally {
            setIsSubmitting(false)
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
                    <div className="flex justify-between items-center mb-4">
                        <h2 className="text-xl font-bold text-gray-800">User List</h2>
                        <button
                            className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                            onClick={openCreateDialog}
                            type="button"
                        >
                            Add New User
                        </button>
                    </div>
                    {userList.length > 0 ? (
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
                                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider border-b">
                                            Actions
                                        </th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-200">
                                    {userList.map((user) => (
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
                                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                                <div className="flex gap-2">
                                                    <button
                                                        className="px-3 py-1 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors text-xs"
                                                        onClick={() => openEditDialog(user)}
                                                        type="button"
                                                    >
                                                        Edit
                                                    </button>
                                                    <button
                                                        className="px-3 py-1 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors text-xs"
                                                        onClick={() => openDeleteDialog(user)}
                                                        type="button"
                                                    >
                                                        Delete
                                                    </button>
                                                </div>
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

                {isEditOpen && editingUser && (
                    <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
                        <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
                            <h3 className="text-lg font-semibold mb-4 text-gray-900">Edit User</h3>
                            <form onSubmit={handleSaveEdit}>
                                <div className="mb-4">
                                    <label className="block text-sm font-medium text-gray-900 mb-1" htmlFor="edit-name">
                                        Name
                                    </label>
                                    <input
                                        className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm text-gray-900"
                                        id="edit-name"
                                        onChange={(e) => setEditName(e.target.value)}
                                        value={editName}
                                    />
                                </div>
                                <div className="mb-4">
                                    <label className="block text-sm font-medium text-gray-900 mb-1" htmlFor="edit-email">
                                        Email
                                    </label>
                                    <input
                                        className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm text-gray-900"
                                        id="edit-email"
                                        onChange={(e) => setEditEmail(e.target.value)}
                                        type="email"
                                        value={editEmail}
                                    />
                                </div>
                                <div className="flex justify-end gap-2">
                                    <button
                                        className="px-4 py-2 rounded-md border border-gray-300 text-gray-900 text-sm hover:bg-gray-100"
                                        disabled={isSubmitting}
                                        onClick={closeEditDialog}
                                        type="button"
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        className="px-4 py-2 rounded-md bg-blue-600 text-white text-sm hover:bg-blue-700 disabled:bg-blue-300"
                                        disabled={isSubmitting}
                                        type="submit"
                                    >
                                        Save
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                )}

                {isDeleteOpen && deletingUser && (
                    <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
                        <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
                            <h3 className="text-lg font-semibold mb-4 text-gray-900">Delete User</h3>
                            <p className="mb-4 text-sm text-gray-900">
                                Are you sure you want to delete user "
                                <span className="font-semibold">{deletingUser.name}</span>"?
                            </p>
                            <div className="flex justify-end gap-2">
                                <button
                                    className="px-4 py-2 rounded-md border border-gray-300 text-gray-900 text-sm hover:bg-gray-100"
                                    disabled={isSubmitting}
                                    onClick={closeDeleteDialog}
                                    type="button"
                                >
                                    Cancel
                                </button>
                                <button
                                    className="px-4 py-2 rounded-md bg-red-600 text-white text-sm hover:bg-red-700 disabled:bg-red-300"
                                    disabled={isSubmitting}
                                    onClick={handleConfirmDelete}
                                    type="button"
                                >
                                    Delete
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                {isCreateOpen && (
                    <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
                        <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
                            <h3 className="text-lg font-semibold mb-4 text-gray-900">Add New User</h3>
                            <form onSubmit={handleCreateUser}>
                                <div className="mb-4">
                                    <label className="block text-sm font-medium text-gray-900 mb-1" htmlFor="create-name">
                                        Name
                                    </label>
                                    <input
                                        className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm text-gray-900"
                                        id="create-name"
                                        onChange={(e) => setCreateName(e.target.value)}
                                        value={createName}
                                        required
                                    />
                                </div>
                                <div className="mb-4">
                                    <label className="block text-sm font-medium text-gray-900 mb-1" htmlFor="create-email">
                                        Email
                                    </label>
                                    <input
                                        className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm text-gray-900"
                                        id="create-email"
                                        onChange={(e) => setCreateEmail(e.target.value)}
                                        type="email"
                                        value={createEmail}
                                        required
                                    />
                                </div>
                                <div className="mb-4">
                                    <label className="block text-sm font-medium text-gray-900 mb-1" htmlFor="create-login-id">
                                        Login ID
                                    </label>
                                    <input
                                        className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm text-gray-900"
                                        id="create-login-id"
                                        onChange={(e) => setCreateLoginId(e.target.value)}
                                        value={createLoginId}
                                        required
                                    />
                                </div>
                                <div className="mb-4">
                                    <label className="block text-sm font-medium text-gray-900 mb-1" htmlFor="create-password">
                                        Password
                                    </label>
                                    <input
                                        className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm text-gray-900"
                                        id="create-password"
                                        onChange={(e) => setCreatePassword(e.target.value)}
                                        type="password"
                                        value={createPassword}
                                        required
                                    />
                                </div>
                                <div className="flex justify-end gap-2">
                                    <button
                                        className="px-4 py-2 rounded-md border border-gray-300 text-gray-900 text-sm hover:bg-gray-100"
                                        disabled={isSubmitting}
                                        onClick={closeCreateDialog}
                                        type="button"
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        className="px-4 py-2 rounded-md bg-green-600 text-white text-sm hover:bg-green-700 disabled:bg-green-300"
                                        disabled={isSubmitting}
                                        type="submit"
                                    >
                                        Save
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                )}
            </div>
        </div>
    )
}
