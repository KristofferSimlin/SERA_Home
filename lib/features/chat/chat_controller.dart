import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/openai_client.dart';
import '../chats/chat_repository.dart';
import '../chats/chat_models.dart';



enum Role { user, assistant }

class Message {
  final Role role;
  final String text;
  final DateTime time;

  Message({required this.role, required this.text, DateTime? time})
      : time = time ?? DateTime.now();

  ChatMessageDTO toDto() =>
      ChatMessageDTO(role: role == Role.user ? 'user' : 'assistant', text: text, time: time);

  static Message fromDto(ChatMessageDTO d) =>
      Message(role: d.role == 'user' ? Role.user : Role.assistant, text: d.text, time: d.time);
}

class ChatState {
  final String sessionId;
  final List<Message> messages;
  final bool isSending;
  final bool hasSafetyRisk;

  ChatState({
    required this.sessionId,
    required this.messages,
    required this.isSending,
    required this.hasSafetyRisk,
  });

  ChatState.initial(String sessionId)
      : sessionId = sessionId,
        messages = const [],
        isSending = false,
        hasSafetyRisk = false;

  ChatState copyWith({
    List<Message>? messages,
    bool? isSending,
    bool? hasSafetyRisk,
  }) {
    return ChatState(
      sessionId: sessionId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      hasSafetyRisk: hasSafetyRisk ?? this.hasSafetyRisk,
    );
  }
}

// Inställningar (oförändrat)
class SettingsState {
  final bool proxyEnabled;
  final String? proxyUrl;
  final String? directApiKey;

  SettingsState({
    required this.proxyEnabled,
    this.proxyUrl,
    this.directApiKey,
  });

  SettingsState copyWith({
    bool? proxyEnabled,
    String? proxyUrl,
    String? directApiKey,
  }) {
    return SettingsState(
      proxyEnabled: proxyEnabled ?? this.proxyEnabled,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      directApiKey: directApiKey ?? this.directApiKey,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(proxyEnabled: true, proxyUrl: null, directApiKey: null));

  void setProxyEnabled(bool v) => state = state.copyWith(proxyEnabled: v);
  void setProxyUrl(String v) => state = state.copyWith(proxyUrl: v);
  void setDirectKey(String v) => state = state.copyWith(directApiKey: v);
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

// ⚠️ Provider FAMILY: ett ChatController per sessionId
final chatControllerProvider =
    StateNotifierProvider.family<ChatController, ChatState, String>((ref, sessionId) {
  final settings = ref.watch(settingsProvider);
  final client = OpenAIClient.fromSettings(settings);
  final repo = ref.watch(chatRepoProvider);
  return ChatController(sessionId: sessionId, client: client, repo: repo);
});

class ChatController extends StateNotifier<ChatState> {
  ChatController({required this.sessionId, required this.client, required this.repo})
      : super(ChatState.initial(sessionId)) {
    _load();
  }

  final String sessionId;
  final OpenAIClient client;
  final ChatRepository repo;

  static final _safetyRegex =
      RegExp(r'(el|hydraul|bränsle|tryck|värme)', caseSensitive: false);

  Future<void> _load() async {
    final raw = await repo.loadMessages(sessionId);
    final msgs = raw.map(Message.fromDto).toList();
    state = state.copyWith(messages: msgs, hasSafetyRisk: _computeSafety(msgs));
  }

  bool _computeSafety(List<Message> msgs) =>
      msgs.any((m) => _safetyRegex.hasMatch(m.text));

  Future<void> send(String userText) async {
    final newUser = Message(role: Role.user, text: userText);
    state = state.copyWith(
      isSending: true,
      messages: [...state.messages, newUser],
      hasSafetyRisk: _safetyRegex.hasMatch(userText) || state.hasSafetyRisk,
    );
    await repo.appendMessages(
      sessionId,
      [newUser.toDto()],
    );

    final history = state.messages
        .map((m) => (m.role == Role.user, m.text))
        .toList(growable: false);

    try {
      final fullText = await client.completeChat(history, userText);

      // streaming-simulering
      var assistant = Message(role: Role.assistant, text: '');
      var msgs = [...state.messages, assistant];
      state = state.copyWith(messages: msgs);

      const stepMs = 12;
      for (int i = 0; i < fullText.length; i++) {
        final chunk = fullText.substring(0, i + 1);
        assistant = assistant.copyWith(text: chunk);
        msgs[msgs.length - 1] = assistant;
        state = state.copyWith(
          messages: [...msgs],
          hasSafetyRisk: _safetyRegex.hasMatch(chunk) || state.hasSafetyRisk,
        );
        await Future.delayed(const Duration(milliseconds: stepMs));
      }

      // spara slutligt assistantsvar
      await repo.appendMessages(sessionId, [assistant.toDto()]);

      // första raden i svaret → döp om titel om det är en helt ny chatt
      if (state.messages.length <= 2) {
        final firstLine = assistant.text.split('\n').first.trim();
        if (firstLine.isNotEmpty) {
          await repo.renameSession(sessionId, firstLine.length > 40 ? '${firstLine.substring(0, 40)}…' : firstLine);
        }
      }
    } finally {
      state = state.copyWith(isSending: false);
    }
  }
}

extension on Message {
  Message copyWith({String? text}) =>
      Message(role: role, text: text ?? this.text, time: time);
}
