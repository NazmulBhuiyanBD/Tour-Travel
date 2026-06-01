import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/routes/app_routes.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../core/utils/pdf_invoice_api.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final Map<String, dynamic> bookingDetails = (args is Map<String, dynamic>) 
        ? args 
        : {'type': (args as String?) ?? 'Booking'};
        
    final String bookingType = bookingDetails['type'] ?? 'Stay';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon with Ring
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 4),
                ),
                child: const Icon(
                  Icons.check,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Payment Successful",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Thank you for booking your $bookingType with us.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              
              // Illustration placeholder or image
              // Note: Using a placeholder that looks like the provided image
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.card_travel,
                  size: 100,
                  color: Colors.blueAccent,
                ),
              ),
              
              const Spacer(),
              const SizedBox(height: 15),

              // Download PDF Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final pdfBytes = await PdfInvoiceApi.generateInvoice(bookingDetails);
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: 'Invoice_${bookingType}_${DateTime.now().millisecondsSinceEpoch}.pdf',
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
              const SizedBox(height: 15),
              
              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Get.offAllNamed('/dashboard'); // Assuming dashboard is the home
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
