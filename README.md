# AI Search with MCP Agent

A Flutter application that combines web search capabilities with AI-powered MCP (Model Context Protocol) agent functionality.

## Features

- **Web Search**: Traditional search functionality powered by web services
- **AI Agent**: MCP-enabled AI agent that can use various tools and provide intelligent responses
- **Tool Integration**: Access to MCP tools for enhanced functionality
- **Cross-Platform**: Works on web, mobile, and desktop platforms

## MCP Agent Functionality

The AI Agent feature allows users to:
- Ask complex questions that require tool usage
- Get intelligent responses that leverage MCP tools
- Maintain conversation history for context
- Automatically select and use relevant tools based on queries

## Setup

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Google Gemini API key

### Environment Variables

Create a `.env` file in the project root with:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Dependencies

The project uses several key packages:
- `google_generative_ai`: For AI model integration
- `web_socket_channel`: For MCP server communication
- `http`: For HTTP requests
- `flutter_dotenv`: For environment variable management

## Usage

### Regular Search
1. Enter your search query in the search bar
2. Click the arrow button or press Enter
3. View search results and sources

### AI Agent Mode
1. Enter your question in the search bar
2. Click the "Agent" button
3. The AI agent will process your request and may use MCP tools
4. View the intelligent response from the agent

## Architecture

- **MCPClient**: Handles communication with MCP servers
- **AgentService**: Manages AI agent logic and tool integration
- **ChatPage**: Displays conversations and responses
- **SearchSection**: Main search interface with agent button


## Getting Started

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Set up environment variables
4. Run the application: `flutter run`

## Development

This project demonstrates:
- Flutter state management
- AI integration with Gemini
- MCP protocol implementation
- Cross-platform UI design
- Real-time communication with external services
