import 'package:ai_search/services/chat_web_service.dart';
import 'package:ai_search/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

// class SourcesSection extends StatefulWidget {
//   const SourcesSection({super.key});

//   @override
//   State<SourcesSection> createState() => _SourcesSectionState();
// }

// class _SourcesSectionState extends State<SourcesSection> {
//   bool isLoading = true;
//   List<dynamic> searchResults = [];
// List searchResults = [
//   {
//     'title': 'Ind vs Aus Live Score 4th Test',
//     'url':
//         'https://www.moneycontrol.com/sports/cricket/ind-vs-aus-live-score-4th-test-shubman-gill-dropped-australia-win-toss-opt-to-bat-liveblog-12897631.html',
//   },
//   {
//     'title': 'Ind vs Aus Live Boxing Day Test',
//     'url':
//         'https://timesofindia.indiatimes.com/sports/cricket/india-vs-australia-live-score-boxing-day-test-2024-ind-vs-aus-4th-test-day-1-live-streaming-online/liveblog/116663401.cms',
//   },
//   {
//     'title': 'Ind vs Aus - 4 Australian Batters Score Half Centuries',
//     'url':
//         'https://economictimes.indiatimes.com/news/sports/ind-vs-aus-four-australian-batters-score-half-centuries-in-boxing-day-test-jasprit-bumrah-leads-indias-fightback/articleshow/116674365.cms',
//   },
// ];
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     ChatWebService().searchResultStream.listen((data) {
//       if (!mounted) return;
//       setState(() {
//         searchResults = data['data'] ?? [];
//         isLoading = false;
//       });
//     });
//   }

//   // List<Map<String, dynamic>> searchResults = [
//   //   {
//   //     'title': 'Ind vs Aus Live Score 4th Test',
//   //     'url':
//   //         'https://www.moneycontrol.com/sports/cricket/ind-vs-aus-live-score-4th-test-shubman-gill-dropped-australia-win-toss-opt-to-bat-liveblog-12897631.html',
//   //   },
//   //   {
//   //     'title': 'Ind vs Aus Live Boxing Day Test',
//   //     'url':
//   //         'https://timesofindia.indiatimes.com/sports/cricket/india-vs-australia-live-score-boxing-day-test-2024-ind-vs-aus-4th-test-day-1-live-streaming-online/liveblog/116663401.cms',
//   //   },
//   //   {
//   //     'title': 'Ind vs Aus - 4 Australian Batters Score Half Centuries',
//   //     'url':
//   //         'https://economictimes.indiatimes.com/news/sports/ind-vs-aus-four-australian-batters-score-half-centuries-in-boxing-day-test-jasprit-bumrah-leads-indias-fightback/articleshow/116674365.cms',
//   //   },
//   // ];

//  @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.source_outlined, color: Colors.white70),
//             SizedBox(width: 8),
//             Text(
//               "Sources",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Skeletonizer(
//           enabled: isLoading,
//           child: searchResults.isEmpty
//               ? Text("No sources found", style: TextStyle(color: Colors.grey))
//               : Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: searchResults.map((res) {
//                     return Container(
//                       width: 150,
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: AppColors.cardColor,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             res['title'] ?? "Untitled",
//                             style: TextStyle(fontWeight: FontWeight.w500),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             res["url"] ?? "",
//                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//         ),
//       ],
//     );
//   }
// }

class SourcesSection extends StatelessWidget {
  final List<dynamic> sources;
  final bool isLoading;

  const SourcesSection({
    super.key,
    required this.sources,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // If loading, use placeholder items
    final displaySources =
        isLoading && sources.isEmpty
            ? List.generate(
              3,
              (_) => {
                'title': 'Loading...',
                'description': '...',
                'url': '...',
              },
            )
            : sources;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.source_outlined, color: Colors.white70),
            SizedBox(width: 8),
            Text(
              "Sources",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 13),
        Skeletonizer(
          enabled: isLoading,
          child:
              displaySources.isEmpty
                  ? Text(
                    "No sources found",
                    style: TextStyle(color: Colors.grey),
                  )
                  : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        displaySources.map<Widget>((res) {
                          return Container(
                            width: 150,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.cardColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  res['title'] ?? "Untitled",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  res["url"] ?? "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }
}

// import 'package:ai_search/services/chat_web_service.dart';
// import 'package:ai_search/themes/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:skeletonizer/skeletonizer.dart';

// class SourcesSection extends StatefulWidget {
//   final ChatWebService? chatService; // Accept chatService as parameter

//   const SourcesSection({super.key, this.chatService});

//   @override
//   State<SourcesSection> createState() => _SourcesSectionState();
// }

// class _SourcesSectionState extends State<SourcesSection> {
//   bool isLoading = true;
//   bool _hasError = false;
//   bool _hasReceivedValidData = false; // Track if we've received valid data
//   List searchResults = []; // Start with empty list - no hardcoded data
//   List? _lastValidResults; // Store last valid results
//   bool _isAIActive = false; // Track if AI is currently responding

//   @override
//   void initState() {
//     super.initState();

//     // Use the passed chatService or create a new one
//     final chatService = widget.chatService ?? ChatWebService();

//     try {
//       chatService.searchResultStream.listen(
//         (data) {
//           if (mounted) {
//             print('Sources received data: $data'); // Debug print

//             // Check if data is valid and contains results
//             if (data != null &&
//                 data['data'] != null &&
//                 data['data'] is List &&
//                 (data['data'] as List).isNotEmpty) {
//               // We have valid data
//               final newResults = data['data'] as List;

//               setState(() {
//                 searchResults = newResults;
//                 _lastValidResults = List.from(
//                   newResults,
//                 ); // Store copy of valid results
//                 isLoading = false;
//                 _hasError = false;
//                 _hasReceivedValidData = true;
//                 _isAIActive = false; // AI hasn't started responding yet
//               });
//             } else if (data != null &&
//                 data['data'] != null &&
//                 data['data'] is List &&
//                 (data['data'] as List).isEmpty &&
//                 _hasReceivedValidData) {
//               // If we receive empty array but had valid data before, keep the last valid results
//               print('Received empty array, keeping last valid results');
//               // Don't update anything - keep the current valid results
//             } else if (!_hasReceivedValidData) {
//               // Only set loading/error state if we haven't received valid data yet
//               setState(() {
//                 isLoading = false;
//                 _hasError = true;
//               });
//             }
//             // Ignore any other invalid data if we already have valid results
//           }
//         },
//         onError: (error) {
//           print('Sources stream error: $error'); // Debug print
//           if (mounted) {
//             setState(() {
//               isLoading = false;
//               // Only set error if we haven't received valid data before
//               if (!_hasReceivedValidData) {
//                 _hasError = true;
//               }
//               // If we had valid data before, keep showing it despite the error
//             });
//           }
//         },
//       );

//       // Listen to AI content to track when AI starts responding
//       chatService.contentStream.listen(
//         (data) {
//           if (mounted && data['type'] == 'content' && data['data'] != null) {
//             print(
//               'Sources received AI content: ${data['data']}',
//             ); // Debug print

//             // Mark AI as active when we receive content
//             if (!_isAIActive) {
//               setState(() {
//                 _isAIActive = true;
//               });
//               print('AI started responding, preserving sources');
//             }
//           }
//         },
//         onError: (error) {
//           print('Sources content stream error: $error'); // Debug print
//         },
//       );
//     } catch (e) {
//       print('Sources initialization error: $e'); // Debug print
//       setState(() {
//         isLoading = false;
//         _hasError = true;
//       });
//     }

//     // Set initial loading to false after a timeout to prevent infinite loading
//     Future.delayed(Duration(seconds: 3), () {
//       if (mounted && isLoading && !_hasReceivedValidData) {
//         setState(() {
//           isLoading = false;
//           _hasError = true;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Handle error state - only show if we truly have no valid data
//     if (_hasError && !_hasReceivedValidData && searchResults.isEmpty) {
//       return Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.cardColor,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.grey, size: 16),
//             SizedBox(width: 8),
//             Text(
//               'Sources temporarily unavailable',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }

//     // Show skeleton when loading OR when we have no sources to show yet
//     if (isLoading || (searchResults.isEmpty && _lastValidResults == null)) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.source_outlined, color: Colors.white70, size: 18),
//               SizedBox(width: 8),
//               Text(
//                 "Sources",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Container(
//             constraints: BoxConstraints(maxHeight: 200),
//             child: Skeletonizer(
//               enabled: true,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(children: _buildSkeletonSources()),
//               ),
//             ),
//           ),
//         ],
//       );
//     }

//     // Show sources if we have any data (either current or last valid)
//     final sourcesToShow =
//         searchResults.isNotEmpty ? searchResults : _lastValidResults;

//     if (sourcesToShow != null && sourcesToShow.isNotEmpty) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.source_outlined, color: Colors.white70, size: 18),
//               SizedBox(width: 8),
//               Text(
//                 "Sources",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//               if (_isAIActive) ...[
//                 SizedBox(width: 8),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.submitButton.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     'AI responding...',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: AppColors.submitButton,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//           SizedBox(height: 12),
//           Container(
//             constraints: BoxConstraints(maxHeight: 200),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children:
//                     sourcesToShow.map<Widget>((res) {
//                       return Container(
//                         width: 200,
//                         margin: EdgeInsets.only(right: 12),
//                         padding: EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: AppColors.cardColor,
//                           border: Border.all(
//                             color: AppColors.subtleBorder,
//                             width: 1,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               res['title'] ?? 'Untitled',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 13,
//                                 color: Colors.white,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               _extractDomain(res["url"] ?? ''),
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: AppColors.textGrey,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//               ),
//             ),
//           ),
//         ],
//       );
//     }

//     // Return empty container if no valid data and not in loading/error state
//     return SizedBox.shrink();
//   }

//   List<Widget> _buildSkeletonSources() {
//     return List.generate(3, (index) {
//       return Container(
//         width: 200,
//         margin: EdgeInsets.only(right: 12),
//         padding: EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: AppColors.cardColor,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 14,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             SizedBox(height: 8),
//             Container(
//               height: 12,
//               width: 100,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   String _extractDomain(String url) {
//     try {
//       final uri = Uri.parse(url);
//       return uri.host;
//     } catch (e) {
//       return url;
//     }
//   }
// }
