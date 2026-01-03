/// Helper to extract auth-related params (access_token, refresh_token, type, token, token_hash)
/// from both query and fragment parts of a URI.
Map<String, String> parseAuthParams(Uri uri) {
  final params = <String, String>{};

  void addAllSafe(String? query) {
    if (query == null || query.isEmpty) return;
    try {
      params.addAll(Uri.splitQueryString(query));
    } catch (_) {
      // ignore malformed fragments
    }
  }

  // Query string (?a=b&c=d)
  addAllSafe(uri.query);

  // Fragment (#a=b&c=d or #/activate?a=b)
  var frag = uri.fragment;
  if (frag.isNotEmpty) {
    // If fragment contains '?', take the part after '?'
    if (frag.contains('?')) {
      frag = frag.split('?').last;
    }
    // If fragment still contains '#', take the part after '#'
    if (frag.contains('#')) {
      frag = frag.split('#').last;
    }
    addAllSafe(frag);
  }

  return params;
}
