import 'package:ai_search/themes/colors.dart';
import 'package:ai_search/widget/answer_section.dart';
import 'package:ai_search/widget/side_nav_bar.dart';
import 'package:ai_search/widget/sources_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String question;
  const ChatPage({super.key, required this.question});

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
                    Text(
                      question,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    // list of sources
                    SourcesSection(),
                    // anser
                    AnswerSection(),
                  ],
                ),
              ),
            ),
          ),
        kIsWeb ?   Placeholder(strokeWidth: 0, color: AppColors.background) : SizedBox(),
        ],
      ),
    );
  }
}
