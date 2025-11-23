/** @jsxImportSource react */

type User = {
    email: string;
    id: string;
    name: string;
}

type AdminProps = {
    message: string;
    users?: User[];
}

export const Admin = (props: AdminProps) => {
    const users = props.users || []

    return (
        <div className="mb-8">
            <div className="mb-4">
                <h2 className="text-2xl font-bold">{props.message}</h2>
            </div>

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
                    ユーザーが見つかりません
                </div>
            )}
        </div>
    )
}
