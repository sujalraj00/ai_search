import 'package:ai_search/themes/colors.dart';
import 'package:ai_search/widget/answer_section.dart';
import 'package:ai_search/widget/side_nav_bar.dart';
import 'package:ai_search/widget/sources_section.dart';
import 'package:ai_search/services/agent_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          kIsWeb ? SideNavBar() : SizedBox(),
          kIsWeb ? SizedBox(width: 100) : SizedBox(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.isAgentMode)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.submitButton,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'AI Agent',
                              style: TextStyle(
                                color: AppColors.background,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.question,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // list of sources
                    if (!widget.isAgentMode) SourcesSection(),
                    // answer
                    AnswerSection(
                      isAgentMode: widget.isAgentMode,
                      agentService: widget.agentService,
                      question: widget.question,
                    ),
                  ],
                ),
              ),
            ),
          ),
          kIsWeb
              ? Placeholder(strokeWidth: 0, color: AppColors.background)
              : SizedBox(),
        ],
      ),
    );
  }
}
