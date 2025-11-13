import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/openai_client.dart';

enum Role { user, assistant }

class Message {
  final Role role;
  final String text;
  final DateTime time;

  Message({required this.role, required this.text, DateTime? time})
      : time = time ?? DateTime.now();

  Message copyWith({String? text}) =>
      Message(role: role, text: text ?? this.text, time: time);
}

class ChatState {
  final List<Message> messages;
  final bool isSending;
  final bool hasSafetyRisk;

  ChatState({
    required this.messages,
    required this.isSending,
    required this.hasSafetyRisk,
  });

  ChatState.initial()
      : messages = const [],
        isSending = false,
        hasSafetyRisk = false;

  ChatState copyWith({
    List<Message>? messages,
    bool? isSending,
    bool? hasSafetyRisk,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      hasSafetyRisk: hasSafetyRisk ?? this.hasSafetyRisk,
    );
  }
}

// Inställningar
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

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final settings = ref.watch(settingsProvider);
  final client = OpenAIClient.fromSettings(settings);
  return ChatController(client: client, ref: ref);
});

class ChatController extends StateNotifier<ChatState> {
  ChatController({required this.client, required this.ref})
      : super(ChatState.initial());

  final OpenAIClient client;
  final Ref ref;

  static final _safetyRegex =
      RegExp(r'(el|hydraul|bränsle|tryck|värme)', caseSensitive: false);

  Future<void> send(String userText) async {
    state = state.copyWith(
      isSending: true,
      messages: [
        ...state.messages,
        Message(role: Role.user, text: userText),
      ],
      hasSafetyRisk: _hasSafety(userText) || state.hasSafetyRisk,
    );

    final history = state.messages
        .map((m) => (m.role == Role.user, m.text))
        .toList(growable: false);

    try {
      final fullText = await client.completeChat(history, userText);

      var assistant = Message(role: Role.assistant, text: '');
      state = state.copyWith(messages: [...state.messages, assistant]);

      const stepMs = 12;
      for (int i = 0; i < fullText.length; i++) {
        final chunk = fullText.substring(0, i + 1);
        final updated = Message(role: Role.assistant, text: chunk, time: assistant.time);
        final msgs = [...state.messages];
        msgs[msgs.length - 1] = updated;
        state = state.copyWith(
          messages: msgs,
          hasSafetyRisk: _hasSafety(chunk) || state.hasSafetyRisk,
        );
        await Future.delayed(const Duration(milliseconds: stepMs));
      }
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  bool _hasSafety(String text) => _safetyRegex.hasMatch(text);
}
