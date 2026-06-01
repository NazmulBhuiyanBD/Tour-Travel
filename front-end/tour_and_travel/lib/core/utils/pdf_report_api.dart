import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfReportApi {
  static String _money(dynamic value) => 'BDT ${value ?? 0}';

  static Future<Uint8List> generateRevenueReport(
    Map<String, dynamic> reportData,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    final formatter = DateFormat('MMM dd, yyyy');
    final String dateRange =
        '${formatter.format(startDate)} - ${formatter.format(endDate)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(dateRange),
            pw.SizedBox(height: 30),
            _buildSummary(reportData),
            pw.SizedBox(height: 30),
            _buildDailyTableTitle(),
            pw.SizedBox(height: 10),
            _buildDailyTable(reportData['dailyData'] ?? {}),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String dateRange) {
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
        pw.Text(
          'Revenue Report',
          style: pw.TextStyle(fontSize: 18, color: PdfColors.blueGrey),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Report Period: $dateRange'),
        pw.Text(
          'Generated On: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(Map<String, dynamic> reportData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem('Total Bookings', '${reportData['totalBookings'] ?? 0}'),
          _summaryItem('Gross Revenue', _money(reportData['grossRevenue'])),
          _summaryItem('Total Refunds', _money(reportData['totalRefunds'])),
          _summaryItem(
            'Net Revenue',
            _money(reportData['netRevenue']),
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(
    String title,
    String value, {
    bool isHighlight = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: isHighlight ? PdfColors.green800 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDailyTableTitle() {
    return pw.Text(
      'Daily Breakdown',
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey900,
      ),
    );
  }

  static pw.Widget _buildDailyTable(Map<String, dynamic> dailyData) {
    if (dailyData.isEmpty) {
      return pw.Text('No data available for this period.');
    }

    final headers = [
      'Date',
      'Bookings',
      'Gross (BDT)',
      'Refunds (BDT)',
      'Net (BDT)',
    ];

    // Sort dates
    final dates = dailyData.keys.toList()..sort();

    final data = dates.map((date) {
      final d = dailyData[date];
      return [
        date,
        '${d['bookingsCount']}',
        _money(d['grossRevenue']),
        _money(d['refunds']),
        _money(d['netRevenue']),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo400),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text(
          'Confidential - Tour & Travel Internal Document',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
