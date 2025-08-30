import 'package:flutter_test/flutter_test.dart';
import 'package:ai_search/services/mcp_client.dart';

void main() {
  group('MCPClient Tests', () {
    late MCPClient mcpClient;

    setUp(() {
      mcpClient = MCPClient();
    });

    tearDown(() {
      mcpClient.dispose();
    });

    test('should initialize with correct base URL', () {
      expect(mcpClient.baseUrl, 'https://mcp-x-server.onrender.com');
    });

    test('should start disconnected', () {
      expect(mcpClient.isConnected, false);
    });

    test('should connect successfully', () async {
      await mcpClient.connect();
      expect(mcpClient.isConnected, true);
    });

    test('should list tools successfully', () async {
      await mcpClient.connect();
      final tools = await mcpClient.listTools();
      expect(tools, isA<List<Map<String, dynamic>>>());
      expect(tools.isNotEmpty, true);
    });

    test('should handle tool calls', () async {
      await mcpClient.connect();
      final tools = await mcpClient.listTools();
      if (tools.isNotEmpty) {
        final firstTool = tools.first;
        final result = await mcpClient.callTool(
          name: firstTool['name'],
          arguments: {'query': 'test query'},
        );
        expect(result, isA<Map<String, dynamic>>());
      }
    });

    test('should disconnect successfully', () async {
      await mcpClient.connect();
      expect(mcpClient.isConnected, true);

      mcpClient.disconnect();
      expect(mcpClient.isConnected, false);
    });
  });
}
