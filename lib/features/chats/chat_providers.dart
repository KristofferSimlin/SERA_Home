import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_models.dart';
import 'chat_repository.dart';

final sessionsProvider = FutureProvider<List<ChatSessionMeta>>((ref) {
  return ref.read(chatRepoProvider).listSessions();
});
