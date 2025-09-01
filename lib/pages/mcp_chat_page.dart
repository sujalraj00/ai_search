// mcp_chat_page.dart
import 'package:ai_search/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_search/services/gemini_service.dart';
import 'package:ai_search/services/mcp_chat_service.dart';
import 'package:ai_search/services/mcp_client.dart';

class MCPChatPage extends StatefulWidget {
  final String question;

  const MCPChatPage({Key? key, required this.question}) : super(key: key);

  @override
  _MCPChatPageState createState() => _MCPChatPageState();
}

class _MCPChatPageState extends State<MCPChatPage> {
  late MCPChatService mcpChatService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> messages = [];
  bool isLoading = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMCP();
  }

  Future<void> _initializeMCP() async {
    try {
      final mcpClient = MCPClient();

      final geminiService = GeminiService(apiKey: '');

      mcpChatService = MCPChatService(
        mcpClient: mcpClient,
        geminiService: geminiService,
      );

      await mcpChatService.initialize();

      setState(() {
        isInitialized = true;
      });

      // Process initial question if provided
      if (widget.question.isNotEmpty) {
        _sendMessage(widget.question);
      }
    } catch (e) {
      setState(() {
        messages.add(
          ChatMessage(
            text: 'Failed to initialize MCP client: $e',
            isUser: false,
            isError: true,
          ),
        );
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || !isInitialized) return;

    setState(() {
      messages.add(ChatMessage(text: message, isUser: true));
      isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await mcpChatService.chat(message);

      setState(() {
        messages.add(ChatMessage(text: response, isUser: false));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add(
          ChatMessage(text: 'Error: $e', isUser: false, isError: true),
        );
        isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Use your app colors
      appBar: AppBar(
        title: Text(
          'MCP Agent Chat',
          style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                messages.clear();
                mcpChatService.clearHistory();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color:
                isInitialized
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            child: Text(
              isInitialized
                  ? '🟢 Connected to MCP Server (${mcpChatService.mcpClient.tools.length} tools available)'
                  : '🔴 Connecting to MCP Server...',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 12,
                color: isInitialized ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Messages
          Expanded(
            child:
                messages.isEmpty
                    ? Center(
                      child: Text(
                        'Start a conversation with the MCP agent',
                        style: GoogleFonts.ibmPlexMono(
                          color: AppColors.textGrey,
                        ),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(message: messages[index]);
                      },
                    ),
          ),

          // Loading indicator
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Agent is thinking...',
                    style: GoogleFonts.ibmPlexMono(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.searchBar,
              border: Border(
                top: BorderSide(color: AppColors.searchBarBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message the MCP agent...',
                      hintStyle: TextStyle(color: AppColors.textGrey),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                    enabled: isInitialized && !isLoading,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap:
                      isInitialized && !isLoading
                          ? () => _sendMessage(_messageController.text)
                          : null,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isInitialized && !isLoading
                              ? AppColors.submitButton
                              : AppColors.textGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.send,
                      color: AppColors.background,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (isInitialized) {
      mcpChatService.mcpClient.disconnect();
    }
    super.dispose();
  }
}

// Support classes
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, this.isError = false})
    : timestamp = DateTime.now();
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  message.isError ? Colors.red : AppColors.submitButton,
              child: Icon(
                message.isError ? Icons.error : Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? AppColors.submitButton
                        : message.isError
                        ? Colors.red.withOpacity(0.1)
                        : AppColors.searchBar,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color:
                      message.isError
                          ? Colors.red.withOpacity(0.3)
                          : AppColors.searchBarBorder,
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 14,
                  color:
                      message.isUser
                          ? Colors.white
                          : message.isError
                          ? Colors.red
                          : Colors.white,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.textGrey,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

// Update your main widget to include MCP functionality
class SearchBarButtonWithMCP extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final TextEditingController? queryController;

  const SearchBarButtonWithMCP({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
    this.queryController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (text == 'Agent') {
          // Navigate to MCP chat page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                      MCPChatPage(question: queryController?.text.trim() ?? ''),
            ),
          );
        } else if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.searchBar,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.searchBarBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textGrey),
            SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
