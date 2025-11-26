// lib/features/chat/chat_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/openai_client.dart';
import '../../data/web_search_client.dart';
import '../chats/chat_repository.dart';
import '../chats/chat_models.dart';

/// Bytt namn för att undvika krockar med andra "Role"
enum ChatRole { user, assistant }

class Message {
  final ChatRole role;
  final String text;
  final DateTime time;

  Message({
    required this.role,
    required this.text,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  Message copyWith({String? text}) =>
      Message(role: role, text: text ?? this.text, time: time);

  ChatMessageDTO toDto() => ChatMessageDTO(
        role: role == ChatRole.user ? 'user' : 'assistant',
        text: text,
        time: time,
      );

  static Message fromDto(ChatMessageDTO d) => Message(
        role: d.role == 'user' ? ChatRole.user : ChatRole.assistant,
        text: d.text,
        time: d.time,
      );
}

class ChatState {
  final String sessionId;
  final List<Message> messages;
  final bool isSending;
  final bool hasSafetyRisk;

  // Meta
  final int? expertise; // 1/2/3
  final String? brand;
  final String? model;
  final String? year;

  // UI-beteende
  final bool equipmentLocked;
  final bool askedEquipment;

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
    required this.askedEquipment,
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
        askedEquipment: false,
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
    bool? askedEquipment,
  }) {
    return ChatState(
      sessionId: sessionId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      hasSafetyRisk: hasSafetyRisk ?? this.hasSafetyRisk,
      expertise: expertise ?? this.expertise,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      equipmentLocked: equipmentLocked ?? this.equipmentLocked,
      askedEquipment: askedEquipment ?? this.askedEquipment,
    );
  }
}

