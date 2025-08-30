import 'package:admanager_web/admanager_web.dart';
import 'package:ai_search/themes/colors.dart';
import 'package:ai_search/widget/safe_source_section.dart';
import 'package:ai_search/widget/side_nav_bar.dart';
import 'package:ai_search/widget/sources_section.dart';
import 'package:ai_search/services/agent_service.dart';
import 'package:ai_search/services/chat_web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  final String question;
  final bool isAgentMode;
  final AgentService? agentService;

  const ChatPage({
    super.key,
    required this.question,
    this.isAgentMode = false,
    this.agentService,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatWebService _chatService = ChatWebService();
  List<ChatMessage> _messages = [];
  //List<dynamic> sources = [];

  bool _isTyping = false;
  // bool _showSources = false; // New state variable to control sources visibility

  @override
  void initState() {
    super.initState();
    _chatService.connect();

    // Add initial question as first message
    _messages.add(
      ChatMessage(
        text: widget.question,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    // // Listen to sources (put this here)
    // _chatService.searchResultStream.listen((data) {
    //   if (!mounted) return;
    //   setState(() {
    //     sources.add(data['data']); // or insert at index tied to the question
    //   });
    // });

    _chatService.searchResultStream.listen((data) {
      if (!mounted) return;
      setState(() {
        if (_messages.isNotEmpty) {
          final lastUserIndex = _messages.lastIndexWhere((m) => m.isUser);
          if (lastUserIndex != -1) {
            _messages[lastUserIndex].sources = data['data'];
          }
        }
      });
    });
    // Show sources for initial question
    // _showSources = true;

    // Listen for incoming messages
    _chatService.contentStream.listen((data) {
      if (data['type'] == 'content' && data['data'] != null) {
        setState(() {
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            // Append to existing AI message
            _messages.last.text += data['data'];
          } else {
            // Create new AI message
            _messages.add(
              ChatMessage(
                text: data['data'],
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
            // Hide sources when AI starts responding
            // _showSources = false;
          }
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
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

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
      // _showSources = true; // Show sources for new user question
    });

    _messageController.clear();
    _scrollToBottom();

    // Send message via WebSocket
    _chatService.chat(message);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Row(
        children: [
          kIsWeb ? SideNavBar() : SizedBox(),
          kIsWeb ? SizedBox(width: 50) : SizedBox(),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 16),
                // Chat messages with Perplexity-style design
                Expanded(
                  child: Container(
                    width: width * 0.6,
                    //height: height,
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          // Perplexity-style typing indicator
                          return Container(
                            margin: EdgeInsets.only(bottom: 24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.submitButton,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.smart_toy,
                                    color: AppColors.background,
                                    size: 16,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.messageBubble,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.submitButton,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        AnimatedDefaultTextStyle(
                                          duration: Duration(milliseconds: 500),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.textGrey,
                                          ),
                                          child: Text('Thinking...'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final message = _messages[index];

                        return Column(
                          children: [
                            // Display the message (user or AI)
                            Container(
                              margin: EdgeInsets.only(bottom: 24),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!message.isUser) ...[
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.submitButton,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.smart_toy,
                                        color: AppColors.background,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                  ],
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color:
                                            message.isUser
                                                ? AppColors.userMessageBubble
                                                : AppColors.messageBubble,
                                        borderRadius: BorderRadius.circular(16),
                                        border:
                                            message.isUser
                                                ? Border.all(
                                                  color: AppColors.subtleBorder,
                                                  width: 1,
                                                )
                                                : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.text,
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.5,
                                              color:
                                                  message.isUser
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.9),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            _formatTime(message.timestamp),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (message.isUser) ...[
                                    SizedBox(width: 16),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.submitButton,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.background,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Sources section - shown after user messages and before AI responsefinal sources = _sources.firstWhere((element) => element['question'] == message.text);
                            if (message.isUser && !widget.isAgentMode) ...[
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                  vertical: 13.0,
                                ),
                                child: SourcesSection(
                                  sources: message.sources ?? [],
                                  isLoading: message.sources == null,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Search bar at the bottom
                Container(
                  width: width * 0.6,
                  padding: EdgeInsets.only(
                    left: 32.0,
                    right: 30.0,
                    top: 8.0,
                    bottom: 15.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.searchBar,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.subtleBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Ask anything...',
                              hintStyle: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        // Minimal action buttons
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Focus button
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.searchBar,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.subtleBorder,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome_outlined,
                                          size: 16,
                                          color: AppColors.textGrey,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Focus',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Send button
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: InkWell(
                                  onTap: _sendMessage,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.submitButton,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.background,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right side space for ads
          kIsWeb
              ? Container(
                width: width * 0.3,
                child: AdBlock(
                  size: [AdBlockSize.largeRectangle], // Other sizes available
                  adUnitId: "3424311963", // Replace with your ad unit ID
                ),
              )
              : SizedBox(),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  String text;
  final bool isUser;
  final DateTime timestamp;
  List<dynamic>? sources;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
  });
}
