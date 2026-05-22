import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../data/services/storage_service.dart';
import '../core/constant/api_constants.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime timestamp;
  final bool isAdminMessage;

  ChatMessage({
    this.id = 0,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.isAdminMessage,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      senderId: json['senderId'] ?? 0,
      receiverId: json['receiverId'] ?? 0,
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isAdminMessage: json['isAdminMessage'] ?? false,
    );
  }
}

class ChatUserThread {
  final int userId;
  final String userName;
  final String userEmail;
  final String? profileImage;
  final String latestMessage;
  final DateTime? timestamp;
  final bool isSystemMessage;

  ChatUserThread({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.profileImage,
    required this.latestMessage,
    this.timestamp,
    required this.isSystemMessage,
  });

  factory ChatUserThread.fromJson(Map<String, dynamic> json) {
    return ChatUserThread(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'User',
      userEmail: json['userEmail'] ?? '',
      profileImage: json['profileImage'],
      latestMessage: json['latestMessage'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
      isSystemMessage: json['isSystemMessage'] ?? false,
    );
  }
}

class ChatViewModel extends GetxController {
  late HubConnection _hubConnection;
  var isConnected = false.obs;
  var messages = <ChatMessage>[].obs;
  var userChatThreads = <ChatUserThread>[].obs;
  var isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSignalR();
  }

  void _initSignalR() async {
    final token = StorageService.to.getToken() ?? '';

    // Choose appropriate localhost depending on emulator or web
    String serverUrl = "http://10.0.2.2:5198/chathub";
    if (kIsWeb) {
      serverUrl = "http://localhost:5198/chathub";
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          serverUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .build();

    _hubConnection.onclose(({error}) {
      isConnected.value = false;
      print("Connection closed");
    });

    _hubConnection.on("ReceiveMessage", _handleReceiveMessage);

    try {
      await _hubConnection.start();
      isConnected.value = true;
      print("Connected to User Support ChatHub");
    } catch (e) {
      print("Error connecting to ChatHub: $e");
    }
  }

  void _handleReceiveMessage(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      final msg = ChatMessage.fromJson(data);
      messages.add(msg);
    }
  }

  void sendMessageToAdmin(String message) async {
    if (isConnected.value && message.isNotEmpty) {
      try {
        await _hubConnection.invoke("SendMessageToAdmin", args: [message]);
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  void sendMessageToUser(int userId, String message) async {
    if (isConnected.value && message.isNotEmpty) {
      try {
        await _hubConnection.invoke("SendMessageToUser", args: [userId, message]);
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  /// Fetch chat history for a specific user
  Future<void> fetchChatHistory(int userId) async {
    try {
      isLoadingHistory.value = true;
      final token = StorageService.to.getToken() ?? '';
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Chat/history/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        messages.value = data.map((e) => ChatMessage.fromJson(e)).toList();
      } else {
        print("Failed to fetch history: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chat history: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// Fetch list of users who have chatted (Admin only)
  Future<void> fetchUserChatList() async {
    try {
      isLoadingHistory.value = true;
      final token = StorageService.to.getToken() ?? '';
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Chat/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        userChatThreads.value =
            data.map((e) => ChatUserThread.fromJson(e)).toList();
      } else {
        print("Failed to fetch chat users: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chat user list: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  @override
  void onClose() {
    _hubConnection.stop();
    super.onClose();
  }
}
