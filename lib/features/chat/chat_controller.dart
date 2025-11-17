// lib/features/chat/chat_controller.dart
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

  Message copyWith({String? text}) =>
      Message(role: role, text: text ?? this.text, time: time);

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

  // Meta om användaren/utrustningen
  final int? expertise;        // 1/2/3
  final String? brand;
  final String? model;
  final String? year;

  // Lås som gör att vi inte frågar om utrustning igen när den väl är satt
  final bool equipmentLocked;

  const ChatState({
    required this.sessionId,
    required this.messages,
    required this.isSending,
    required this.hasSafetyRisk,
    required this.expertise,
    required this.brand,
    required this.model,
    required this.year,
    required this.equipmentLocked,
  });

  factory ChatState.initial(String sessionId) => ChatState(
        sessionId: sessionId,
        messages: const [],
        isSending: false,
        hasSafetyRisk: false,
        expertise: null,
        brand: null,
        model: null,
        year: null,
        equipmentLocked: false,
      );

  ChatState copyWith({
    List<Message>? messages,
    bool? isSending,
    bool? hasSafetyRisk,
    int? expertise,
    String? brand,
    String? model,
    String? year,
    bool? equipmentLocked,
    bool keepMeta = false,
  }) {
    return ChatState(
      sessionId: sessionId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      hasSafetyRisk: hasSafetyRisk ?? this.hasSafetyRisk,
      expertise: keepMeta ? this.expertise : (expertise ?? this.expertise),
      brand: keepMeta ? this.brand : (brand ?? this.brand),
      model: keepMeta ? this.model : (model ?? this.model),
      year: keepMeta ? this.year : (year ?? this.year),
      equipmentLocked:
          keepMeta ? this.equipmentLocked : (equipmentLocked ?? this.equipmentLocked),
    );
  }
}

/// Inställningar (proxy/direkt, webbsök)
class SettingsState {
  final bool proxyEnabled;
  final String? proxyUrl; // /chat
  final String? directApiKey;
  final bool webLookupEnabled;

  const SettingsState({
    required this.proxyEnabled,
    this.proxyUrl,
    this.directApiKey,
    this.webLookupEnabled = false,
  });

  SettingsState copyWith({
    bool? proxyEnabled,
    String? proxyUrl,
    String? directApiKey,
    bool? webLookupEnabled,
  }) {
    return SettingsState(
      proxyEnabled: proxyEnabled ?? this.proxyEnabled,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      directApiKey: directApiKey ?? this.directApiKey,
      webLookupEnabled: webLookupEnabled ?? this.webLookupEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(const SettingsState(proxyEnabled: true, proxyUrl: null, directApiKey: null));

  void setProxyEnabled(bool v) => state = state.copyWith(proxyEnabled: v);
  void setProxyUrl(String v) => state = state.copyWith(proxyUrl: v);
  void setDirectKey(String v) => state = state.copyWith(directApiKey: v);
  void setWebLookup(bool v) => state = state.copyWith(webLookupEnabled: v);
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

final chatControllerProvider =
    StateNotifierProvider.family<ChatController, ChatState, String>((ref, sessionId) {
  final settings = ref.watch(settingsProvider);
  final client = OpenAIClient.fromSettings(settings);
  final repo = ref.read(chatRepoProvider);
  return ChatController(sessionId: sessionId, client: client, repo: repo, settings: settings);
});

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required this.sessionId,
    required this.client,
    required this.repo,
    required this.settings,
  }) : super(ChatState.initial(sessionId)) {
    _load();
  }

  final String sessionId;
  final OpenAIClient client;
  final ChatRepository repo;
  SettingsState settings;

  static final _safetyRegex = RegExp(
    r'(?:(?<!\p{L})(el|elektr(?:isk|icitet)|hydraul(?:ik|system)?|bränsle|diesel|bensin|tryck|högt\s+tryck|värme|heta\s+y(?:t|tor))(?!\p{L}))',
    caseSensitive: false,
    unicode: true,
  );

  bool _lastMessageIsRisk(List<Message> msgs) =>
      msgs.isNotEmpty && _safetyRegex.hasMatch(msgs.last.text);

