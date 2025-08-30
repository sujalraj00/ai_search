import 'package:ai_search/services/chat_web_service.dart';
import 'package:ai_search/services/agent_service.dart';
import 'package:ai_search/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AnswerSection extends StatefulWidget {
  final bool isAgentMode;
  final AgentService? agentService;
  final String question;

  const AnswerSection({
    super.key,
    this.isAgentMode = false,
    this.agentService,
    this.question = '',
  });

  @override
  State<AnswerSection> createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<AnswerSection> {
  String fullResponse = '';
  bool isLoading = true;
  bool _isAgentProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAgentMode && widget.agentService != null) {
      _handleAgentQuery();
    } else {
      _handleRegularChat();
    }
  }

  void _handleRegularChat() {
    ChatWebService().contentStream.listen((data) {
      if (isLoading) {
        fullResponse = "";
      }
      setState(() {
        fullResponse += data['data'];
        isLoading = false;
      });
    });
  }

  Future<void> _handleAgentQuery() async {
    if (widget.agentService == null) return;

    setState(() {
      _isAgentProcessing = true;
      isLoading = true;
    });

    try {
      final response = await widget.agentService!.handleAgentQuery(
        widget.question,
      );
      setState(() {
        fullResponse = response;
        isLoading = false;
        _isAgentProcessing = false;
      });
    } catch (e) {
      setState(() {
        fullResponse = "Sorry, I encountered an error: $e";
        isLoading = false;
        _isAgentProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isAgentMode ? 'AI Agent Response' : 'Perplexity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        if (widget.isAgentMode && _isAgentProcessing)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.submitButton,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'AI Agent is processing your request...',
                  style: TextStyle(fontSize: 16, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        Skeletonizer(
          enabled: isLoading,
          child: Markdown(
            data: fullResponse.isEmpty ? 'Loading...' : fullResponse,
            shrinkWrap: true,
            styleSheet: MarkdownStyleSheet.fromTheme(
              Theme.of(context),
            ).copyWith(
              codeblockDecoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              code: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
