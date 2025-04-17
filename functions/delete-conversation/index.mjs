import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DeleteCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-west-1" }))
const CONVERSATIONS_TABLE_NAME = 'dev_Conversations'

export const handler = async (event) => {

        console.log("Event: ", event)
        const userId = event.requestContext.authorizer.jwt.claims.sub
        const conversationId = event.pathParameters.conversationId

        if (!conversationId || !userId) {
            return {
              statusCode: 400,
              body: JSON.stringify({ message: "Missing conversationId or userId", success: false }),
            };
        }
    try {

        await dynamo.send(new DeleteCommand({
            TableName: CONVERSATIONS_TABLE_NAME,
            Key: {
                userId: userId,
                conversationId: conversationId
            }
        }))

        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                success: true
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
                body: JSON.stringify({ error: error.message, success: false })
            };
    }
};