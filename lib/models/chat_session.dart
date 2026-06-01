import 'chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime lastInteraction;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.lastInteraction,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lastInteraction': lastInteraction.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'] ?? 'New Clinical Case...',
      lastInteraction: DateTime.parse(json['lastInteraction']),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }

  ChatSession copyWith({
    String? title,
    DateTime? lastInteraction,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      messages: messages ?? this.messages,
    );
  }
}