/// Inställningar (proxy/direkt, webbsök)
class SettingsState {
  final bool proxyEnabled;
  final String? proxyUrl; // t.ex. https://api.sera.chat/api/openai-proxy
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
      : super(SettingsState(
          proxyEnabled: true,
          // Default to same-origin proxy in web builds to avoid CORS/redirect issues.
          proxyUrl: kIsWeb ? '/api/openai-proxy' : null,
          directApiKey: null,
        ));

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
  return ChatController(
    sessionId: sessionId,
    client: client,
    repo: repo,
    settings: settings,
  );
});

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required this.sessionId,
    required this.client,
    required this.repo,
    required this.settings,
  }) : super(ChatState.initial(sessionId)) {
    _init(); // starta asynkront
  }

  final String sessionId;
  final OpenAIClient client;
  final ChatRepository repo;
  SettingsState settings;
  final WebSearchClient _webSearch = WebSearchClient();

  // ---- Persistensnycklar (per sessionId) ----
  String get _kBrand     => 'equip_${sessionId}_brand';
  String get _kModel     => 'equip_${sessionId}_model';
  String get _kYear      => 'equip_${sessionId}_year';
  String get _kLock      => 'equip_${sessionId}_locked';
  String get _kExpertise => 'equip_${sessionId}_expertise';

  // Säkerhetsord (el/hydraul/bränsle/tryck/värme)
  static final _safetyRegex = RegExp(
    r'(?:(?<!\p{L})(el|elektr(?:isk|icitet)|hydraul(?:ik|system)?|bränsle|diesel|bensin|tryck|högt\s+tryck|värme|heta\s+y(?:t|tor))(?!\p{L}))',
    caseSensitive: false,
    unicode: true,
  );

  bool _lastMessageIsRisk(List<Message> msgs) {
    return msgs.isNotEmpty && _safetyRegex.hasMatch(msgs.last.text);
  }

  Future<void> _init() async {
    // 1) Läs historik från repo
    final raw = await repo.loadMessages(sessionId);
    var msgs = raw.map(Message.fromDto).toList();

    // För helt nya sessioner: hälsa och tipsa om utrustningsinfo
    if (msgs.isEmpty) {
      final intro = Message(
        role: ChatRole.assistant,
        text:
            'Hej! Jag är SERA – Service & Equipment Repair Assistant. Fyll gärna i märke, modell, årsmodell och din kunskapsnivå så kan jag hjälpa dig mer träffsäkert.',
      );
      msgs = [intro];
      await repo.appendMessages(sessionId, [intro.toDto()]);
    }

    // 2) Uppdatera state
    state = state.copyWith(
      messages: msgs,
      hasSafetyRisk: _lastMessageIsRisk(msgs),
    );

    // 3) Läs utrustning + kunskapsnivå från prefs
    await _loadMetaFromPrefs();
  }

  Future<void> _loadMetaFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final b = p.getString(_kBrand);
    final m = p.getString(_kModel);
    final y = p.getString(_kYear);
    final l = p.getBool(_kLock);
    final x = p.getInt(_kExpertise);
    state = state.copyWith(
      brand: b ?? state.brand,
      model: m ?? state.model,
      year:  y ?? state.year,
      equipmentLocked: l ?? state.equipmentLocked,
      expertise: x ?? state.expertise,
    );
  }

  Future<void> _saveEquipmentToPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (state.brand != null)  await p.setString(_kBrand, state.brand!);
    if (state.model != null)  await p.setString(_kModel, state.model!);
    if (state.year  != null)  await p.setString(_kYear,  state.year!);
    await p.setBool(_kLock, state.equipmentLocked);
  }

  Future<void> _saveExpertiseToPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (state.expertise == null) {
      await p.remove(_kExpertise);
    } else {
      await p.setInt(_kExpertise, state.expertise!);
    }
  }

  // ---- Enda sättet att ändra utrustning: via UI-rutorna ----
  void updateEquipment({String? brand, String? model, String? year, bool lock = false}) {
    state = state.copyWith(
      brand: brand ?? state.brand,
      model: model ?? state.model,
      year:  year  ?? state.year,
      equipmentLocked: lock ? true : state.equipmentLocked,
      askedEquipment: true,
    );
    _saveEquipmentToPrefs();
    unawaited(_maybeRenameFromEquipment());
  }

  void setEquipmentLocked(bool v) {
    state = state.copyWith(equipmentLocked: v);
    _saveEquipmentToPrefs();
  }

  // ---- Kunskapsnivå sätts från dropdown i UI ----
  void setExpertise(int? level) {
    int? valid;
    if (level == null || level == 1 || level == 2 || level == 3) {
      valid = level;
    } else {
      valid = null;
    }
    state = state.copyWith(expertise: valid);
    _saveExpertiseToPrefs();
  }

  void suppressEquipmentQuestion() {
    state = state.copyWith(askedEquipment: true);
  }

  bool _isChangeEquipmentCommand(String s) {
    final x = s.toLowerCase().trim();
    return x.startsWith('/byt') ||
        x.startsWith('byt utrustning') ||
        x.startsWith('ändra utrustning') ||
        x.startsWith('byta utrustning');
  }

  Future<String?> _fetchWebNotes(String userText) async {
    final brand = state.brand?.trim();
    final model = state.model?.trim();
    final year = state.year?.trim();
    final parts = <String>[];
    if (brand?.isNotEmpty == true) parts.add(brand!);
    if (model?.isNotEmpty == true) parts.add(model!);
    if (year?.isNotEmpty == true) parts.add(year!);
    final contextQuery = parts.join(' ');
    final combined = [contextQuery, userText.trim()]
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();
    if (combined.length < 4) return null;
    try {
      return await _webSearch.searchSummary(combined);
    } catch (e, st) {
      debugPrint('Web lookup error: $e\n$st');
      return null;
    }
  }

  Future<void> send(String userText) async {
    // /byt: påminn att använda rutorna – ändra inget automatiskt
    if (_isChangeEquipmentCommand(userText)) {
      final u = Message(role: ChatRole.user, text: userText);
      final a = Message(
        role: ChatRole.assistant,
        text: 'Uppdatera märke, modell och årsmodell i fälten ovan. Chatten ändrar inte utrustning.',
      );
      final msgs = [...state.messages, u, a];
      state = state.copyWith(
        messages: msgs,
        hasSafetyRisk: _safetyRegex.hasMatch(a.text),
        askedEquipment: true,
      );
      await repo.appendMessages(sessionId, [u.toDto(), a.toDto()]);
      return;
    }

    // Vanligt användarmeddelande
    final newUser = Message(role: ChatRole.user, text: userText);
    var msgs = [...state.messages, newUser];

    state = state.copyWith(
      isSending: true,
      messages: msgs,
      hasSafetyRisk: _safetyRegex.hasMatch(newUser.text),
    );
    await repo.appendMessages(sessionId, [newUser.toDto()]);

    // Historik (user-flag + text)
    final history = state.messages
        .map<(bool, String)>((m) => (m.role == ChatRole.user, m.text))
        .toList(growable: false);

    try {
      String? webNotes;
      if (settings.webLookupEnabled) {
        webNotes = await _fetchWebNotes(userText);
      }

      final fullText = await client.completeChat(
        history,
        userText,
        expertise: state.expertise,
        brand: state.brand,
        model: state.model,
        year: state.year,
        webNotes: webNotes,
      );

      var assistant = Message(role: ChatRole.assistant, text: '');
      msgs = [...msgs, assistant];
      state = state.copyWith(messages: msgs, hasSafetyRisk: false);

      // Simulerad "streaming"
      const stepMs = 12;
      for (int i = 0; i < fullText.length; i++) {
        final chunk = fullText.substring(0, i + 1);
        assistant = assistant.copyWith(text: chunk);
        msgs[msgs.length - 1] = assistant;
        state = state.copyWith(
          messages: [...msgs],
          hasSafetyRisk: _safetyRegex.hasMatch(chunk),
        );
        await Future.delayed(const Duration(milliseconds: stepMs));
      }

      await repo.appendMessages(sessionId, [assistant.toDto()]);

      // Döp titel efter första riktiga svaret (frivilligt)
      if (msgs.length <= 3) {
        final firstLine = assistant.text.split('\n').first.trim();
        if (firstLine.isNotEmpty) {
          final title = firstLine.length > 40
              ? '${firstLine.substring(0, 40)}…'
              : firstLine;
          await repo.renameSessionAuto(sessionId, title);
        }
      }
    } catch (e, st) {
      // Visa fel som assistent-meddelande så användaren ser vad som hände.
      debugPrint('Chat error: $e\n$st');
      final errText = e.toString();
      final assistant = Message(
        role: ChatRole.assistant,
        text: 'Fel vid kontakt med modellen:\n$errText',
      );
      msgs = [...msgs, assistant];
      state = state.copyWith(messages: msgs, hasSafetyRisk: false);
      await repo.appendMessages(sessionId, [assistant.toDto()]);
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  String? _buildEquipmentTitle() {
    final brand = state.brand?.trim() ?? '';
    final model = state.model?.trim() ?? '';
    final year = state.year?.trim() ?? '';
    final core = [brand, model].where((e) => e.isNotEmpty).join(' ');
    if (core.isEmpty && year.isEmpty) return null;
    if (year.isEmpty) return core;
    if (core.isEmpty) return year;
    return '$core ($year)';
  }

  Future<void> _maybeRenameFromEquipment() async {
    final title = _buildEquipmentTitle();
    if (title == null) return;
    await repo.renameSessionAuto(sessionId, title);
  }
}
