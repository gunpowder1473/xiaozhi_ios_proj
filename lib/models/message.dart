enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isImage;
  final String? imageLocalPath;
  final String? fileId;

  Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isImage = false,
    this.imageLocalPath,
    this.fileId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      role: MessageRole.values.byName(json['role']),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      isImage: json['isImage'] ?? false,
      imageLocalPath: json['imageLocalPath'],
      fileId: json['fileId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isImage': isImage,
      'imageLocalPath': imageLocalPath,
      'fileId': fileId,
    };
  }
}
