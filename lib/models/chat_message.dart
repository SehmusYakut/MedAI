class ChatMessage {
  final String sender; // 'user' or the AI service name (e.g., 'Gemini')
  final String text;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.sender,
    required this.text,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        sender: json['sender'],
        text: json['text'],
        timestamp: DateTime.parse(json['timestamp']),
        isError: json['isError'] ?? false,
      );
}
