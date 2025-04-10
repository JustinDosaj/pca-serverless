

export const handler = async (event) => {
    try {

        return {
            statusCode: 200,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    conversations: sortedItems
                })
            };
    } catch (error) {
            console.error("Error:", error);
            return {
                statusCode: 500,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ error: error.message })
            };
    }
};