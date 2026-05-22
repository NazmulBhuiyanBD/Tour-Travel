import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../core/utils/pdf_invoice_api.dart';
import '../common_widgets/review_bottom_sheet.dart';
import '../common_widgets/refund_bottom_sheet.dart';
import '../../core/constant/app_colors.dart';
import '../../view_models/booking_view_model.dart';

class HotelBookingDetailsScreen extends StatelessWidget {
  final dynamic booking;

  const HotelBookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final bookingViewModel = Get.find<BookingViewModel>();
    final bookingId = booking['referenceId'] ?? booking['id'] ?? 0;
    final String bookingType = booking['type'] ?? 'Hotel';

    return Obx(() {
      final dynamic booking = bookingViewModel.bookingHistory.firstWhere(
        (b) => (b['referenceId'] ?? b['id'] ?? 0) == bookingId && (b['type'] ?? 'Hotel').toString().toLowerCase() == bookingType.toLowerCase(),
        orElse: () => this.booking,
      );

      final String status = booking['status'] ?? 'Confirmed';
      final bool isConfirmed = status.toLowerCase() == 'confirmed';
      final String hotelName = booking['detailTitle'] ?? booking['hotelName'] ?? 'Hotel';
      final String checkIn = booking['checkInDate'] ?? booking['bookingDate']?.toString().substring(0, 10) ?? 'N/A';
      final String checkOut = booking['checkOutDate'] ?? 'N/A';
      
      final bool canReview = booking['canReview'] == true;
      final bool canRefund = booking['canRefund'] == true && isConfirmed;

      return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Hotel Booking Details",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order ID
                        Text(
                          "Booking ID: ${booking['referenceNumber'] ?? booking['id']?.toString() ?? 'HTL_0000'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Booking Date and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Booked:",
                                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking['bookingDate']?.toString().replaceAll('T', ' ').substring(0, 16) ?? "N/A",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isConfirmed ? const Color(0xFF27AE60) : const Color(0xFFF2994A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Hotel Name and Price Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FB),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hotelName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        Icon(Icons.star_half, color: Colors.amber.shade200, size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$${booking['totalPrice'] ?? '0.00'}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Text(
                                    "Total Fare",
                                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 20),

                        // Stay Duration Section
                        const Text(
                          "STAY DETAILS",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Check-In / Check-Out Visual
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "CHECK-IN",
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  checkIn.length > 10 ? checkIn.substring(0, 10) : checkIn,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Row(
                                      children: List.generate(20, (index) {
                                        return Expanded(
                                          child: Container(
                                            height: 1.5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            color: index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent,
                                          ),
                                        );
                                      }),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.hotel, color: Colors.teal, size: 24),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "CHECK-OUT",
                                  style: TextStyle(
                                    color: Color(0xFFF2994A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  checkOut.length > 10 ? checkOut.substring(0, 10) : checkOut,
                                  style: const TextStyle(
                                    color: Color(0xFFF2994A),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 25),

                        // Timeline
                        _buildTimelineItem(
                          title: checkIn.length > 10 ? checkIn.substring(0, 10) : checkIn,
                          subtitle: "Check-In at the hotel reception",
                          icon: Icons.login,
                        ),
                        _buildTimelineItem(
                          title: "Enjoy your stay",
                          subtitle: "",
                          isStep: true,
                          icon: Icons.king_bed,
                        ),
                        _buildTimelineItem(
                          title: checkOut.length > 10 ? checkOut.substring(0, 10) : checkOut,
                          subtitle: "Check-Out from hotel",
                          isLast: true,
                          icon: Icons.logout,
                        ),

                        const SizedBox(height: 25),
                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 20),

                        // Booking Details Table
                        const Text(
                          "Booking Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow("Hotel Name", hotelName),
                        _buildDetailRow("Payment Method", booking['paymentMethod'] ?? booking['PaymentMethod'] ?? "N/A"),
                        _buildDetailRow("Transaction ID", booking['transactionId'] ?? booking['TransactionId'] ?? "N/A"),
                        _buildDetailRow("Guest", booking['userName'] ?? "Guest"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Download PDF Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  booking['type'] = 'Hotel';
                  final pdfBytes = await PdfInvoiceApi.generateInvoice(booking);
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'Invoice_Hotel_${DateTime.now().millisecondsSinceEpoch}.pdf',
                  );
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  "Download Invoice PDF",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Review Button
            if (canReview) ...[
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ReviewBottomSheet(
                        itemType: "Hotel",
                        itemId: booking['hotelId'] ?? booking['itemId'] ?? 0,
                      ),
                    );
                  },
                  icon: const Icon(Icons.rate_review, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  label: const Text(
                    "Write a Review",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Refund Button
            if (canRefund) ...[
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => RefundBottomSheet(
                        itemType: "Hotel",
                        bookingId: booking['referenceId'] ?? booking['id'] ?? 0,
                      ),
                    );
                  },
                  icon: const Icon(Icons.money_off, color: Colors.red),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  label: const Text(
                    "Request Refund",
                    style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
    });
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    bool isLast = false,
    bool isStep = false,
    IconData? icon,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isStep ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: isStep ? Colors.black87 : Colors.teal,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 25),
                    child: Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (isStep) const SizedBox(height: 25),
                if (isLast) const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
