import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/view_models/support_view_model.dart';
import 'package:tour_and_travel/core/constant/app_colors.dart';
import 'ticket_chat_view.dart';

class AdminTicketListView extends StatefulWidget {
  const AdminTicketListView({Key? key}) : super(key: key);

  @override
  State<AdminTicketListView> createState() => _AdminTicketListViewState();
}

class _AdminTicketListViewState extends State<AdminTicketListView> {
  final SupportViewModel supportViewModel = Get.put(SupportViewModel());
  
  @override
  void initState() {
    super.initState();
    supportViewModel.fetchAllTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Premium background
      appBar: AppBar(
        title: const Text(
          'Support Tickets (Admin)',
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

        if (supportViewModel.allAdminTickets.isEmpty && !supportViewModel.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent_rounded, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'No support tickets available.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => supportViewModel.fetchAllTickets(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Refresh'),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => supportViewModel.fetchAllTickets(),
          child: ListView.builder(
            itemCount: supportViewModel.allAdminTickets.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final ticket = supportViewModel.allAdminTickets[index];
              final hasUnread = ticket.hasUnread;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: hasUnread ? const Color(0xFFFFF5F5) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasUnread ? Colors.redAccent.withOpacity(0.2) : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: hasUnread 
                          ? Colors.redAccent.withOpacity(0.02)
                          : Colors.black.withOpacity(0.02),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.to(() => TicketChatView(ticketId: ticket.id, subject: ticket.subject))?.then((_) {
                          supportViewModel.fetchAllTickets();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (hasUnread)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    ticket.subject,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: hasUnread ? Colors.red.shade900 : const Color(0xFF1A1F36),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'From: ${ticket.userName ?? "Unknown"} (${ticket.userEmail ?? ""})',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ticket.isClosed ? Colors.grey.shade100 : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ticket.isClosed ? 'Closed' : 'Open',
                                    style: TextStyle(
                                      color: ticket.isClosed ? Colors.grey.shade600 : Colors.green.shade700,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                                const SizedBox(width: 6),
                                Text(
                                  'Updated: ${ticket.updatedAt.toLocal().toString().split('.')[0]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
