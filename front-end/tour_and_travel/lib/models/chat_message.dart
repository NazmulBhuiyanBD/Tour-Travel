class ChatMessage {
  final int id;
  final int? ticketId;
  final int senderId;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isAdminMessage;
  final int? adminId;
  final String? adminName;
  final bool isRead;

  ChatMessage({
    required this.id,
    this.ticketId,
    required this.senderId,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    required this.isAdminMessage,
    this.adminId,
    this.adminName,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      ticketId: json['ticketId'],
      senderId: json['senderId'] ?? 0,
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      isAdminMessage: json['isAdminMessage'] ?? false,
      adminId: json['adminId'],
      adminName: json['adminName'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'senderId': senderId,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isAdminMessage': isAdminMessage,
      'adminId': adminId,
      'adminName': adminName,
      'isRead': isRead,
    };
  }
}
