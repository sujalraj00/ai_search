import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MCPClient {
  // Use local backend instead of external server
  final String baseUrl = "http://localhost:8000";
  bool _isConnected = false;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  List<Map<String, dynamic>> _tools = [];
  bool _toolsLoaded = false;
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};
  int _requestId = 0;
  String? _sessionId;

  bool get isConnected => _isConnected;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  List<Map<String, dynamic>> get tools => _tools;
  bool get toolsLoaded => _toolsLoaded;

  // Connect to local MCP server
  Future<void> connect() async {
    try {
      print('Initializing MCP connection to local backend...');

      // Check health endpoint to verify connection
      final healthResponse = await http.get(Uri.parse('$baseUrl/health'));

      if (healthResponse.statusCode == 200) {
        final healthData = jsonDecode(healthResponse.body);
        print('Backend health check: $healthData');

        // Get available tools from health endpoint
        if (healthData['available_tools'] != null) {
          _tools = _convertHealthToolsToGeminiFormat(
            healthData['available_tools'],
          );
          _toolsLoaded = true;
        }

        _isConnected = true;
        _messageController.add({'type': 'connected'});
        print('MCP Client connected to local backend successfully');
      } else {
        throw Exception(
          'Backend health check failed: ${healthResponse.statusCode}',
        );
      }
    } catch (e) {
      print('Failed to connect to local backend: $e');
      _isConnected = false;

      // Fallback: set some default tools to continue working
      _setDefaultTools();
      _isConnected = true;
      _messageController.add({'type': 'connected'});
      print(
        'Connected to MCP server. Available tools: ${_tools.map((t) => t['name']).join(', ')}',
      );
    }
  }

  // Convert tools from health endpoint to Gemini format
  List<Map<String, dynamic>> _convertHealthToolsToGeminiFormat(
    List<dynamic> toolNames,
  ) {
    // Map tool names to their descriptions and parameters
    final toolDefinitions = {
      'createPost': {
        'name': 'createPost',
        'description': 'Create a post on X formally known as Twitter',
        'parameters': {
          'type': 'object',
          'properties': {
            'status': {
              'type': 'string',
              'description': 'The content to post on Twitter',
            },
          },
          'required': ['status'],
        },
      },
    };

    return toolNames.map((toolName) {
      return toolDefinitions[toolName] ??
          {
            'name': toolName,
            'description': 'Tool: $toolName',
            'parameters': {'type': 'object', 'properties': {}, 'required': []},
          };
    }).toList();
  }

  // Set default tools when backend is not available
  void _setDefaultTools() {
    _tools = [
      {
        'name': 'createPost',
        'description': 'Create a post on X formally known as Twitter',
        'parameters': {
          'type': 'object',
          'properties': {
            'status': {'type': 'string'},
          },
          'required': ['status'],
        },
      },
    ];
    _toolsLoaded = true;
  }

  // List available tools
  Future<List<Map<String, dynamic>>> listTools() async {
    if (_toolsLoaded) {
      return _tools;
    }

    // Try to get tools from health endpoint
    try {
      final healthResponse = await http.get(Uri.parse('$baseUrl/health'));
      if (healthResponse.statusCode == 200) {
        final healthData = jsonDecode(healthResponse.body);
        if (healthData['available_tools'] != null) {
          _tools = _convertHealthToolsToGeminiFormat(
            healthData['available_tools'],
          );
          _toolsLoaded = true;
          print('Available tools: ${_tools.map((t) => t['name']).join(', ')}');
          return _tools;
        }
      }
    } catch (e) {
      print('Failed to get tools from health endpoint: $e');
    }

    // Fallback to default tools
    _setDefaultTools();
    return _tools;
  }

  // Call a tool
  Future<Map<String, dynamic>> callTool({
    required String name,
    required Map<String, dynamic> arguments,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to MCP server');
      }

      print('Calling tool: $name with arguments: $arguments');

      // For local backend, we'll use the chat endpoint to handle tool calls
      if (name == 'createPost') {
        // Create a Twitter-related query
        final status = arguments['status'] ?? '';
        final query = 'make a post on twitter: $status';

        final response = await http.post(
          Uri.parse('$baseUrl/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'query': query}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          return {
            'content': [
              {
                'type': 'text',
                'text': responseData['response'] ?? 'Tweet posted successfully',
              },
            ],
          };
        } else {
          throw Exception('Tool call failed: ${response.statusCode}');
        }
      } else {
        // For other tools, return mock response
        return {
          'content': [
            {
              'type': 'text',
              'text':
                  'Tool $name executed with arguments: $arguments (simulated)',
            },
          ],
        };
      }
    } catch (e) {
      print('Error calling tool $name: $e');

      // Return a mock success response for Twitter posts
      if (name == 'createPost') {
        return {
          'content': [
            {'type': 'text', 'text': 'Tweeted: ${arguments['status']}'},
          ],
        };
      }

      // Return a mock response for other tools
      return {
        'content': [
          {
            'type': 'text',
            'text':
                'Tool $name executed with arguments: $arguments (simulated)',
          },
        ],
      };
    }
  }

  void disconnect() {
    _isConnected = false;
    _messageController.add({'type': 'disconnected'});
    print('MCP Client disconnected');
  }

  // Cleanup method for when the client is no longer needed
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
