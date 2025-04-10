

export const handler = async (event) => {
    try {

        console.log("Event: ", event)
        const conversationId = event.pathParameters.conversationId;


        return {
            statusCode: 200,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    content: conversationId
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