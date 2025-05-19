// functions/chat-completion/index.js
import OpenAI from "openai"
import { DynamoDBClient } from "@aws-sdk/client-dynamodb"
import { DynamoDBDocumentClient, PutCommand, QueryCommand } from "@aws-sdk/lib-dynamodb"
import { v4 as uuidv4 } from "uuid"

// Init OpenAI
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })

// Init DynamoDB
const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-west-1" }))
// const USERS_TABLE_NAME = "dev_Users"
const CONVERSATIONS_TABLE_NAME = 'dev_PCA_Conversations'
const MESSAGES_TABLE_NAME = 'dev_PCA_Messages'

export const handler = async (event) => {

    try {
        const userId = event.requestContext.authorizer.jwt.claims.sub // from Cognito JWT
        const body = JSON.parse(event.body)
        const message = body.message || 'Write a one sentence story about a unicorn.'
        const conversationId = body.conversationId || uuidv4() 
        const timestamp = Date.now()
        const timestamp_response = timestamp + 1 // Ensure timestamp is never equal

        let title = !body.conversationId ? message.slice(0, 30) : ''

        // If body conversationId exists --> title exists and must be retrieved
        if (body.conversationId) {
        
            try {
                const result = await dynamo.send(new QueryCommand({
                    TableName: CONVERSATIONS_TABLE_NAME,
                    KeyConditionExpression: "userId = :uid AND conversationId = :cid",
                    ExpressionAttributeValues: {
                        ":uid": userId,
                        ":cid": conversationId
                    }
                }));

                if (result.Items) {
                    title = result.Items[0].title;
                    console.log("EXISTING TITLE: ", title)
                }

            } catch (err) {
                console.error("Error fetching existing conversation:", err);
            }
        }

        // Send to OpenAI
        const completion = await openai.chat.completions.create({
            model: "gpt-3.5-turbo",
            messages: [
                { role: "system", content: "Respond in Markdown format recognizable by React Markdown with remarkGfm" },
                { role: "user", content: message }
            ],
        })

        const response = completion.choices[0].message.content
        const currentUnixTime = Math.floor(timestamp / 1000)
        const expiresAt = currentUnixTime + 30 * 24 * 60 * 60

        // Store user message
        await dynamo.send(new PutCommand({
            TableName: MESSAGES_TABLE_NAME,
            Item: {
                userId: userId,
                conversationId: conversationId,
                sender: "user",
                content: message,
                timestamp: timestamp,
                expiresAt: expiresAt,
            }
        }))

        // Store assistant response
        await dynamo.send(new PutCommand({
            TableName: MESSAGES_TABLE_NAME,
            Item: {
                userId: userId,
                conversationId: conversationId,
                sender: "bot",
                content: response,
                timestamp: timestamp_response,
                expiresAt: expiresAt,
            }
        }))

        // Optionally update the chat metadata (conversation level tracking)
        await dynamo.send(new PutCommand({
            TableName: CONVERSATIONS_TABLE_NAME,
            Item: {
                userId: userId,
                conversationId: conversationId,
                title: title,
                createdAt: timestamp,
                lastUpdated: timestamp_response,
                type: "chatMeta",
                expiresAt: expiresAt,
            }
        }))

        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                conversationId: conversationId,
                content: response
            })
        }

    } catch (error) {
        console.error("Error:", error)
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ error: error.message })
        }
    }
}