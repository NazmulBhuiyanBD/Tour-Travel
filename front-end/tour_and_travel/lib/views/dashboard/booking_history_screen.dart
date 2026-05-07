import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../common_widgets/payment_gateway_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
  final BookingController _bookingController = Get.put(BookingController());

  BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Journeys',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (_bookingController.isLoading.value &&
            _bookingController.bookingHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_bookingController.bookingHistory.isEmpty) {
          return const Center(
            child: Text(
              "You have no booking history.",
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _bookingController.bookingHistory.length,
          itemBuilder: (context, index) {
            var item = _bookingController.bookingHistory[index];
            bool requiresPayment =
                item['status'] == 'Pending' ||
                item['status'] == 'Confirmed'; // Mock logic

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: CircleAvatar(
                  backgroundColor: _getAvatarColor(item['type']),
                  child: Icon(_getIcon(item['type']), color: Colors.white),
                ),
                title: Text(
                  item['detailTitle'] ?? 'Detail',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text('Type: ${item['type']}'),
                    Text('Status: ${item['status']} - \$${item['totalPrice']}'),
                    Text('Date: ${item['bookingDate']?.substring(0, 10)}'),
                  ],
                ),
                trailing: requiresPayment
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => Get.to(
                          () => PaymentGatewayScreen(
                            amount: item['totalPrice'] ?? 0,
                          ),
                        ),
                        child: const Text(
                          "Pay Now",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : const Chip(
                        label: Text("Paid"),
                        backgroundColor: Colors.tealAccent,
                      ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _getAvatarColor(String? type) {
    switch (type) {
      case 'Flight':
        return Colors.indigo;
      case 'Hotel':
        return Colors.teal;
      case 'Tour':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'Flight':
        return Icons.flight;
      case 'Hotel':
        return Icons.hotel;
      case 'Tour':
        return Icons.tour;

      default:
        return Icons.airplane_ticket;
    }
  }
}
