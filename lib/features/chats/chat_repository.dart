import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ← viktigt!
import 'chat_models.dart';

class ChatRepository {
  static const _kSessionsKey = 'sera.sessions';
  static String _kMessagesKey(String id) => 'sera.session.$id.messages';

  Future<List<ChatSessionMeta>> listSessions() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kSessionsKey);
    if (raw == null) return [];
    final list = decodeList(raw, ChatSessionMeta.fromJson);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> _saveSessions(List<ChatSessionMeta> list) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kSessionsKey, encodeList(list, (m) => m.toJson()));
  }

  Future<String> createSession({String? title}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final trimmed = title?.trim();
    final hasCustomTitle = trimmed?.isNotEmpty == true;
    final session = ChatSessionMeta(
      id: id,
      title: hasCustomTitle ? trimmed! : 'Ny chatt',
      updatedAt: DateTime.now(),
      customTitle: hasCustomTitle,
    );
    final all = await listSessions();
    await _saveSessions([session, ...all]);
    await _saveMessages(id, []);
    return id;
  }

  Future<void> renameSession(String id, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final all = await listSessions();
    final i = all.indexWhere((s) => s.id == id);
    if (i < 0) return;
    all[i] = all[i].copyWith(
      title: trimmed,
      updatedAt: DateTime.now(),
      customTitle: true,
    );
    await _saveSessions(all);
  }

  Future<void> renameSessionAuto(String id, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final all = await listSessions();
    final i = all.indexWhere((s) => s.id == id);
    if (i < 0) return;
    final session = all[i];
    if (session.customTitle) return;
    all[i] = session.copyWith(
      title: trimmed,
      updatedAt: DateTime.now(),
      customTitle: false,
    );
    await _saveSessions(all);
  }

  Future<void> touch(String id) async {
    final all = await listSessions();
    final i = all.indexWhere((s) => s.id == id);
    if (i < 0) return;
    all[i] = all[i].copyWith(updatedAt: DateTime.now());
    await _saveSessions(all);
  }

  Future<void> deleteSession(String id) async {
    final sp = await SharedPreferences.getInstance();
    final all = await listSessions();
    all.removeWhere((s) => s.id == id);
    await _saveSessions(all);
    await sp.remove(_kMessagesKey(id));
  }

  Future<List<ChatMessageDTO>> loadMessages(String id) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kMessagesKey(id));
    if (raw == null) return [];
    return decodeList(raw, ChatMessageDTO.fromJson);
  }

  Future<ChatSessionMeta?> getSession(String id) async {
    final all = await listSessions();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> appendMessages(String id, List<ChatMessageDTO> msgs) async {
    final all = await loadMessages(id);
    await _saveMessages(id, [...all, ...msgs]);
    await touch(id);
  }

  Future<void> overwriteMessages(String id, List<ChatMessageDTO> msgs) async {
    await _saveMessages(id, msgs);
    await touch(id);
  }

  Future<void> _saveMessages(String id, List<ChatMessageDTO> msgs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMessagesKey(id), encodeList(msgs, (m) => m.toJson()));
  }

  Future<List<ChatSessionMeta>> search(String q) async {
    final s = q.trim().toLowerCase();
    final all = await listSessions();
    if (s.isEmpty) return all;
    return all.where((e) => e.title.toLowerCase().contains(s)).toList();
  }
}

// ✅ Gemensam provider som alla filer importerar
final chatRepoProvider = Provider<ChatRepository>((ref) => ChatRepository());
