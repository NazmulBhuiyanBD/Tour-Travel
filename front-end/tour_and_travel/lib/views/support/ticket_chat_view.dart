import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/core/constant/app_colors.dart';
import 'package:tour_and_travel/data/services/storage_service.dart';
import 'package:tour_and_travel/view_models/support_view_model.dart';

class TicketChatView extends StatefulWidget {
  final int ticketId;
  final String subject;

  const TicketChatView({
    Key? key,
    required this.ticketId,
    required this.subject,
  }) : super(key: key);

  @override
  State<TicketChatView> createState() => _TicketChatViewState();
}

class _TicketChatViewState extends State<TicketChatView> {
  final SupportViewModel supportViewModel =
      Get.find<SupportViewModel>();

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      supportViewModel.fetchTicketDetails(
        widget.ticketId,
      );

      supportViewModel.currentMessages.listen((_) {
        Future.delayed(
          const Duration(milliseconds: 100),
          _scrollToBottom,
        );
      });
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _selectedImage =
            File(image.path);
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text
            .trim()
            .isEmpty &&
        _selectedImage == null) {
      return;
    }

    final message =
        _messageController.text;

    final image =
        _selectedImage;

    _messageController.clear();

    setState(() {
      _selectedImage = null;
    });

    await supportViewModel
        .sendMessage(
      widget.ticketId,
      message,
      image: image,
    );

    _scrollToBottom();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Obx(() {
            final ticket =
                supportViewModel
                    .currentTicket
                    .value;

            final userRole =
                StorageService.to
                    .getUser()
                    ?.role;

            if (ticket != null &&
                !ticket.isClosed &&
                (userRole ==
                        'Admin' ||
                    userRole ==
                        'SuperAdmin')) {
              return IconButton(
                icon: const Icon(
                  Icons
                      .check_circle_outline,
                ),
                onPressed: () {
                  Get.defaultDialog(
                    title:
                        'Close Ticket?',
                    middleText:
                        'Are you sure?',
                    textConfirm:
                        'Yes',
                    textCancel:
                        'No',
                    confirmTextColor:
                        Colors.white,
                    onConfirm:
                        () {
                      supportViewModel
                          .closeTicket(
                        widget
                            .ticketId,
                      );

                      Get.back();
                    },
                  );
                },
              );
            }

            return const SizedBox();
          }),
        ],
      ),

      backgroundColor:
          const Color(
        0xFFF4F7FC,
      ),

      body: Container(
        child: Column(
          children: [

            Obx(() {
              final ticket =
                  supportViewModel
                      .currentTicket
                      .value;

              if (ticket != null &&
                  ticket
                      .isClosed) {
                return Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .all(
                    12,
                  ),
                  color:
                      Colors.grey,
                  child:
                      const Center(
                    child: Text(
                      'Ticket Closed',
                      style:
                          TextStyle(
                        color: Colors
                            .white,
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox();
            }),

            Expanded(
              child: Obx(() {

                if (supportViewModel
                        .isLoading
                        .value &&
                    supportViewModel
                        .currentMessages
                        .isEmpty) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (supportViewModel
                        .currentMessages
                        .isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.',
                    ),
                  );
                }

                return ListView.builder(
                  controller:
                      _scrollController,
                  padding:
                      const EdgeInsets
                          .all(
                    16,
                  ),
                  itemCount:
                      supportViewModel
                          .currentMessages
                          .length,
                  itemBuilder:
                      (context,
                          index) {

                    final msg =
                        supportViewModel
                            .currentMessages[index];

                    final currentUser =
                        StorageService
                            .to
                            .getUser();

                    final isAdminViewer =
                        currentUser
                                    ?.role ==
                                'Admin' ||
                            currentUser
                                    ?.role ==
                                'SuperAdmin';

                    final isMe =
                        isAdminViewer
                            ? msg
                                .isAdminMessage
                            : !msg
                                .isAdminMessage;

                    return _buildMessageBubble(
                      msg,
                      isMe,
                    );
                  },
                );
              }),
            ),

            if (_selectedImage !=
                null)
              Container(
                padding:
                    const EdgeInsets
                        .all(
                  8,
                ),
                child: Row(
                  children: [
                    Image.file(
                      _selectedImage!,
                      width: 80,
                      height: 80,
                    ),
                    IconButton(
                      onPressed:
                          () {
                        setState(() {
                          _selectedImage =
                              null;
                        });
                      },
                      icon:
                          const Icon(
                        Icons.close,
                      ),
                    ),
                  ],
                ),
              ),

            Obx(() {
              final ticket =
                  supportViewModel
                      .currentTicket
                      .value;

              if (ticket != null &&
                  ticket
                      .isClosed) {
                return const SizedBox();
              }

              return _buildMessageInput();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    dynamic msg,
    bool isMe,
  ) {
    return Align(
      alignment: isMe
          ? Alignment
              .centerRight
          : Alignment
              .centerLeft,
      child: Container(
        margin:
            const EdgeInsets
                .only(
          bottom: 12,
        ),
        padding:
            const EdgeInsets
                .all(
          12,
        ),
        decoration:
            BoxDecoration(
          color: isMe
              ? Colors.blue
              : Colors.white,
          borderRadius:
              BorderRadius
                  .circular(
            12,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [

            if (msg.imageUrl !=
                    null &&
                msg.imageUrl
                    .isNotEmpty)
              Image.network(
                ApiConstants
                        .mediaBaseUrl +
                    msg.imageUrl,
              ),

            if (msg.message
                .isNotEmpty)
              Text(
                msg.message,
                style:
                    TextStyle(
                  color: isMe
                      ? Colors
                          .white
                      : Colors
                          .black,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget
      _buildMessageInput() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          padding:
              const EdgeInsets
                  .all(
            12,
          ),
          child: Row(
            children: [

              IconButton(
                onPressed:
                    _pickImage,
                icon:
                    const Icon(
                  Icons.image,
                ),
              ),

              Expanded(
                child:
                    TextField(
                  controller:
                      _messageController,
                  minLines: 1,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(
                    hintText:
                        'Type a message...',
                  ),
                ),
              ),

              IconButton(
                onPressed:
                    _sendMessage,
                icon:
                    const Icon(
                  Icons.send,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}