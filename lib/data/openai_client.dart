import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../features/chat/chat_controller.dart';

const String _defaultProxyUrlHost = 'https://api.sera.chat/api/openai-proxy';
const String _defaultProxyUrlWeb = '/api/openai-proxy';

const String _baseSystemPrompt =
  'Du är SERA – en säkerhetsmedveten felsökningsassistent för maskiner.'
  '\nSTIL: Rak, professionell, jordnära. Inga artighetsfraser.'
  '\nEKO: Upprepa inte användarens text. Citera kort endast vid behov.'
  '\nTON: Svenska. Korta stycken, punktlistor när det passar.'
  '\nBETEENDE: Ställ 1–2 följdfrågor vid oklarheter. Ge tydliga nästa steg.'
  '\nSÄKERHET: Lägg alltid till Säkerhetsfilter om el/hydraulik/bränsle/tryck/värme berörs.'
  '\nUNDVIK: "Som en AI", överdriven artighet, ursäkter.';

String _expertiseAddon(int? level) {
  switch (level) {
    case 1:
      return '\nEXPERTIS=1 (nybörjare): Förklara enkelt, steg-för-steg och inkludera grundkontroller.';
    case 2:
      return '\nEXPERTIS=2 (medel): Anta viss vana. Balansera grundkontroller och mätpunkter.';
    case 3:
      return '\nEXPERTIS=3 (expert): Hoppa över triviala kontroller. Gå direkt på sannolika orsaker, mätvärden, toleranser.';
    default:
      return '\nEXPERTIS=okänd: fråga kort om nivå, annars anta medel.';
  }
}

String _equipmentAddon({String? brand, String? model, String? year}) {
  final parts = <String>[];
  if ((brand ?? '').isNotEmpty) parts.add('Märke: $brand');
  if ((model ?? '').isNotEmpty) parts.add('Modell: $model');
  if ((year ?? '').isNotEmpty) parts.add('Årsmodell: $year');
  if (parts.isEmpty) {
    return '\nUTRUSTNING: okänd (be användaren om märke, modell, årsmodell).';
  }
  return '\nUTRUSTNING: ${parts.join(', ')}';
}

String _webNotesAddon(String? webNotes) {
  if (webNotes == null || webNotes.trim().isEmpty) return '';
  return '\nWEBB-TRÄFFAR (sammanfattning, använd om relevant):\n$webNotes';
}

String _postProcess(String s) {
  final polite = RegExp(
    r'^(tack(?: så mycket)?(?: för att du| för info| för information)?|'
    r'hoppas allt är bra|tack för ditt meddelande|tack för att du hör av dig)[\.\!\,\s\-–—:]*',
    caseSensitive: false,
  );
  var out = s.trimLeft().replaceFirst(polite, '');
  final echo = RegExp(r'^(du (säger|skriver|nämner) att[:\s]+)', caseSensitive: false);
  out = out.replaceFirst(echo, '');
  return out.trimLeft();
}

String _contentFromList(List<dynamic> content) {
  final buffer = StringBuffer();
  for (final part in content) {
    if (part is String) {
      buffer.write(part);
      continue;
    }
    if (part is Map<String, dynamic>) {
      final textField = part['text'];
      if (textField is String) {
        buffer.write(textField);
        continue;
      }
      if (textField is Map) {
        final value = textField['value'] ?? textField['content'];
        if (value is String) {
          buffer.write(value);
          continue;
        }
      }
      final innerContent = part['content'];
      if (innerContent is String) {
        buffer.write(innerContent);
      }
    }
  }
  return buffer.toString();
}

String _extractText(Map<String, dynamic> data) {
  final choices = data['choices'];
  if (choices is List && choices.isNotEmpty) {
    final first = choices.first;
    final message = first is Map<String, dynamic> ? first['message'] : null;
    if (message is Map<String, dynamic>) {
      final content = message['content'];
      if (content is String && content.trim().isNotEmpty) {
        return content;
      }
      if (content is List && content.isNotEmpty) {
        final combined = _contentFromList(content);
        if (combined.trim().isNotEmpty) return combined;
      }
    }
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    final text = first is Map<String, dynamic> ? first['text'] : null;
    if (text is String && text.trim().isNotEmpty) return text;
  }
  final topLevel =
      data['text'] ?? data['content'] ?? data['reply'] ?? data['response'];
  if (topLevel is String) return topLevel;
  return '';
}

class OpenAIClient {
  final bool useProxy;
  final String? proxyUrl;    // /chat
  final String? directKey;

  OpenAIClient({
    required this.useProxy,
    this.proxyUrl,
    this.directKey,
  });

  factory OpenAIClient.fromSettings(SettingsState s) {
    final envProxy = (dotenv.env['PROXY_URL'] ?? '').trim();
    final envKey = dotenv.env['OPENAI_API_KEY'];
    final resolvedProxy = (s.proxyUrl?.isNotEmpty == true)
        ? s.proxyUrl!.trim()
        : (envProxy.isNotEmpty
            ? envProxy
            : (kIsWeb ? _defaultProxyUrlWeb : _defaultProxyUrlHost));
    return OpenAIClient(
      useProxy: s.proxyEnabled,
      proxyUrl: resolvedProxy,
      directKey: s.directApiKey?.isNotEmpty == true ? s.directApiKey : envKey,
    );
  }

  Future<String> completeChat(
    List<(bool, String)> history,
    String newUserMessage, {
    int? expertise,
    String? brand,
    String? model,
    String? year,
    String? webNotes, // sammanfattning från webbsök
  }) async {
    final systemPrompt = _baseSystemPrompt
        + _expertiseAddon(expertise)
        + _equipmentAddon(brand: brand, model: model, year: year)
        + _webNotesAddon(webNotes);

    if (useProxy) {
      if (proxyUrl == null || proxyUrl!.isEmpty) {
        throw 'PROXY_URL saknas. Ange i inställningar eller .env';
      }
      final res = await http.post(
        Uri.parse(proxyUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...history.map((e) => {'role': e.$1 ? 'user' : 'assistant', 'content': e.$2}),
            {'role': 'user', 'content': newUserMessage},
          ],
          'model': 'gpt-4o-mini',
          'temperature': 0.2,
        }),
      );
      if (res.statusCode == 401) throw '401 (otillåten). Kontrollera proxy-konfiguration.';
      if (res.statusCode >= 400) throw 'Proxyfel ${res.statusCode}: ${res.body}';
      // Debug-logga proxysvaret för felsökning
      debugPrint('Proxy response: ${res.body}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = _extractText(data);
      return _postProcess(text.isEmpty ? '[Tomt svar]' : text);
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
            {'role': 'system', 'content': systemPrompt},
            ...history.map((e) => {'role': e.$1 ? 'user' : 'assistant', 'content': e.$2}),
            {'role': 'user', 'content': newUserMessage},
          ],
          'temperature': 0.2,
          'stream': false,
        }),
      );
      if (res.statusCode == 401) throw '401 (otillåten). Kontrollera API-nyckeln.';
      if (res.statusCode >= 400) throw 'OpenAI-fel ${res.statusCode}: ${res.body}';
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = _extractText(data);
      return _postProcess(text.isEmpty ? '[Tomt svar]' : text);
    }
  }
}
