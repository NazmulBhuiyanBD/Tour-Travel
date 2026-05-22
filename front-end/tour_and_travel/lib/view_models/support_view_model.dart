import 'package:get/get.dart';
import 'package:tour_and_travel/data/repositories/support_repository.dart';
import 'package:tour_and_travel/models/support_ticket.dart';
import 'package:tour_and_travel/models/chat_message.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';
import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'dart:io';

class SupportViewModel extends GetxController {
  final SupportRepository _supportRepository = SupportRepository();
  final NetworkApiService _networkApiService = NetworkApiService();

  var isLoading = false.obs;
  var isSending = false.obs;
  
  var myTickets = <SupportTicket>[].obs;
  var allAdminTickets = <SupportTicket>[].obs;
  
  var currentTicket = Rxn<SupportTicket>();
  var currentMessages = <ChatMessage>[].obs;

  // Fetch tickets for current user
  Future<void> fetchMyTickets(int userId) async {
    try {
      isLoading.value = true;
      print("Fetching tickets for user: $userId");
      final response = await _supportRepository.getUserTickets(userId);
      print("User tickets response: $response");
      if (response != null && response is List) {
        myTickets.value = response.map((e) => SupportTicket.fromJson(e)).toList();
        print("Loaded ${myTickets.length} tickets");
      }
    } catch (e) {
      print("Error fetching my tickets: $e");
      Get.snackbar('Error', 'Failed to fetch tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all tickets for admin
  Future<void> fetchAllTickets() async {
    try {
      isLoading.value = true;
      final response = await _supportRepository.getAllTickets();
      if (response != null && response is List) {
        allAdminTickets.value = response.map((e) => SupportTicket.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch all tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch single ticket details
  Future<void> fetchTicketDetails(int ticketId) async {
    try {
      isLoading.value = true;
      final response = await _supportRepository.getTicketDetails(ticketId);
      print("Ticket Details Response: $response");
      if (response != null) {
        currentTicket.value = SupportTicket.fromJson(response);
        currentMessages.value = currentTicket.value!.messages;
        print("Loaded ${currentMessages.length} messages");
      }
    } catch (e) {
      print("Error fetching ticket details: $e");
      Get.snackbar('Error', 'Failed to fetch ticket details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new ticket
  Future<bool> createTicket(String subject, String initialMessage, {File? image}) async {
    try {
      isLoading.value = true;
      String? imageUrl;
      
      if (image != null) {
        imageUrl = await uploadImage(image);
      }

      final data = {
        'subject': subject,
        'initialMessage': initialMessage,
        'imageUrl': imageUrl
      };

      final response = await _supportRepository.createTicket(data);
      if (response != null) {
        Get.snackbar('Success', 'Ticket created successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create ticket: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Send a message to a ticket
  Future<void> sendMessage(int ticketId, String message, {File? image}) async {
    try {
      isSending.value = true;
      String? imageUrl;
      
      if (image != null) {
        imageUrl = await uploadImage(image);
      }

      final data = {
        'message': message,
        'imageUrl': imageUrl
      };

      final response = await _supportRepository.sendMessage(ticketId, data);
      if (response != null) {
        final newMessage = ChatMessage.fromJson(response);
        currentMessages.add(newMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isSending.value = false;
    }
  }

  // Close a ticket (Admin)
  Future<bool> closeTicket(int ticketId) async {
    try {
      isLoading.value = true;
      await _supportRepository.closeTicket(ticketId);
      Get.snackbar('Success', 'Ticket closed');
      
      // Update local state
      if (currentTicket.value != null && currentTicket.value!.id == ticketId) {
        currentTicket.value = SupportTicket(
          id: currentTicket.value!.id,
          subject: currentTicket.value!.subject,
          isClosed: true,
          createdAt: currentTicket.value!.createdAt,
          updatedAt: currentTicket.value!.updatedAt,
          messages: currentTicket.value!.messages,
          hasUnread: currentTicket.value!.hasUnread,
          userName: currentTicket.value!.userName,
          userEmail: currentTicket.value!.userEmail
        );
      }
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to close ticket: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Upload an image and get URL
  Future<String?> uploadImage(File image) async {
    try {
      final response = await _networkApiService.getMultipartApiResponse(
        ApiConstants.baseUrl + ApiConstants.supportUpload, 
        image.path
      );
      if (response != null && response['path'] != null) {
        return response['path'];
      }
      return null;
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }
}
