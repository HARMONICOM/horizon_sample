/** @jsxImportSource react */

type AdminProps = {
    message: any;  // eslint-disable-line @typescript-eslint/no-explicit-any
}

export const Admin = (props: AdminProps) => {
    return (
        <div className="mb-8">
            <div className="mb-4">
                <h2 className="text-2xl font-bold">{props.message}</h2>
            </div>
        </div>
    )
}
