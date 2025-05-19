import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

// TODO: Get conversation id from event then get all messages from dynamodb
const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-west-1" }));
const MESSAGES_TABLE_NAME = 'dev_pca_messages';

export const handler = async (event) => {

    console.log("Event", event)
    
    try {
        
        const userId = event.requestContext.authorizer.jwt.claims.sub
        const conversationId = event.queryStringParameters.conversationId || ''

        console.log("ID: ", conversationId)

        const result = await dynamo.send(new QueryCommand({
            TableName: MESSAGES_TABLE_NAME,
            KeyConditionExpression: "conversationId = :cid",
            FilterExpression: "userId = :uid",
            ExpressionAttributeValues: {
                ":cid": conversationId,
                ":uid": userId,
            }
        }))

        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                messages: result.Items || [],
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