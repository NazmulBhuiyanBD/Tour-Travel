import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tour_and_travel/controllers/support_controller.dart';
import 'package:tour_and_travel/core/constant/app_colors.dart';
import 'package:tour_and_travel/data/services/storage_service.dart';

class CreateTicketView extends StatefulWidget {
  const CreateTicketView({Key? key}) : super(key: key);

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final SupportController supportController = Get.find<SupportController>();
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

    final success = await supportController.createTicket(
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
        supportController.fetchMyTickets(int.parse(user.userId!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Support Ticket'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (supportController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Describe your issue',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_selectedImage != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    )
                  ],
                ),
                
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Attach Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _submitTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit Ticket', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
