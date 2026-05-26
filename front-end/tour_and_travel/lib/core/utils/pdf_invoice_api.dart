import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfInvoiceApi {
  static Future<Uint8List> generateInvoice(
    Map<String, dynamic> bookingDetails,
  ) async {
    final pdf = pw.Document();

    final String bookingType = bookingDetails['type'] ?? 'Booking';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildTitle(bookingType),
            pw.SizedBox(height: 30),
            _buildInvoiceDetails(bookingDetails),
            pw.SizedBox(height: 30),
            _buildBookingTable(bookingDetails),
            pw.SizedBox(height: 40),
            _buildTotalSection(bookingDetails),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TOUR & TRAVEL INC.',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.indigo,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text('Uttora sector-10, Dhaka -1230'),
        pw.Text('Email: support@tourtravel.com'),
        pw.Text('Phone: +1 800 123 4567'),
      ],
    );
  }

  static pw.Widget _buildTitle(String bookingType) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 32,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: pw.BoxDecoration(
            color: PdfColors.green100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Text(
            'PAID',
            style: pw.TextStyle(
              color: PdfColors.green800,
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceDetails(Map<String, dynamic> bookingDetails) {
    final now = DateTime.now();
    final formatter = DateFormat('MMM dd, yyyy');
    final String transactionId =
        bookingDetails['transactionId'] ??
        bookingDetails['TransactionId'] ??
        'INV-${now.millisecondsSinceEpoch.toString().substring(5)}';
    final String paymentMethod =
        bookingDetails['paymentMethod'] ??
        bookingDetails['PaymentMethod'] ??
        'Credit/Debit Card';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Billed To:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(bookingDetails['userName'] ?? 'Valued Customer'),
            pw.Text('customer@example.com'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Invoice No: $transactionId'),
            pw.Text('Payment Method: $paymentMethod'),
            pw.Text('Date: ${formatter.format(now)}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBookingTable(Map<String, dynamic> bookingDetails) {
    final String title =
        bookingDetails['title'] ?? '${bookingDetails['type']} Reservation';
    final String type = bookingDetails['type'] ?? 'Booking';
    final int quantity = bookingDetails['quantity'] ?? 1;
    final double totalPrice = bookingDetails['price'] ?? 0.0;
    final double unitPrice = quantity > 0 ? totalPrice / quantity : totalPrice;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                'Description',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                'Type',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                'Qty',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                'Unit Price',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                'Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        // Data row
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(title),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(type),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('$quantity'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('৳${unitPrice.toStringAsFixed(2)}'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                '৳${totalPrice.toStringAsFixed(2)}',
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTotalSection(Map<String, dynamic> bookingDetails) {
    final double totalPrice = bookingDetails['price'] ?? 0.0;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Subtotal:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('৳${totalPrice.toStringAsFixed(2)}'),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Paid:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    '৳${totalPrice.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                      color: PdfColors.indigo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text(
          'Thank you for booking with Tour & Travel!',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.indigo,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'If you have any questions about this invoice, please contact support.',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
