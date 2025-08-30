// widgets/safe_sources_section.dart
import 'package:flutter/material.dart';

class SafeSourcesSection extends StatefulWidget {
  const SafeSourcesSection({super.key});

  @override
  State<SafeSourcesSection> createState() => _SafeSourcesSectionState();
}

class _SafeSourcesSectionState extends State<SafeSourcesSection> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Sources temporarily unavailable',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sources',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            // Add your actual source items here
            _buildSourceItem('Source 1', 'https://example.com/1'),
            _buildSourceItem('Source 2', 'https://example.com/2'),
            _buildSourceItem('Source 3', 'https://example.com/3'),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceItem(String title, String url) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  url,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
