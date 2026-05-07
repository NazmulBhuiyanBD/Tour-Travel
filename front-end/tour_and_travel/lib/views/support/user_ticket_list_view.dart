import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/controllers/support_controller.dart';
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
  final SupportController supportController = Get.put(SupportController());

  @override
  void initState() {
    super.initState();
    final user = StorageService.to.getUser();
    print("UserTicketListView: current user ID = ${user?.userId}, role = ${user?.role}");
    if (user != null && user.userId != null && user.userId!.isNotEmpty) {
      try {
        supportController.fetchMyTickets(int.parse(user.userId!));
      } catch (e) {
        print("Error parsing userId: $e");
      }
    }
  }

  Future<void> _refreshTickets() async {
    final user = StorageService.to.getUser();
    if (user != null && user.userId != null) {
      await supportController.fetchMyTickets(int.parse(user.userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Support Tickets'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),

      // ➕ Create Ticket Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Ticket', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Get.to(() => const CreateTicketView())?.then((_) {
            _refreshTickets();
          });
        },
      ),
      body: Obx(() {
        // 🔄 Loading
        if (supportController.isLoading.value &&
            supportController.myTickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (supportController.myTickets.isEmpty &&
            !supportController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have no support tickets.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshTickets,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refreshTickets,
          child: ListView.builder(
            itemCount: supportController.myTickets.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final ticket = supportController.myTickets[index];

              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),

                    // 👉 Open Chat
                    onTap: () {
                      Get.to(() => TicketChatView(
                            ticketId: ticket.id,
                            subject: ticket.subject,
                          ))?.then((_) {
                        _refreshTickets();
                      });
                    },

                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.confirmation_number_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  ticket.subject,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (ticket.hasUnread)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
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
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ticket.isClosed
                                      ? Colors.grey[200]
                                      : AppColors.cardGreen
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  ticket.isClosed ? 'Closed' : 'Active',
                                  style: TextStyle(
                                    color: ticket.isClosed
                                        ? Colors.grey[600]
                                        : AppColors.cardGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // ⏱ Updated Time
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                'Updated: ${ticket.updatedAt.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 4),

                              const Icon(Icons.chevron_right,
                                  size: 18, color: Colors.grey),
                            ],
                          ),
                        ],
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