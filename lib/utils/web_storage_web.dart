import 'dart:html' as html;

Future<String?> readLocalImpl(String key) async =>
    html.window.localStorage[key];

Future<void> writeLocalImpl(String key, String value) async {
  html.window.localStorage[key] = value;
}

Future<void> removeLocalImpl(String key) async {
  html.window.localStorage.remove(key);
}

Future<String?> readSessionImpl(String key) async =>
    html.window.sessionStorage[key];

Future<void> writeSessionImpl(String key, String value) async {
  html.window.sessionStorage[key] = value;
}

Future<void> removeSessionImpl(String key) async {
  html.window.sessionStorage.remove(key);
}
