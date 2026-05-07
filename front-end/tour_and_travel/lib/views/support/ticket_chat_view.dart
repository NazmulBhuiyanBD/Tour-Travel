import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tour_and_travel/controllers/support_controller.dart';
import 'package:tour_and_travel/core/constant/app_colors.dart';
import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/services/storage_service.dart';

class TicketChatView extends StatefulWidget {
  final int ticketId;
  final String subject;

  const TicketChatView({Key? key, required this.ticketId, required this.subject}) : super(key: key);

  @override
  State<TicketChatView> createState() => _TicketChatViewState();
}

class _TicketChatViewState extends State<TicketChatView> {
  final SupportController supportController = Get.find<SupportController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      supportController.fetchTicketDetails(widget.ticketId);
      
      // Auto scroll when messages change
      supportController.currentMessages.listen((_) {
        Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
      });
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImage == null) {
      return;
    }

    final message = _messageController.text;
    final image = _selectedImage;
    
    _messageController.clear();
    setState(() {
      _selectedImage = null;
    });

    await supportController.sendMessage(widget.ticketId, message, image: image);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = StorageService.to.getUser();
    final currentUserId = currentUser?.userId != null ? int.parse(currentUser!.userId!) : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            final ticket = supportController.currentTicket.value;
            final userRole = StorageService.to.getUser()?.role;
            if (ticket != null && !ticket.isClosed && (userRole == 'Admin' || userRole == 'SuperAdmin')) {
              return IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Close Ticket',
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Close Ticket?',
                    middleText: 'Are you sure you want to mark this problem as solved?',
                    textConfirm: 'Yes',
                    textCancel: 'No',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      supportController.closeTicket(widget.ticketId);
                      Get.back(); // close dialog
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          // Close ticket banner if closed
          Obx(() {
            final ticket = supportController.currentTicket.value;
            if (ticket != null && ticket.isClosed) {
              return Container(
                width: double.infinity,
                color: Colors.grey[300],
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'This ticket has been marked as closed/solved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          Expanded(
            child: Obx(() {
              if (supportController.isLoading.value && supportController.currentMessages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (supportController.currentMessages.isEmpty && !supportController.isLoading.value) {
                return const Center(child: Text('No messages yet.'));
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: supportController.currentMessages.length,
                itemBuilder: (context, index) {
                  final msg = supportController.currentMessages[index];
                  
                  // Determine if the message should be on the right (sent by the current viewer side)
                  final currentUser = StorageService.to.getUser();
                  final isAdminViewer = currentUser?.role == 'Admin' || currentUser?.role == 'SuperAdmin';
                  
                  // If I'm an admin, messages sent by any admin are on my "side" (right)
                  // If I'm a user, messages sent by me (not admin messages) are on my "side" (right)
                  final isMe = isAdminViewer ? msg.isAdminMessage : !msg.isAdminMessage;
                  
                  return _buildMessageBubble(msg, isMe);
                },
              );
            }),
          ),
          
          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Image.file(_selectedImage!, height: 80, width: 80, fit: BoxFit.cover),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _selectedImage = null),
                  )
                ],
              ),
            ),
            
          Obx(() {
            final ticket = supportController.currentTicket.value;
            if (ticket != null && ticket.isClosed) {
              return const SizedBox.shrink();
            }
            
            return _buildMessageInput();
          }),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && msg.isAdminMessage && msg.adminName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Admin: ${msg.adminName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                ),
              ),
              
            if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Image.network(
                  ApiConstants.mediaBaseUrl + msg.imageUrl!,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
              
            if (msg.message.isNotEmpty)
              Text(
                msg.message,
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
              
            const SizedBox(height: 4),
            Text(
              '${msg.timestamp.toLocal().hour}:${msg.timestamp.toLocal().minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: AppColors.primaryBlue),
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
            ),
          ),
          Obx(() {
            if (supportController.isSending.value) {
              return const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
              );
            }
            return IconButton(
              icon: const Icon(Icons.send, color: AppColors.primaryBlue),
              onPressed: _sendMessage,
            );
          }),
        ],
      ),
    );
  }
}
