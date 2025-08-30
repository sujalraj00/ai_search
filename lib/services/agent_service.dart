import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'mcp_client.dart';

class AgentService {
  GenerativeModel? _gemini;
  final mcp = MCPClient();
  final List<Map<String, dynamic>> chatHistory = [];
  List<Map<String, dynamic>> tools = [];

  // Get or create the Gemini model instance
  GenerativeModel get gemini {
    _gemini ??= GenerativeModel(
      model: "gemini-2.0-flash-exp",
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? "",
    );
    return _gemini!;
  }

  // Initialize the agent and connect to MCP
  Future<void> initialize() async {
    try {
      await mcp.connect();
      tools = await mcp.listTools();
      print('Agent initialized with ${tools.length} tools');
    } catch (e) {
      print('Failed to initialize agent: $e');
      rethrow;
    }
  }

  // Handle agent query with MCP integration
  Future<String> handleAgentQuery(String question) async {
    try {
      // Check if API key is available
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return "Error: Gemini API key not configured. Please check your .env file.";
      }

      // Add user question to chat history
      chatHistory.add({
        "role": "user",
        "parts": [
          {"text": question, "type": "text"},
        ],
      });

      // Start chat with Gemini
      final chat = gemini.startChat(
        history: [
          Content.text(
            "You are an AI agent connected to MCP (Model Context Protocol) with access to various tools. When you need to perform specific actions or gather information, you can use these tools. Always provide helpful and accurate responses.",
          ),
        ],
      );

      // Send message to Gemini
      final response = await chat.sendMessage(Content.text(question));

      final responseText = response.text;

      // Add AI response to chat history
      chatHistory.add({
        "role": "model",
        "parts": [
          {"text": responseText ?? "No response", "type": "text"},
        ],
      });

      // Check if the response suggests using a tool
      if (responseText != null && _shouldUseTool(responseText, question)) {
        return await _tryToolExecution(question, responseText);
      }

      return responseText ?? "No response";
    } catch (e) {
      print('Error in handleAgentQuery: $e');
      return "Sorry, I encountered an error: $e";
    }
  }

  // Determine if we should try to use a tool
  bool _shouldUseTool(String response, String question) {
    final lowerResponse = response.toLowerCase();
    final lowerQuestion = question.toLowerCase();

    // Check if response suggests needing external data or tools
    return lowerResponse.contains('i don\'t have access') ||
        lowerResponse.contains('i cannot') ||
        lowerResponse.contains('i don\'t know') ||
        lowerQuestion.contains('search') ||
        lowerQuestion.contains('find') ||
        lowerQuestion.contains('get') ||
        lowerQuestion.contains('fetch');
  }

  // Try to execute a relevant tool
  Future<String> _tryToolExecution(String question, String aiResponse) async {
    try {
      // Find the most relevant tool based on the question
      final relevantTool = _findRelevantTool(question);

      if (relevantTool != null) {
        print("Attempting to use tool: ${relevantTool['name']}");

        // Execute the tool with basic parameters
        final toolResult = await mcp.callTool(
          name: relevantTool['name'],
          arguments: {"query": question},
        );

        // Generate a new response incorporating the tool result
        final chat = gemini.startChat(
          history: [
            Content.text(
              "You are an AI agent. You just used a tool and got a result. Provide a comprehensive answer based on this result.",
            ),
          ],
        );

        final enhancedResponse = await chat.sendMessage(
          Content.text(
            "Question: $question\nTool Result: $toolResult\nPlease provide a comprehensive answer based on the tool result.",
          ),
        );

        return enhancedResponse.text ??
            "Tool executed successfully: $toolResult";
      }

      return aiResponse;
    } catch (e) {
      print('Error in tool execution: $e');
      return aiResponse; // Return original response if tool fails
    }
  }

  // Find the most relevant tool for a given question
  Map<String, dynamic>? _findRelevantTool(String question) {
    if (tools.isEmpty) return null;

    final lowerQuestion = question.toLowerCase();

    // Simple keyword matching to find relevant tools
    for (final tool in tools) {
      final toolName = tool['name'].toString().toLowerCase();
      final toolDesc = tool['description'].toString().toLowerCase();

      if (lowerQuestion.contains('search') &&
          (toolName.contains('search') || toolDesc.contains('search'))) {
        return tool;
      }
      if (lowerQuestion.contains('file') &&
          (toolName.contains('file') || toolDesc.contains('file'))) {
        return tool;
      }
      if (lowerQuestion.contains('web') &&
          (toolName.contains('web') || toolDesc.contains('web'))) {
        return tool;
      }
    }

    // Return first tool if no specific match found
    return tools.first;
  }

  // Get chat history
  List<Map<String, dynamic>> getChatHistory() {
    return List.from(chatHistory);
  }

  // Clear chat history
  void clearChatHistory() {
    chatHistory.clear();
  }

  // Get available tools
  List<Map<String, dynamic>> getAvailableTools() {
    return List.from(tools);
  }

  // Dispose resources
  void dispose() {
    mcp.dispose();
  }
}
