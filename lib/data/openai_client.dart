import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../features/chat/chat_controller.dart';

const String _systemPrompt =
    'Du är SERA – en säkerhetsmedveten felsökningsassistent. '
    'Ställ följdfrågor först, börja med enkla kontroller, lägg alltid till '
    'Säkerhetsfilter vid el/hydraulik/bränsle/tryck/värme. '
    'Svara kort, på svenska, i punktlistor när det passar.';

class OpenAIClient {
  final bool useProxy;
  final String? proxyUrl;
  final String? directKey;

  OpenAIClient({
    required this.useProxy,
    this.proxyUrl,
    this.directKey,
  });

  factory OpenAIClient.fromSettings(SettingsState s) {
    final envProxy = dotenv.env['PROXY_URL'];
    final envKey = dotenv.env['OPENAI_API_KEY'];
    return OpenAIClient(
      useProxy: s.proxyEnabled,
      proxyUrl: s.proxyUrl?.isNotEmpty == true ? s.proxyUrl : envProxy,
      directKey: s.directApiKey?.isNotEmpty == true ? s.directApiKey : envKey,
    );
  }

  Future<String> completeChat(List<(bool, String)> history, String newUserMessage) async {
    if (useProxy) {
      if (proxyUrl == null || proxyUrl!.isEmpty) {
        throw 'PROXY_URL saknas. Ange i inställningar eller .env';
      }
      final res = await http.post(
        Uri.parse(proxyUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            ...history.map((e) => {
                  'role': e.$1 ? 'user' : 'assistant',
                  'content': e.$2,
                }),
            {'role': 'user', 'content': newUserMessage},
          ],
          'model': 'gpt-4o-mini',
        }),
      );
      if (res.statusCode == 401) {
        throw '401 (otillåten). Kontrollera proxy-konfiguration.';
      }
      if (res.statusCode >= 400) {
        throw 'Proxyfel ${res.statusCode}: ${res.body}';
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['text'] as String?) ?? data['content'] ?? data['reply'] ?? '[Tomt svar]';
    } else {
      if (directKey == null || directKey!.isEmpty) {
        throw 'OPENAI_API_KEY saknas. Ange i Inställningar eller .env';
      }
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $directKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            ...history.map((e) => {
                  'role': e.$1 ? 'user' : 'assistant',
                  'content': e.$2,
                }),
            {'role': 'user', 'content': newUserMessage},
          ],
          'temperature': 0.2,
          'stream': false,
        }),
      );
      if (res.statusCode == 401) {
        throw '401 (otillåten). Kontrollera API-nyckeln.';
      }
      if (res.statusCode >= 400) {
        throw 'OpenAI-fel ${res.statusCode}: ${res.body}';
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final choices = (data['choices'] as List?) ?? const [];
      final content = choices.isNotEmpty
          ? (choices.first['message']?['content'] as String? ?? '')
          : '';
      return content.isEmpty ? '[Tomt svar]' : content;
    }
  }
}
