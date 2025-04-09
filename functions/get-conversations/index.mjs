import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-west-1" }));
const CONVERSATIONS_TABLE_NAME = 'dev_Conversations';

export const handler = async (event) => {
    try {
        const userId = event.requestContext.authorizer.jwt.claims.sub;

        const result = await dynamo.send(new QueryCommand({
            TableName: CONVERSATIONS_TABLE_NAME,
            KeyConditionExpression: "userId = :uid",
            ExpressionAttributeValues: {
                ":uid": userId
            }
        }));

        const sortedItems = (result.Items || []).sort((a, b) => b.lastUpdated - a.lastUpdated);

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