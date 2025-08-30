import 'dart:async';

import 'package:ai_search/pages/chat_page.dart';
import 'package:ai_search/pages/mcp_chat_page.dart';
import 'package:ai_search/services/chat_web_service.dart';
import 'package:ai_search/services/agent_service.dart';
import 'package:ai_search/themes/colors.dart';
import 'package:ai_search/widget/search_bar_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController queryController = TextEditingController();
  final ChatWebService chatService = ChatWebService();
  final AgentService agentService = AgentService();
  bool isAgentMode = false;
  StreamSubscription? _agentSubscription;
  bool _isAgentInitializing = false;

  @override
  void initState() {
    super.initState();
    chatService.connect();

    // Listen to agent responses
    _agentSubscription = chatService.agentResponseStream.listen((response) {
      // Handle agent responses here if needed
      print('Agent response: $response');
    });
  }

  @override
  void dispose() {
    _agentSubscription?.cancel();
    agentService.dispose();
    super.dispose();
  }

  void _activateAgentMode() async {
    setState(() {
      _isAgentInitializing = true;
    });

    try {
      // Connect to MCP server
      await agentService.initialize();

      // Listen to agent responses
      _agentSubscription = chatService.agentResponseStream.listen((response) {
        // Handle real-time agent responses if needed
        print('Agent response: $response');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🤖 Agent mode activated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to connect to agent: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isAgentMode = false;
      });
    } finally {
      setState(() {
        _isAgentInitializing = false;
      });
    }
  }

  void _deactivateAgentMode() {
    _agentSubscription?.cancel();
    agentService.dispose();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔌 Agent mode deactivated'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Where knowledge begins',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 40,
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: 700,
          decoration: BoxDecoration(
            color: AppColors.searchBar,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.searchBarBorder, width: 1.5),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: queryController,
                  decoration: InputDecoration(
                    hintText: 'Search Anything...',
                    hintStyle: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    SearchBarButton(
                      icon: Icons.auto_awesome_outlined,
                      text: 'Focus',
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    SearchBarButton(
                      icon: Icons.add_circle_outline,
                      text: 'Attach',
                      onTap: () {},
                    ),
                    // Updated Agent button with MCP functionality
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => MCPChatPage(
                                  question: queryController.text.trim(),
                                ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.searchBar,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.searchBarBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.handshake,
                              size: 16,
                              color: AppColors.textGrey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Agent',
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ChatWebService().chat(queryController.text.trim());
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => ChatPage(
                                  question: queryController.text.trim(),
                                ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.submitButton,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
