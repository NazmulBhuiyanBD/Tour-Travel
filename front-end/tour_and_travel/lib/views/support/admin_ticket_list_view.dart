import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/controllers/support_controller.dart';
import 'package:tour_and_travel/core/constant/app_colors.dart';
import 'ticket_chat_view.dart';

class AdminTicketListView extends StatefulWidget {
  const AdminTicketListView({Key? key}) : super(key: key);

  @override
  State<AdminTicketListView> createState() => _AdminTicketListViewState();
}

class _AdminTicketListViewState extends State<AdminTicketListView> {
  final SupportController supportController = Get.put(SupportController());
  
  @override
  void initState() {
    super.initState();
    supportController.fetchAllTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets (Admin)'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (supportController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (supportController.allAdminTickets.isEmpty && !supportController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No support tickets available.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => supportController.fetchAllTickets(),
                  child: const Text('Refresh'),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => supportController.fetchAllTickets(),
          child: ListView.builder(
            itemCount: supportController.allAdminTickets.length,
            itemBuilder: (context, index) {
              final ticket = supportController.allAdminTickets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: ticket.hasUnread ? 4 : 1,
                color: ticket.hasUnread ? Colors.red[50] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: ticket.hasUnread 
                      ? const BorderSide(color: Colors.redAccent, width: 1)
                      : BorderSide.none
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      if (ticket.hasUnread)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          ticket.subject,
                          style: TextStyle(
                            fontWeight: ticket.hasUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From: ${ticket.userName ?? "Unknown"} (${ticket.userEmail ?? ""})'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ticket.isClosed ? Colors.grey[300] : AppColors.cardGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ticket.isClosed ? 'Closed' : 'Open',
                                style: TextStyle(
                                  color: ticket.isClosed ? Colors.grey[800] : AppColors.cardGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Updated: ${ticket.updatedAt.toLocal().toString().split('.')[0]}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Get.to(() => TicketChatView(ticketId: ticket.id, subject: ticket.subject))?.then((_) {
                      // Refresh when coming back
                      supportController.fetchAllTickets();
                    });
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
