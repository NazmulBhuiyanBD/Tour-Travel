import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tour_and_travel/view_models/support_view_model.dart';
import 'package:tour_and_travel/core/constant/app_colors.dart';
import 'package:tour_and_travel/data/services/storage_service.dart';

class CreateTicketView extends StatefulWidget {
  const CreateTicketView({Key? key}) : super(key: key);

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final SupportViewModel supportViewModel = Get.find<SupportViewModel>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _submitTicket() async {
    if (subjectController.text.isEmpty || messageController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a subject and message');
      return;
    }

    final success = await supportViewModel.createTicket(
      subjectController.text,
      messageController.text,
      image: _selectedImage,
    );

    if (success) {
      Get.defaultDialog(
        title: 'Ticket Submitted',
        middleText: 'Your support ticket has been created successfully.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // close dialog
          Get.back(); // go back to list
        },
      );
      
      final user = StorageService.to.getUser();
      if (user != null && user.userId != null) {
        supportViewModel.fetchMyTickets(int.parse(user.userId!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Premium background
      appBar: AppBar(
        title: const Text(
          'Create Support Ticket',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (supportViewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Describe Your Issue",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Please provide a subject and details about your issue. You can also attach an image to help us understand better.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF697386),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Subject Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: TextField(
                  controller: subjectController,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    floatingLabelStyle: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Message Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: TextField(
                  controller: messageController,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  decoration: InputDecoration(
                    labelText: 'Describe your issue',
                    labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    floatingLabelStyle: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          _selectedImage!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              // Attach Image Button
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined, size: 20),
                label: const Text('Attach Image', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3F51B5),
                  side: BorderSide(color: const Color(0xFF3F51B5).withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3F51B5).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Submit Ticket',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
