// gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  GeminiService({required this.apiKey});

  Future<Map<String, dynamic>> generateContent({
    required List<Map<String, dynamic>> chatHistory,
    required List<Map<String, dynamic>> tools,
  }) async {
    final requestBody = {
      'contents': chatHistory,
      'tools':
          tools.isEmpty
              ? null
              : [
                {'functionDeclarations': tools},
              ],
      'generationConfig': {'temperature': 0.7, 'topK': 40, 'topP': 0.95},
    };

    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/models/gemini-2.0-flash-exp:generateContent?key=$apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      throw e;
    }
  }
}
