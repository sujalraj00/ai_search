// mcp_chat_service.dart
import 'package:ai_search/services/gemini_service.dart';
import 'package:ai_search/services/mcp_client.dart';

class MCPChatService {
  final MCPClient mcpClient;
  final GeminiService geminiService;
  final List<Map<String, dynamic>> chatHistory = [];

  MCPChatService({required this.mcpClient, required this.geminiService});

  Future<void> initialize() async {
    if (!mcpClient.isConnected) {
      await mcpClient.connect();
    }
  }

  Future<String> chat(String message) async {
    // Add user message to history
    chatHistory.add({
      'role': 'user',
      'parts': [
        {'text': message},
      ],
    });

    return await _processChat();
  }

  Future<String> _processChat([Map<String, dynamic>? toolCall]) async {
    if (toolCall != null) {
      print('Calling tool: ${toolCall['name']}');

      // Add tool call message
      chatHistory.add({
        'role': 'model',
        'parts': [
          {'text': 'Calling tool ${toolCall['name']}'},
        ],
      });

      try {
        // Execute the tool
        final toolResult = await mcpClient.callTool(
          name: toolCall['name'],
          arguments: toolCall['arguments'] ?? {},
        );

        // Add tool result to history
        final resultText =
            toolResult['content']?[0]?['text'] ?? 'Tool executed successfully';
        chatHistory.add({
          'role': 'user',
          'parts': [
            {'text': 'Tool result: $resultText'},
          ],
        });

        print('Tool result: $resultText');
      } catch (e) {
        final errorText = 'Tool execution failed: $e';
        chatHistory.add({
          'role': 'user',
          'parts': [
            {'text': errorText},
          ],
        });
        print(errorText);
      }
    }

    try {
      // Generate response with Gemini
      final tools = mcpClient.tools;
      final response = await geminiService.generateContent(
        chatHistory: chatHistory,
        tools: tools,
      );

      final candidate = response['candidates']?[0];
      final content = candidate?['content'];
      final parts = content?['parts']?[0];

      if (parts?['functionCall'] != null) {
        // Handle function call
        final functionCall = parts['functionCall'];
        return await _processChat(functionCall);
      } else if (parts?['text'] != null) {
        // Handle text response
        final responseText = parts['text'];

        chatHistory.add({
          'role': 'model',
          'parts': [
            {'text': responseText},
          ],
        });

        return responseText;
      }
    } catch (e) {
      print('Error in chat processing: $e');
      return 'Sorry, I encountered an error while processing your request.';
    }

    return 'No response generated';
  }

  void clearHistory() {
    chatHistory.clear();
  }
}
