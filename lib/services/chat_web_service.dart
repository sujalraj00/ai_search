import 'dart:async';
import 'dart:convert';

import 'package:web_socket_client/web_socket_client.dart';

class ChatWebService {
  static final _instance = ChatWebService._internal();

  WebSocket? _webSocket;
  factory ChatWebService() => _instance;
  ChatWebService._internal();

  final _searchResultController = StreamController<Map<String, dynamic>>();
  final _contentController = StreamController<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get searchResultStream =>
      _searchResultController.stream;
  Stream<Map<String, dynamic>> get contentStream => _contentController.stream;

  void connect() {
    _webSocket = WebSocket(Uri.parse("ws://localhost:8000/ws/chat"));

    _webSocket!.messages.listen((message) {
      final data = json.decode(message);
      if (data["type"] == "search_result") {
        _searchResultController.add(data);
      } else if (data["type"] == "content") {
        _contentController.add(data);
      }
    });
  }

  void chat(String query) {
    _webSocket!.send(json.encode({"query": query}));
  }
}
