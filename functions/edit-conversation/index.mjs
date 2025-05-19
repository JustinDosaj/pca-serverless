import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { UpdateCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-west-1" }))
const CONVERSATIONS_TABLE_NAME = 'dev_pca_conversations'

export const handler = async (event) => {

    console.log("Event: ", event)
    const userId = event.requestContext.authorizer.jwt.claims.sub
    const conversationId = event.pathParameters.conversationId
    const body = JSON.parse(event.body)
    const title = body.title || null
    const timestamp = Date.now()
    const currentUnixTime = Math.floor(timestamp / 1000)
    const expiresAt = currentUnixTime + 30 * 24 * 60 * 60

    if (!conversationId || !userId || !title) {
        return {
          statusCode: 400,
          body: JSON.stringify({ message: "Missing conversationId, userId or title", success: false }),
        };
    }
    
    try {
        
        await dynamo.send(new UpdateCommand({
            TableName: CONVERSATIONS_TABLE_NAME,
            Key: {
                userId: userId,
                conversationId: conversationId
            },
            UpdateExpression: "set title = :title, lastUpdated = :lastUpdated, expiresAt = :expiresAt",
            ExpressionAttributeValues: {
                ":title": title,
                ":lastUpdated": timestamp,
                ":expiresAt": expiresAt,
            },
            ReturnValues: "UPDATED_NEW"
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