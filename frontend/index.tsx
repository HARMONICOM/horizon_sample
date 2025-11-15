/** @jsxImportSource react */

type IndexProps = {
    message: any;  // eslint-disable-line @typescript-eslint/no-explicit-any
}

export const Index = (props: IndexProps) => {
    return (
        <div className="mb-8">
            <div className="mb-4">
                <h2 className="text-2xl font-bold">{props.message}</h2>
            </div>
        </div>
    )
}
