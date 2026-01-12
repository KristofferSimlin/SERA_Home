import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

Future<String?> readLocalImpl(String key) async {
  final prefs = await _prefs();
  return prefs.getString(key);
}

Future<void> writeLocalImpl(String key, String value) async {
  final prefs = await _prefs();
  await prefs.setString(key, value);
}

Future<void> removeLocalImpl(String key) async {
  final prefs = await _prefs();
  await prefs.remove(key);
}

Future<String?> readSessionImpl(String key) => readLocalImpl(key);

Future<void> writeSessionImpl(String key, String value) =>
    writeLocalImpl(key, value);

Future<void> removeSessionImpl(String key) => removeLocalImpl(key);