  Future<void> _load() async {
    final raw = await repo.loadMessages(sessionId);
    var msgs = raw.map(Message.fromDto).toList();

    // Helt ny chatt → fråga först efter expertis 1/2/3
    if (msgs.isEmpty) {
      final ask = Message(
        role: Role.assistant,
        text: 'Välj nivå:\n1) Nybörjare\n2) Medel\n3) Expert\nSvara med 1, 2 eller 3.',
      );
      msgs = [ask];
      await repo.appendMessages(sessionId, [ask.toDto()]);
    }

    state = state.copyWith(messages: msgs, hasSafetyRisk: _lastMessageIsRisk(msgs));
  }

  int? _parseExpertiseSelection(String s) {
    final m = RegExp(r'^\s*([123])\s*$').firstMatch(s);
    return m == null ? null : int.parse(m.group(1)!);
  }

  // Tålig tolkning: funkar för "Volvo EC250E 2019" OCH "märke: volvo, modell: ec250e, år: 2019"
  ({String? brand, String? model, String? year}) _extractEquipment(String s) {
    final lower = s.toLowerCase();

    // Nyckelordformat
    final brandK = RegExp(r'\bmärke\s*:\s*([^\n,;]+)', caseSensitive: false).firstMatch(s);
    final modelK = RegExp(r'\bmodell\s*:\s*([^\n,;]+)', caseSensitive: false).firstMatch(s);
    final yearK  = RegExp(r'\b(år|årsmodell)\s*:\s*(\d{4})', caseSensitive: false).firstMatch(s);

    String? brand = brandK?.group(1)?.trim();
    String? model = modelK?.group(1)?.trim();
    String? year  = yearK?.group(2)?.trim();

    // Fritextformat som fallback
    year ??= RegExp(r'\b(19|20)\d{2}\b').firstMatch(s)?.group(0);
    if (brand == null || model == null) {
      final words = s.trim().split(RegExp(r'\s+'));
      if (words.isNotEmpty) brand ??= words.first;
      if (words.length >= 2) {
        final filtered = words.where((w) => w != year).toList();
        if (filtered.length >= 2) {
          model ??= filtered.sublist(1).join(' ');
        }
      }
    }

    // Städa triviala ord
    if (brand != null && brand.toLowerCase().startsWith('märke')) brand = null;
    if (model != null && model.toLowerCase().startsWith('modell')) model = null;

    return (brand: _clean(brand), model: _clean(model), year: _clean(year));
  }

