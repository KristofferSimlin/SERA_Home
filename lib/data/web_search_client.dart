import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WebSearchClient {
  final String? proxySearchUrl; // t.ex. https://api.sera.chat/api/openai-search

  WebSearchClient()
      : proxySearchUrl = (dotenv.env['PROXY_SEARCH_URL'] ?? '').trim().isNotEmpty
            ? dotenv.env['PROXY_SEARCH_URL']!.trim()
            : '/api/openai-search';

  Future<String?> searchSummary(String query) async {
    final url = proxySearchUrl;
    if (url == null || url.isEmpty) return null;
    final res = await http.get(Uri.parse('$url?q=${Uri.encodeQueryComponent(query)}'));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    // Nya schemat: { summary, hits: [{title, snippet, link}] }
    final summary = data['summary'];
    if (summary is String && summary.trim().isNotEmpty) {
      return summary.trim();
    }

    final hits = (data['hits'] as List?) ?? (data['items'] as List? ?? const []);
    if (hits.isEmpty) return null;
    final b = StringBuffer();
    for (final it in hits.take(5)) {
      final m = it as Map<String, dynamic>;
      final title = (m['title'] ?? '').toString();
      final snippet = (m['snippet'] ?? '').toString();
      final link = (m['link'] ?? '').toString();
      b.writeln('• $title — $snippet${link.isNotEmpty ? ' ($link)' : ''}');
    }
    return b.toString().trim();
  }
}
