// functions/chat-completion/index.js
import OpenAI from "openai"
import { DynamoDBClient } from "@aws-sdk/client-dynamodb"
import { DynamoDBDocumentClient, PutCommand, QueryCommand } from "@aws-sdk/lib-dynamodb"
import { ComprehendClient, DetectPiiEntitiesCommand } from "@aws-sdk/client-comprehend"
import { v4 as uuidv4 } from "uuid"

// Init OpenAI
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })

// Init DynamoDB
const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-west-1" }))

// Init Comprehend
const comprehend= new ComprehendClient({region: "us-west-2"})

// const USERS_TABLE_NAME = "dev_Users"
const CONVERSATIONS_TABLE_NAME = 'dev_pca_conversations'
const MESSAGES_TABLE_NAME = 'dev_pca_messages'

export const handler = async (event) => {

    try {

        const userId = event.requestContext.authorizer.jwt.claims.sub // from Cognito JWT
        const body = JSON.parse(event.body)
        const message = body.message || 'Write a one sentence story about a unicorn.'
        const conversationId = body.conversationId || uuidv4()
        const privacySettings = body.privacySettings 
        const timestamp = Date.now()
        const timestamp_response = timestamp + 1 // Ensure timestamp_response is never equal with timestamp

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

        const allowedPiiTypes = cleanSettings(privacySettings)

        const piiEntities = await detectPiiEntities(message, allowedPiiTypes)

        const cleanedMessage = await removeDetections(message, piiEntities)

        const response = await sendChatMessage(cleanedMessage)

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
                // Changed from response to cleanedMesage while removing LLM response
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

function cleanSettings(settings) {

    console.log("Settings Before Clean: ", settings)

    const val = Object.keys(settings).filter((key) => settings[key])

    console.log("Settings After Clean: ", val)

    return Object.keys(settings).filter((key) => settings[key])
}

async function detectPiiEntities(message, allowedTypes) {
    
    const allowedSet = new Set(allowedTypes)

    try {
        
        const command = new DetectPiiEntitiesCommand({
            Text: message,
            LanguageCode: "en"
        })

        const res = await comprehend.send(command)
        const entities = (res?.Entities || []).filter(
            (entity) => entity.Type && allowedSet.has(entity.Type)
        )

        console.log("Detected PII Entities: ", entities)

        return entities

    } catch (error) {
        console.error("Error detecting PII: ", error)
        throw error
    }
}

async function removeDetections(message, entities) {

    try {
    
        const wordMap = new Map();

        let index = 0
        
        entities.forEach((entity) => {
            const start = entity.BeginOffset || 0
            const end = entity.EndOffset || 0
            const word = message.substring(start, end)
            const type = entity.Type || "UNKNOWN"

            if (wordMap.has(type)) {
                wordMap.get(type).push({word, index})
            } else {
                wordMap.set(type, [{word, index}])
            }
            index++;
        })

        wordMap.forEach((arr, type) => {
            for (let i = 0; i < arr.length; i++) {
                const entity = entities[arr[i].index]
                const wordLength = (entity.EndOffset || 0) - (entity.BeginOffset || 0)
                const startIdx = message.indexOf(arr[i].word);
                const endIdx = startIdx + wordLength;
                const original = message.substring(startIdx, endIdx)
                const replacement = `[${type}_${i}]`
                message = message.replace(original, replacement)
            }
        })

        return message
        
    } catch (error) {
        console.error("Error removing PII entities: ", error)
        throw error
    }
}

async function sendChatMessage(message) {

    try {
        
        const completion = await openai.chat.completions.create({
            model: "gpt-3.5-turbo",
            messages: [
                { role: "system", content: "Your response must be exactly what the user sent. Do not make changes or alternations, only respond in Markdown format recognizable by React Markdown with remarkGfm" },
                { role: "user", content: message },
            ],
        })

        console.log("Completion: ", completion)

        return completion.choices[0].message.content;

    } catch (error) {
        console.error('Error recieving LLM response: ', error)
        throw error
    }
}