import 'dart:async';
import 'dart:convert';
import 'package:web_socket_client/web_socket_client.dart';
import 'mcp_client.dart';
import 'package:http/http.dart' as http;

class ChatWebService {
  static final _instance = ChatWebService._internal();

  WebSocket? _webSocket;
  MCPClient? _mcpClient;

  factory ChatWebService() => _instance;
  ChatWebService._internal();

  final _searchResultController = StreamController<Map<String, dynamic>>();
  final _contentController = StreamController<Map<String, dynamic>>();
  final _agentResponseController = StreamController<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get searchResultStream =>
      _searchResultController.stream;
  Stream<Map<String, dynamic>> get contentStream => _contentController.stream;
  Stream<Map<String, dynamic>> get agentResponseStream =>
      _agentResponseController.stream;

  void connect() {
    if (_webSocket != null) return;

    try {
      _webSocket = WebSocket(Uri.parse("ws://localhost:8000/ws/chat"));

      _webSocket!.messages.listen((message) {
        try {
          final data = json.decode(message);
          if (data["type"] == "search_result") {
            _searchResultController.add(data);
          } else if (data["type"] == "content") {
            _contentController.add(data);
          }
        } catch (e) {
          print('Error parsing WebSocket message: $e');
        }
      });
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
    }
  }

  void connectToMcpAgent() {
    _mcpClient = MCPClient();

    _mcpClient!
        .connect()
        .then((_) {
          _mcpClient!.messageStream.listen((data) {
            try {
              _agentResponseController.add(data);
            } catch (e) {
              print('Error parsing MCP message: $e');
              _agentResponseController.add({
                'type': 'error',
                'content': 'Failed to parse message: $e',
              });
            }
          });
        })
        .catchError((error) {
          print('Failed to connect to MCP SSE: $error');
        });
  }

  void chat(String query) {
    if (_webSocket == null) {
      connect();
    }

    try {
      if (_webSocket != null) {
        _webSocket!.send(json.encode({"query": query}));
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> chatWithAgent(String query) async {
    if (_mcpClient == null) {
      connectToMcpAgent();
      // Wait a bit for connection to establish
      await Future.delayed(Duration(seconds: 1));
    }

    // Send query to MCP agent via separate HTTP endpoint
    // You'll need to create this endpoint in your MCP server
    try {
      final response = await http.post(
        Uri.parse('https://mcp-x-server.onrender.com/message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': 'user_query',
          'content': query,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to send message to MCP: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error sending message to MCP: $e');
      _agentResponseController.add({
        'type': 'error',
        'content': 'Failed to send message: $e',
      });
    }
  }

  void dispose() {
    _webSocket?.close();
    _mcpClient?.dispose();
    _searchResultController.close();
    _contentController.close();
    _agentResponseController.close();
  }
}
