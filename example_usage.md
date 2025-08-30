# MCP Agent Usage Examples

## Overview
The AI Search application now includes a powerful MCP (Model Context Protocol) agent that can use various tools to provide intelligent responses.

## How to Use

### 1. Basic Agent Query
1. Open the application
2. Type your question in the search bar
3. Click the "Agent" button (handshake icon)
4. Wait for the AI agent to process your request
5. View the intelligent response

### 2. Example Queries

#### Web Search
```
Question: "What's the latest news about AI developments?"
Agent Response: The agent will use the search_web tool to find current information about AI developments and provide a comprehensive summary.
```

#### File Operations
```
Question: "Can you read the contents of my project file?"
Agent Response: The agent will attempt to use the read_file tool to access and display file contents.
```

#### Weather Information
```
Question: "What's the weather like in New York?"
Agent Response: The agent will use the get_weather tool to provide current weather conditions for New York.
```

### 3. How It Works

1. **Question Analysis**: The AI agent analyzes your question to determine if tools are needed
2. **Tool Selection**: Automatically selects the most relevant MCP tool based on your query
3. **Tool Execution**: Executes the selected tool with appropriate parameters
4. **Response Generation**: Generates a comprehensive answer based on tool results
5. **Context Maintenance**: Maintains conversation history for better context

### 4. Available Tools

The agent currently has access to these tools:

- **search_web**: Search the internet for information
- **read_file**: Read and display file contents
- **get_weather**: Get weather information for locations

### 5. Agent vs Regular Search

- **Regular Search**: Uses web search services for general queries
- **Agent Mode**: Uses AI intelligence + MCP tools for complex, tool-dependent queries

### 6. Error Handling

If the MCP server is unavailable, the agent will:
- Provide mock responses based on the requested tool
- Clearly indicate that responses are simulated
- Continue to function for demonstration purposes

## Technical Details

- **MCP Client**: Handles communication with MCP servers
- **Tool Discovery**: Automatically discovers available tools
- **Fallback System**: Provides mock responses when server endpoints are unavailable
- **AI Integration**: Uses Google Gemini for intelligent query processing
- **State Management**: Maintains conversation context and tool usage history

## Future Enhancements

- Real MCP server integration
- Additional tool types
- Enhanced tool parameter handling
- Streaming responses
- Tool chaining for complex workflows
