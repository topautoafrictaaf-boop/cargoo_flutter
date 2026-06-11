class ChatMessage {
  final String id;
  final String text;
  final String sender; // 'user' ou 'bot'
  final DateTime timestamp;
  final String? imageBase64;
  final String? imageMimeType;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.imageBase64,
    this.imageMimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'imageBase64': imageBase64,
      'imageMimeType': imageMimeType,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: json['sender'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageBase64: json['imageBase64'] as String?,
      imageMimeType: json['imageMimeType'] as String?,
    );
  }
}
