// functions/chat-completion/index.js
import OpenAI from "openai"

// Initialize the OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export const handler = async (event) => {
  try {

    console.log(openai)

    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        { 
            role: "system", 
            content: "Respond in Markdown format recongizable by React Markdown with remarkGfm" 
        },
        { 
            role: "user", 
            content: event.message || "Write a one sentence story about a unicorn." 
        }
      ],
    });

    console.log("Completion: ", completion)

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        message: completion.choices[0].message.content
      })
    };
  } catch (error) {
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