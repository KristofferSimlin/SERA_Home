import 'web_storage_stub.dart' if (dart.library.html) 'web_storage_web.dart';

Future<String?> readLocal(String key) => readLocalImpl(key);
Future<void> writeLocal(String key, String value) =>
    writeLocalImpl(key, value);
Future<void> removeLocal(String key) => removeLocalImpl(key);

Future<String?> readSession(String key) => readSessionImpl(key);
Future<void> writeSession(String key, String value) =>
    writeSessionImpl(key, value);
Future<void> removeSession(String key) => removeSessionImpl(key);
