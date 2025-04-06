// functions/chat-completion/index.js
import OpenAI from "openai"
import { DynamoDBClient } from "@aws-sdk/client-dynamodb"
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb"
import { v4 as uuidv4 } from "uuid"

// Init OpenAI
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })

// Init DynamoDB
const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-west-1" }))
const TABLE_NAME = "dev_ChatTable" // Switch to env later

export const handler = async (event) => {

  console.log("Event: ", event.requestContext.authorizer.jwt.claims.sub)

  try {
    const userSub = event.requestContext.authorizer.jwt.claims.sub // from Cognito JWT
    const body = JSON.parse(event.body)
    const message = body.message || 'Write a one sentence story about a unicorn.'
    const chatId = body.chatId || uuidv4()
    const timestamp = Date.now()

    // Send to OpenAI
    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: "Respond in Markdown format recognizable by React Markdown with remarkGfm" },
        { role: "user", content: message }
      ],
    })

    const response = completion.choices[0].message.content

    // Store user message
    await dynamo.send(new PutCommand({
      TableName: TABLE_NAME,
      Item: {
        userId: userSub,
        sortKey: `MSG#${timestamp}`,
        chatId,
        role: "user",
        content: message,
        timestamp,
        lastUpdated: timestamp,
      }
    }))

    // Store assistant response
    await dynamo.send(new PutCommand({
      TableName: TABLE_NAME,
      Item: {
        userId: userSub,
        sortKey: `MSG#${timestamp + 1}`, // +1 to ensure it's after the user message
        chatId,
        role: "assistant",
        content: response,
        timestamp: timestamp + 1,
        lastUpdated: timestamp + 1,
      }
    }))

    // Optionally update the chat metadata (conversation level tracking)
    await dynamo.send(new PutCommand({
      TableName: TABLE_NAME,
      Item: {
        userId: userSub,
        sortKey: `CHAT#${chatId}`,
        chatId,
        lastUpdated: timestamp + 1,
        type: "chatMeta"
      }
    }))

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        chatId,
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
