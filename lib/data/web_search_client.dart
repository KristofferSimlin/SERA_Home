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
    // förväntar { items: [{title, snippet, link}, ...] }
    final items = (data['items'] as List?) ?? const [];
    if (items.isEmpty) return null;
    final b = StringBuffer();
    for (final it in items.take(5)) {
      final m = it as Map<String, dynamic>;
      final title = m['title'] ?? '';
      final snippet = m['snippet'] ?? '';
      final link = m['link'] ?? '';
      b.writeln('• $title — $snippet ($link)');
    }
    return b.toString().trim();
  }
}
