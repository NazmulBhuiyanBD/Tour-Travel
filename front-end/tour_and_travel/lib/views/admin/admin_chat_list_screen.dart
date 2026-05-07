import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../core/constant/app_colors.dart';
import '../../routes/app_routes.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    chatController.fetchUserChatList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1F36), size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Support Inbox",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage customer inquiries and support.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF697386),
                ),
              ),
              const SizedBox(height: 24),

              // Chat Thread List
              Expanded(
                child: Obx(() {
                  if (chatController.isLoadingHistory.value && chatController.userChatThreads.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)));
                  }
                  
                  if (chatController.userChatThreads.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00ACC1).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.forum_rounded, size: 64, color: Color(0xFF00ACC1)),
                          ),
                          const SizedBox(height: 16),
                          const Text("No messages yet", style: TextStyle(color: Color(0xFF697386))),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF3F51B5),
                    onRefresh: () => chatController.fetchUserChatList(),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: chatController.userChatThreads.length,
                      itemBuilder: (context, index) {
                        final thread = chatController.userChatThreads[index];
                        return _ChatThreadCard(thread: thread);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatThreadCard extends StatelessWidget {
  final ChatUserThread thread;

  const _ChatThreadCard({required this.thread});

  String _timeAgo(DateTime? timestamp) {
    if (timestamp == null) return '';
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Get.toNamed(Routes.ADMIN_CHAT, arguments: {
            'userId': thread.userId,
            'userName': thread.userName,
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              thread.userName.isNotEmpty ? thread.userName[0].toUpperCase() : '?',
              style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
        title: Text(
          thread.userName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1F36)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            thread.latestMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: thread.isSystemMessage ? const Color(0xFF3F51B5) : const Color(0xFF697386),
              fontSize: 13,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _timeAgo(thread.timestamp),
              style: const TextStyle(color: Color(0xFF697386), fontSize: 11),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Reply',
                style: TextStyle(color: Color(0xFF3F51B5), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
