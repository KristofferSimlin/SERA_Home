import 'dart:convert';

class ChatSessionMeta {
  final String id;
  final String title;
  final DateTime updatedAt;

  ChatSessionMeta({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  ChatSessionMeta copyWith({String? title, DateTime? updatedAt}) =>
      ChatSessionMeta(
        id: id,
        title: title ?? this.title,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static ChatSessionMeta fromJson(Map<String, dynamic> j) => ChatSessionMeta(
        id: j['id'] as String,
        title: j['title'] as String? ?? 'Ny chatt',
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class ChatMessageDTO {
  final String role; // "user" | "assistant"
  final String text;
  final DateTime time;

  ChatMessageDTO({required this.role, required this.text, required this.time});

  Map<String, dynamic> toJson() =>
      {'role': role, 'text': text, 'time': time.toIso8601String()};

  static ChatMessageDTO fromJson(Map<String, dynamic> j) => ChatMessageDTO(
        role: j['role'] as String,
        text: j['text'] as String? ?? '',
        time: DateTime.tryParse(j['time'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Små helpers för (de)serialisering
String encodeList<T>(List<T> list, Object Function(T) toJson) =>
    jsonEncode(list.map((e) => toJson(e)).toList());

List<R> decodeList<R>(
  String source,
  R Function(Map<String, dynamic>) fromJson,
) {
  final arr = (jsonDecode(source) as List).cast<dynamic>();
  return arr.map((e) => fromJson((e as Map).cast())).toList();
}
