import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/view_models/support_view_model.dart';
import 'package:tour_and_travel/core/constant/app_colors.dart';
import 'package:tour_and_travel/data/services/storage_service.dart';
import 'create_ticket_view.dart';
import 'ticket_chat_view.dart';

class UserTicketListView extends StatefulWidget {
  const UserTicketListView({Key? key}) : super(key: key);

  @override
  State<UserTicketListView> createState() => _UserTicketListViewState();
}

class _UserTicketListViewState extends State<UserTicketListView> {
  final SupportViewModel supportViewModel = Get.put(SupportViewModel());

  @override
  void initState() {
    super.initState();
    final user = StorageService.to.getUser();
    print("UserTicketListView: current user ID = ${user?.userId}, role = ${user?.role}");
    if (user != null && user.userId != null && user.userId!.isNotEmpty) {
      try {
        supportViewModel.fetchMyTickets(int.parse(user.userId!));
      } catch (e) {
        print("Error parsing userId: $e");
      }
    }
  }

  Future<void> _refreshTickets() async {
    final user = StorageService.to.getUser();
    if (user != null && user.userId != null) {
      await supportViewModel.fetchMyTickets(int.parse(user.userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Premium background
      appBar: AppBar(
        title: const Text(
          'My Support Tickets',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      // ➕ Create Ticket Button (Premium Gradient)
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3F51B5).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            Get.to(() => const CreateTicketView())?.then((_) {
              _refreshTickets();
            });
          },
        ),
      ),
      body: Obx(() {
        // 🔄 Loading
        if (supportViewModel.isLoading.value &&
            supportViewModel.myTickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (supportViewModel.myTickets.isEmpty &&
            !supportViewModel.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent_rounded, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'You have no support tickets.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshTickets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refreshTickets,
          child: ListView.builder(
            itemCount: supportViewModel.myTickets.length,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final ticket = supportViewModel.myTickets[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
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
                        Get.to(() => TicketChatView(
                              ticketId: ticket.id,
                              subject: ticket.subject,
                            ))?.then((_) {
                          _refreshTickets();
                        });
                      },

                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF3F51B5).withOpacity(0.15),
                                        const Color(0xFF3F51B5).withOpacity(0.05)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.confirmation_number_outlined,
                                    color: Color(0xFF3F51B5),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Text(
                                    ticket.subject,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF1A1F36),
                                    ),
                                  ),
                                ),
                                if (ticket.hasUnread)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 🔹 Bottom Row
                            Row(
                              children: [
                                // 📌 Status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ticket.isClosed
                                        ? Colors.grey.shade100
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ticket.isClosed ? 'Closed' : 'Active',
                                    style: TextStyle(
                                      color: ticket.isClosed
                                          ? Colors.grey.shade600
                                          : Colors.green.shade700,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                // ⏱ Updated Time
                                Icon(Icons.access_time_rounded,
                                    size: 14, color: Colors.grey[400]),
                                const SizedBox(width: 6),
                                Text(
                                  'Updated: ${ticket.updatedAt.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7FC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.chevron_right_rounded,
                                      size: 16, color: Color(0xFF8F9BB3)),
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