import 'package:tour_and_travel/models/chat_message.dart';

class SupportTicket {
  final int id;
  final String subject;
  final bool isClosed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userEmail;
  final bool hasUnread;
  final List<ChatMessage> messages;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.isClosed,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userEmail,
    this.hasUnread = false,
    this.messages = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    List<ChatMessage> msgList = [];
    if (json['messages'] != null) {
      msgList = (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList();
    }

    return SupportTicket(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      isClosed: json['isClosed'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      userName: json['userName'],
      userEmail: json['userEmail'],
      hasUnread: json['hasUnread'] ?? false,
      messages: msgList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'isClosed': isClosed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userName': userName,
      'userEmail': userEmail,
      'hasUnread': hasUnread,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
