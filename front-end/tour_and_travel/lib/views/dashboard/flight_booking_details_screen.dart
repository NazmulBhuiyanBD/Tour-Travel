import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/view_models/booking_view_model.dart';
import '../../core/constant/app_colors.dart';
import 'package:printing/printing.dart';
import '../../core/utils/pdf_invoice_api.dart';
import '../common_widgets/review_bottom_sheet.dart';
import '../common_widgets/refund_bottom_sheet.dart';

class FlightBookingDetailsScreen extends StatelessWidget {
  final dynamic booking;

  const FlightBookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final bookingViewModel = Get.find<BookingViewModel>();
    final bookingId = booking['referenceId'] ?? booking['id'] ?? 0;
    final String bookingType = booking['type'] ?? 'Flight';

    return Obx(() {
      final dynamic booking = bookingViewModel.bookingHistory.firstWhere(
        (b) =>
            (b['referenceId'] ?? b['id'] ?? 0) == bookingId &&
            (b['type'] ?? 'Flight').toString().toLowerCase() ==
                bookingType.toLowerCase(),
        orElse: () => this.booking,
      );

      final String status = booking['status'] ?? 'Confirmed';
      final bool isConfirmed = status.toLowerCase() == 'confirmed';

      final String fromCity = booking['from'] ?? 'Islamabad';
      final String toCity = booking['to'] ?? 'Dubai';
      final String fromCode = fromCity.length >= 3
          ? fromCity.substring(0, 3).toUpperCase()
          : fromCity.toUpperCase();
      final String toCode = toCity.length >= 3
          ? toCity.substring(0, 3).toUpperCase()
          : toCity.toUpperCase();

      DateTime? departDateTime = booking['bookingDate'] != null
          ? DateTime.tryParse(booking['bookingDate'].toString())
          : null;
      DateTime? arriveDateTime = booking['arrivalTime'] != null
          ? DateTime.tryParse(booking['arrivalTime'].toString())
          : null;

      String durationStr = "N/A";
      if (departDateTime != null && arriveDateTime != null) {
        final diff = arriveDateTime.difference(departDateTime);
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        durationStr = "${hours}h:${minutes}m";
      }

      final bool canReview = booking['canReview'] == true;
      final bool canRefund = booking['canRefund'] == true && isConfirmed;

      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: const Text(
            "Flight Booking Details",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
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
                      color: Colors.black.withValues(alpha: 0.04),
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
                            "Order ID: ${booking['referenceNumber'] ?? (booking['id'] != null ? 'FLIGHT-${booking['id'].toString().padLeft(6, '0')}' : 'off_0000AzdG1Y2vwyd7eemLxt')}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 15),

                          // Booking Date and Status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Booked:",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDateTime(departDateTime),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isConfirmed
                                      ? const Color(0xFF27AE60)
                                      : const Color(0xFFF2994A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Airline and Price Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    booking['airline'] ?? "Emirates",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "৳${booking['totalPrice'] ?? '321.68'}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Text(
                                      "Total Fare",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          Divider(color: Colors.grey.shade100, thickness: 1.5),
                          const SizedBox(height: 20),

                          // Depart Section
                          const Text(
                            "DEPART",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Route
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                fromCode,
                                style: const TextStyle(
                                  color: Color(0xFF2F80ED),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Row(
                                        children: List.generate(20, (index) {
                                          return Expanded(
                                            child: Container(
                                              height: 1.5,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 1,
                                                  ),
                                              color: index % 2 == 0
                                                  ? Colors.grey.shade200
                                                  : Colors.transparent,
                                            ),
                                          );
                                        }),
                                      ),
                                      const Icon(
                                        Icons.flight,
                                        color: Color(0xFF2F80ED),
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                toCode,
                                style: const TextStyle(
                                  color: Color(0xFF2F80ED),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          Divider(color: Colors.grey.shade100, thickness: 1.5),
                          const SizedBox(height: 25),

                          // Timeline
                          _buildTimelineItem(
                            title: _formatDateTime(departDateTime),
                            subtitle: "Depart from $fromCity",
                          ),
                          _buildTimelineItem(
                            title: "Flight duration: $durationStr",
                            subtitle: "",
                            isStep: true,
                          ),
                          _buildTimelineItem(
                            title: _formatDateTime(arriveDateTime),
                            subtitle: "Arrive at $toCity",
                            isLast: true,
                          ),

                          const SizedBox(height: 25),
                          Divider(color: Colors.grey.shade100, thickness: 1.5),
                          const SizedBox(height: 20),

                          // Flight Details Table
                          const Text(
                            "Flight Details (Depart)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDetailRow(
                            "Cabin Class",
                            booking['cabinClass'] ?? "Economy",
                          ),
                          _buildDetailRow(
                            "Airline Name",
                            booking['airline'] ?? "Emirates",
                          ),
                          _buildDetailRow(
                            "Flight Number",
                            "FL-${booking['itemId']?.toString().padLeft(4, '0') ?? '0613'}",
                          ),
                          _buildDetailRow(
                            "Payment Method",
                            booking['paymentMethod'] ??
                                booking['PaymentMethod'] ??
                                "N/A",
                          ),
                          _buildDetailRow(
                            "Transaction ID",
                            booking['transactionId'] ??
                                booking['TransactionId'] ??
                                "N/A",
                          ),
                          _buildDetailRow(
                            "Traveler",
                            booking['userName'] ?? "Traveler",
                          ),
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
                    booking['type'] = 'Flight';
                    final pdfBytes = await PdfInvoiceApi.generateInvoice(
                      booking,
                    );
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename:
                          'Invoice_Flight_${DateTime.now().millisecondsSinceEpoch}.pdf',
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
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
                          itemType: "Flight",
                          itemId: booking['flightId'] ?? booking['itemId'] ?? 0,
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    label: const Text(
                      "Write a Review",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                          itemType: "Flight",
                          bookingId:
                              booking['referenceId'] ?? booking['id'] ?? 0,
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
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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
                  child: Container(width: 1.5, color: Colors.grey.shade200),
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
                    color: isStep ? Colors.black87 : const Color(0xFF2F80ED),
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 25),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? "PM" : "AM";
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "${weekDays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}, $hour:$minute $period";
  }
}
