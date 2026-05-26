import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../view_models/admin_management_view_model.dart';
import '../../core/utils/pdf_report_api.dart';
import 'package:printing/printing.dart';

class AdminRevenueReportScreen extends StatefulWidget {
  const AdminRevenueReportScreen({Key? key}) : super(key: key);

  @override
  State<AdminRevenueReportScreen> createState() =>
      _AdminRevenueReportScreenState();
}

class _AdminRevenueReportScreenState extends State<AdminRevenueReportScreen> {
  final AdminManagementViewModel controller =
      Get.find<AdminManagementViewModel>();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
    _fetchReport();
  }

  void _fetchReport() {
    if (_startDate != null && _endDate != null) {
      final startStr = DateFormat('yyyy-MM-dd').format(_startDate!);
      final endStr = DateFormat('yyyy-MM-dd').format(_endDate!);
      controller.fetchRevenueReport(startStr, endStr);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3F51B5), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchReport();
    }
  }

  Future<void> _generatePdf() async {
    final data = controller.revenueReportData;
    if (data.isEmpty || _startDate == null || _endDate == null) return;

    final pdfBytes = await PdfReportApi.generateRevenueReport(
      data,
      _startDate!,
      _endDate!,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'Revenue_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(() {
                if (controller.isReportLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = controller.revenueReportData;
                if (data.isEmpty) {
                  return const Center(child: Text("No report data available."));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(data),
                      const SizedBox(height: 32),
                      const Text(
                        "Daily Breakdown",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDailyChart(data['dailyData']),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generatePdf,
        backgroundColor: const Color(0xFF3F51B5),
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text(
          "Download PDF",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final formatter = DateFormat('MMM dd, yyyy');
    final dateRangeStr = _startDate != null && _endDate != null
        ? '${formatter.format(_startDate!)} - ${formatter.format(_endDate!)}'
        : 'Select Date Range';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1A1F36),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const Text(
                "Revenue Report",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDateRange(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD3D8E1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.date_range,
                    color: Color(0xFF3F51B5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateRangeStr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F566B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Gross Revenue",
                value: "৳${data['grossRevenue'] ?? 0}",
                icon: Icons.account_balance_wallet,
                color: const Color(0xFF3F51B5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: "Total Refunds",
                value: "৳${data['totalRefunds'] ?? 0}",
                icon: Icons.currency_exchange,
                color: const Color(0xFFE53935),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Net Revenue",
                value: "৳${data['netRevenue'] ?? 0}",
                icon: Icons.trending_up,
                color: const Color(0xFF43A047),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: "Total Bookings",
                value: "${data['totalBookings'] ?? 0}",
                icon: Icons.receipt_long,
                color: const Color(0xFFF9A825),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyChart(Map<String, dynamic>? dailyData) {
    if (dailyData == null || dailyData.isEmpty) {
      return const Text("No daily data available.");
    }

    final dates = dailyData.keys.toList()..sort();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final d = dailyData[date];

        DateTime parsedDate = DateTime.parse(date);
        String formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF0F1F4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${d['bookingsCount']} Bookings",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF697386),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "+৳${d['grossRevenue']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF43A047),
                    ),
                  ),
                  if (d['refunds'] > 0)
                    Text(
                      "-৳${d['refunds']}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE53935),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF697386),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F36),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
