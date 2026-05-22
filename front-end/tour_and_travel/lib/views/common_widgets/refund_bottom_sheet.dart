import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/refund_view_model.dart';
import '../../core/constant/app_colors.dart';
import '../../view_models/booking_view_model.dart';

class RefundBottomSheet extends StatefulWidget {
  final String itemType;
  final int bookingId;

  const RefundBottomSheet({
    super.key,
    required this.itemType,
    required this.bookingId,
  });

  @override
  State<RefundBottomSheet> createState() => _RefundBottomSheetState();
}

class _RefundBottomSheetState extends State<RefundBottomSheet> {
  final TextEditingController _reasonController = TextEditingController();
  final RefundViewModel _refundViewModel = Get.put(RefundViewModel());

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitRefundRequest() async {
    if (_reasonController.text.trim().isEmpty) {
      Get.snackbar(
        "Required",
        "Please provide a reason for the refund.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    bool success = await _refundViewModel.createRefundRequest(
      widget.itemType,
      widget.bookingId,
      _reasonController.text.trim(),
    );

    if (success) {
      try {
        final bookingViewModel = Get.find<BookingViewModel>();
        await bookingViewModel.fetchBookingHistory();
      } catch (e) {
        // Ignored
      }
      Get.back(); // Close bottom sheet on success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Request a Refund",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Please tell us why you are requesting a refund:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your reason here...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _refundViewModel.isLoading.value ? null : _submitRefundRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _refundViewModel.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Refund Request",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
