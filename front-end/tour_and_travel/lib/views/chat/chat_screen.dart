import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/chat_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../core/constant/app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatViewModel chatViewModel = Get.put(ChatViewModel());
    final AuthViewModel authViewModel = Get.find<AuthViewModel>();
    final TextEditingController textController = TextEditingController();

    bool isAdmin = authViewModel.user.value.role == 'Admin';

    // Get the target user id from arguments if passed (admin replying to a specific user)
    final args = Get.arguments;
    int? targetUserId = args != null ? args['userId'] : null;
    String? targetUserName = args != null ? args['userName'] : null;

    // Fetch history
    if (isAdmin && targetUserId != null) {
      chatViewModel.fetchChatHistory(targetUserId);
    } else if (!isAdmin) {
      // Fetch current user's own history
      final currentUserId = authViewModel.user.value.userId;
      if (currentUserId != null) {
        chatViewModel.fetchChatHistory(int.tryParse(currentUserId) ?? 0);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? (targetUserName ?? 'User Chat') : 'Help & Support',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
                  chatViewModel.isConnected.value
                      ? '● Online'
                      : '○ Connecting...',
                  style: TextStyle(
                    color: chatViewModel.isConnected.value
                        ? Colors.green
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: const Icon(Icons.support_agent, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() {
              if (chatViewModel.isLoadingHistory.value &&
                  chatViewModel.messages.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBlue));
              }
              if (chatViewModel.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        isAdmin
                            ? 'No messages from this user yet'
                            : 'How can we help you?\nSend us a message!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: chatViewModel.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatViewModel.messages[index];
                  bool isMe = (isAdmin && msg.isAdminMessage) ||
                      (!isAdmin && !msg.isAdminMessage);

                  return _MessageBubble(
                    message: msg.message,
                    isMe: isMe,
                    timestamp: msg.timestamp,
                    isAdmin: msg.isAdminMessage,
                  );
                },
              );
            }),
          ),
          // Input bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.headerGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          if (isAdmin && targetUserId != null) {
                            chatViewModel.sendMessageToUser(
                                targetUserId, textController.text.trim());
                          } else {
                            chatViewModel.sendMessageToAdmin(
                                textController.text.trim());
                          }
                          textController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final bool isAdmin;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)])
              : null,
          color: isMe ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  isAdmin ? '🛡️ Support Agent' : 'You',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? AppColors.primaryBlue : Colors.grey,
                  ),
                ),
              ),
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