  String? _clean(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  bool _hasEquipment(ChatState st) =>
      (st.brand?.isNotEmpty == true) && (st.model?.isNotEmpty == true) && (st.year?.isNotEmpty == true);

  bool _isChangeEquipmentCommand(String s) {
    final x = s.toLowerCase().trim();
    return x.startsWith('/byt') ||
           x.startsWith('byt utrustning') ||
           x.startsWith('ändra utrustning') ||
           x.startsWith('byta utrustning');
  }

  Future<void> send(String userText) async {
    // 0) Special: användaren vill byta utrustning manuellt
    if (_isChangeEquipmentCommand(userText)) {
      final u = Message(role: Role.user, text: userText);
      final a = Message(
        role: Role.assistant,
        text: 'Ok, uppdatera märke, modell och årsmodell (t.ex. "Märke: Volvo, Modell: EC250E, År: 2019").',
      );
      final msgs = [...state.messages, u, a];
      state = state.copyWith(
        messages: msgs,
        hasSafetyRisk: _safetyRegex.hasMatch(a.text),
        brand: null, model: null, year: null,
        equipmentLocked: false,
      );
      await repo.appendMessages(sessionId, [u.toDto(), a.toDto()]);
      return;
    }

    // 1) Hantera första valet av expertis
    if (state.expertise == null) {
      final pick = _parseExpertiseSelection(userText);
      if (pick != null) {
        final userMsg = Message(role: Role.user, text: userText);
        final confirm = Message(
          role: Role.assistant,
          text: switch (pick) {
            1 => 'Ok. Jag förklarar stegvis. Vilket märke, modell och årsmodell?',
            2 => 'Noterat. Ange märke, modell och årsmodell.',
            _ => 'Klart. Ange märke, modell och årsmodell för exakt guidning.',
          },
        );
        final next = [...state.messages, userMsg, confirm];
        state = state.copyWith(
          messages: next,
          hasSafetyRisk: _safetyRegex.hasMatch(confirm.text),
          expertise: pick,
          equipmentLocked: false,
        );
        await repo.appendMessages(sessionId, [userMsg.toDto(), confirm.toDto()]);
        return;
      }
    }

    // 2) Lägg till användarens meddelande
    final newUser = Message(role: Role.user, text: userText);
    var msgs = [...state.messages, newUser];

    // 3) Uppdatera utrustning om den inte var låst än
    String? brand = state.brand, model = state.model, year = state.year;
    if (!state.equipmentLocked) {
      final eq = _extractEquipment(userText);
      brand ??= eq.brand;
      model ??= eq.model;
      year  ??= eq.year;
    }

    // 4) Ska vi fråga efter saknade bitar? Endast om INTE låst ännu.
    if (!state.equipmentLocked) {
      final missing = <String>[];
      if (brand == null || brand.isEmpty) missing.add('märke');
      if (model == null || model.isEmpty) missing.add('modell');
      if (year == null || year.isEmpty) missing.add('årsmodell');

      // Spara användarens meddelande först
      state = state.copyWith(
        isSending: true,
        messages: msgs,
        hasSafetyRisk: _safetyRegex.hasMatch(newUser.text),
        brand: brand, model: model, year: year,
        keepMeta: true,
      );
      await repo.appendMessages(sessionId, [newUser.toDto()]);

      if (missing.isNotEmpty) {
        final ask = Message(
          role: Role.assistant,
          text: 'För att vara specifik, saknas: ${missing.join(', ')}. '
                'Svara t.ex: "Märke: Volvo, Modell: EC250E, År: 2019". '
                'Vill du byta senare, skriv "/byt".',
        );
        msgs = [...msgs, ask];
        state = state.copyWith(
          messages: msgs,
          hasSafetyRisk: _safetyRegex.hasMatch(ask.text),
          keepMeta: true,
          isSending: false,
        );
        await repo.appendMessages(sessionId, [ask.toDto()]);
        return;
      } else {
        // All utrustning finns → lås så vi inte frågar igen
        state = state.copyWith(equipmentLocked: true, keepMeta: true);
      }
    } else {
      // Utrustning är redan låst — bara spara användarens meddelande
      state = state.copyWith(
        isSending: true,
        messages: msgs,
        hasSafetyRisk: _safetyRegex.hasMatch(newUser.text),
        keepMeta: true,
      );
      await repo.appendMessages(sessionId, [newUser.toDto()]);
    }

    // 5) Hämta ev. webbnotiser (om påslaget) och svara
    String? webNotes;
    if (settings.webLookupEnabled && _hasEquipment(state)) {
      // Webbsök sköts i OpenAIClient via systempromptens "webNotes" om du kopplat in
      // en faktisk webbsök-klient. Här håller vi oss till befintlig arkitektur.
      // (Om du redan infört WebSearchClient i tidigare steg, skicka in webNotes via client.completeChat)
      webNotes = null;
    }

    final history = state.messages
        .map<(bool, String)>((m) => (m.role == Role.user, m.text))
        .toList(growable: false);

    try {
      final fullText = await client.completeChat(
        history,
        userText,
        expertise: state.expertise,
        brand: state.brand,
        model: state.model,
        year: state.year,
        webNotes: webNotes,
      );

      var assistant = Message(role: Role.assistant, text: '');
      msgs = [...msgs, assistant];
      state = state.copyWith(messages: msgs, hasSafetyRisk: false, keepMeta: true);

      // Simulerad streaming
      const stepMs = 12;
      for (int i = 0; i < fullText.length; i++) {
        final chunk = fullText.substring(0, i + 1);
        assistant = assistant.copyWith(text: chunk);
        msgs[msgs.length - 1] = assistant;
        state = state.copyWith(
          messages: [...msgs],
          hasSafetyRisk: _safetyRegex.hasMatch(chunk),
          keepMeta: true,
        );
        await Future.delayed(const Duration(milliseconds: stepMs));
      }

      await repo.appendMessages(sessionId, [assistant.toDto()]);

      // Döp titel på första “riktiga” svaret
      if (msgs.length <= 3) {
        final firstLine = assistant.text.split('\n').first.trim();
        if (firstLine.isNotEmpty) {
          final title = firstLine.length > 40 ? '${firstLine.substring(0, 40)}…' : firstLine;
          await repo.renameSession(sessionId, title);
        }
      }
    } finally {
      state = state.copyWith(isSending: false, keepMeta: true);
    }
  }
}
