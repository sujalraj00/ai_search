# MCP Tools Implementation

This backend now includes a local MCP (Model Context Protocol) server with Twitter posting capabilities.

## Features

- **Local MCP Server**: No external dependencies, runs entirely within your Python backend
- **Twitter Posting Tool**: `createPost` tool that can post to Twitter/X
- **Add Numbers Tool**: `addTwoNumbers` tool for basic arithmetic
- **Gemini Integration**: Uses Google's Gemini model for intelligent responses
- **Tool Calling**: Automatically detects when tools should be used

## Setup

### 1. Install Dependencies

```bash
cd server
pip install -r requirements.txt
```

### 2. Environment Variables

Create a `.env` file in the `server` directory with your Twitter API credentials:

```env
# Twitter API Credentials
TWITTER_API_KEY=your_twitter_api_key
TWITTER_API_SECRET=your_twitter_api_secret
TWITTER_ACCESS_TOKEN=your_twitter_access_token
TWITTER_ACCESS_SECRET=your_twitter_access_secret

# Gemini API Key
GEMINI_API_KEY=your_gemini_api_key
```

### 3. Run the Server

```bash
cd server
python run_server.py
```

The server will start on `http://localhost:8000`

## Available Tools

### 1. createPost
- **Description**: Create a post on X formally known as Twitter
- **Parameters**: 
  - `status` (string): The content to post on Twitter
- **Usage**: Automatically called when users ask to post on Twitter

### 2. addTwoNumbers
- **Description**: Add two numbers
- **Parameters**:
  - `a` (number): First number
  - `b` (number): Second number
- **Usage**: Automatically called when users ask to add numbers

## How It Works

1. **Tool Detection**: The system automatically detects when users want to use tools
2. **Content Extraction**: For Twitter posts, it extracts the content from natural language
3. **Tool Execution**: Calls the appropriate tool with extracted parameters
4. **Response Generation**: Returns the tool result to the user

## Example Usage

### Twitter Posting
- User: "make a post on twitter about AI"
- System: Detects Twitter request, extracts content "AI"
- Tool: Calls `createPost` with `{"status": "AI"}`
- Result: Posts to Twitter and confirms success

### Number Addition
- User: "add 5 and 3"
- System: Detects math request
- Tool: Calls `addTwoNumbers` with `{"a": 5, "b": 3}`
- Result: Returns "The sum of 5 and 3 is 8"

## API Endpoints

- `GET /health` - Check server status and available tools
- `POST /chat` - Chat endpoint that supports tool calling
- `WebSocket /ws/chat` - WebSocket endpoint for real-time chat

## Flutter Integration

The Flutter app now connects to this local backend instead of external servers. It will:

1. Connect to `http://localhost:8000`
2. Get available tools from the health endpoint
3. Call tools through the chat endpoint
4. Display results in the MCP chat interface

## Troubleshooting

### Twitter API Issues
- Ensure all Twitter credentials are set in `.env`
- Check if Twitter API keys are valid
- The system will fall back to simulated responses if Twitter is unavailable

### Connection Issues
- Make sure the Python server is running on port 8000
- Check if Flutter app is pointing to the correct localhost URL
- Verify firewall settings allow local connections

### Tool Calling Issues
- Check the server logs for detailed error messages
- Ensure the tool parameters match the expected format
- Verify that the Gemini API key is valid
