export const handler = async (event) => {
    const res = {
        statusCode: 200,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            success: "true"
        })
    };

    return res;
}