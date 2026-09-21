import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static Future<String> generateResponse({
    required String prompt,
    required String apiKey,
    String model = "gemini",
  }) async {
    if (apiKey.isEmpty) {
      return "Hello! AutoSend AI received: '$prompt'. (Configure AI API Key in Settings for smart replies)";
    }

    if (model == "openai") {
      return _callOpenAI(prompt, apiKey);
    } else {
      return _callGemini(prompt, apiKey);
    }
  }

  static Future<String> _callGemini(String prompt, String apiKey) async {
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'You are an automated assistant replying to WhatsApp chats. Generate a concise, polite, and helpful response for: $prompt'
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final candidates = json['candidates'] as List;
        if (candidates.isNotEmpty) {
          final text = candidates[0]['content']['parts'][0]['text'];
          return text.toString().trim();
        }
      }
    } catch (e) {}
    return "Thank you for your message! AutoSend AI received: $prompt";
  }

  static Future<String> _callOpenAI(String prompt, String apiKey) async {
    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful automated WhatsApp auto-responder.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final text = json['choices'][0]['message']['content'];
        return text.toString().trim();
      }
    } catch (e) {}
    return "AutoSend AI: Received '$prompt'";
  }
}
