import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/refund_view_model.dart';


class AdminRefundManageScreen extends StatefulWidget {
  const AdminRefundManageScreen({super.key});

  @override
  State<AdminRefundManageScreen> createState() => _AdminRefundManageScreenState();
}

class _AdminRefundManageScreenState extends State<AdminRefundManageScreen> with SingleTickerProviderStateMixin {
  final RefundViewModel _viewModel = Get.put(RefundViewModel());
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  String _searchQuery = "";
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Redraw list when switching tabs
    });
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchAllRefundRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredRequests(List<dynamic> requests) {
    // 1. Filter by Tab Status
    String targetStatus = "";
    switch (_tabController.index) {
      case 1:
        targetStatus = "Pending";
        break;
      case 2:
        targetStatus = "Approved";
        break;
      case 3:
        targetStatus = "Rejected";
        break;
    }

    Iterable<dynamic> filtered = requests;
    if (targetStatus.isNotEmpty) {
      filtered = filtered.where((r) => (r['status'] ?? '').toString().toLowerCase() == targetStatus.toLowerCase());
    }

    // 2. Filter by Search Query (User Name, Item Type, Reason, Booking ID)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final userName = (r['userName'] ?? '').toString().toLowerCase();
        final itemType = (r['itemType'] ?? '').toString().toLowerCase();
        final reason = (r['reason'] ?? '').toString().toLowerCase();
        final bookingId = (r['bookingId'] ?? '').toString();
        return userName.contains(_searchQuery) ||
            itemType.contains(_searchQuery) ||
            reason.contains(_searchQuery) ||
            bookingId.contains(_searchQuery);
      });
    }

    return filtered.toList();
  }

  void _showProcessRefundSheet(BuildContext context, dynamic request) {
    double bookingPrice = (request['bookingPrice'] ?? 0).toDouble();
    if (bookingPrice <= 0) {
      // Fallback in case of existing empty records
      bookingPrice = 1000.0;
    }

    double currentPercentage = 100.0;
    final feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double calculatedRefund = bookingPrice * (currentPercentage / 100.0);

            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F51B5).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.price_check_rounded,
                            color: Color(0xFF3F51B5),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          "Process Refund",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Request summary card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8E9F3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Requester:",
                                style: TextStyle(color: Color(0xFF697386), fontSize: 13),
                              ),
                              Text(
                                request['userName'] ?? "User",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1F36),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Booking Reference:",
                                style: TextStyle(color: Color(0xFF697386), fontSize: 13),
                              ),
                              Text(
                                "${request['itemType']} Booking #${request['bookingId']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1F36),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Original Amount Paid:",
                                style: TextStyle(color: Color(0xFF697386), fontSize: 13),
                              ),
                              Text(
                                "৳${bookingPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1F36),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Refund Slider Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Refund Percentage",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F51B5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${currentPercentage.toInt()}%",
                            style: const TextStyle(
                              color: Color(0xFF3F51B5),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF3F51B5),
                        inactiveTrackColor: const Color(0xFFE8E9F3),
                        thumbColor: const Color(0xFF3F51B5),
                        overlayColor: const Color(0xFF3F51B5).withOpacity(0.15),
                        valueIndicatorColor: const Color(0xFF3F51B5),
                        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: currentPercentage,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: "${currentPercentage.toInt()}%",
                        onChanged: (double val) {
                          setModalState(() {
                            currentPercentage = val;
                          });
                        },
                      ),
                    ),

                    // Preset buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [100, 90, 80, 50, 0].map((percentage) {
                        bool isSelected = currentPercentage.toInt() == percentage;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFF3F51B5) : const Color(0xFFE8E9F3),
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: isSelected ? const Color(0xFF3F51B5).withOpacity(0.05) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  currentPercentage = percentage.toDouble();
                                });
                              },
                              child: Text(
                                "$percentage%",
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF3F51B5) : const Color(0xFF4F566B),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Price Breakdown Summary Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Money Back Amount:",
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "৳${calculatedRefund.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Admin Notes / Feedback",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Add feedback for user (e.g. approved 80% refund due to late cancellation)",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE8E9F3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3F51B5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Color(0xFF697386),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final success = await _viewModel.updateRefundStatus(
                                request['id'],
                                "Rejected",
                                0,
                                feedbackController.text.trim(),
                              );
                              if (success) {
                                Get.back();
                              }
                            },
                            child: const Text(
                              "Reject",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final success = await _viewModel.updateRefundStatus(
                                request['id'],
                                "Approved",
                                currentPercentage.toInt(),
                                feedbackController.text.trim(),
                              );
                              if (success) {
                                Get.back();
                              }
                            },
                            child: const Text(
                              "Approve",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemTypeBadge(String? itemType) {
    IconData icon;
    Color color;
    String label = itemType ?? "Item";

    if (label.toLowerCase() == 'flight') {
      icon = Icons.flight_rounded;
      color = const Color(0xFFF9A825);
    } else if (label.toLowerCase() == 'hotel') {
      icon = Icons.hotel_rounded;
      color = const Color(0xFF43A047);
    } else {
      icon = Icons.map_rounded;
      color = const Color(0xFFE53935);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    if (status.toLowerCase() == 'approved') {
      color = const Color(0xFF43A047);
      icon = Icons.check_circle_outline_rounded;
    } else if (status.toLowerCase() == 'rejected') {
      color = const Color(0xFFE53935);
      icon = Icons.cancel_outlined;
    } else {
      color = const Color(0xFFFFB300);
      icon = Icons.timelapse_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Top Bar
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
                    "Refund Console",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Review user refund requests and process payouts.",
                style: TextStyle(fontSize: 14, color: Color(0xFF697386)),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF697386)),
                    hintText: "Search by user name, reference, or reason...",
                    hintStyle: TextStyle(color: Color(0xFF8792A2), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Custom tab bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8E9F3)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF3F51B5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF4F566B),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  tabs: const [
                    Tab(text: "All"),
                    Tab(text: "Pending"),
                    Tab(text: "Approved"),
                    Tab(text: "Rejected"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Refunds list
              Expanded(
                child: Obx(() {
                  if (_viewModel.isLoading.value && _viewModel.allRefunds.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF3F51B5)),
                    );
                  }

                  final filteredList = _getFilteredRequests(_viewModel.allRefunds);

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.currency_exchange_rounded,
                            size: 72,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No refund requests found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Requests will show up here once submitted.",
                            style: TextStyle(color: Color(0xFF697386), fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _viewModel.fetchAllRefundRequests(),
                    color: const Color(0xFF3F51B5),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final String status = item['status'] ?? "Pending";
                        final bool isPending = status.toLowerCase() == "pending";
                        
                        double originalPrice = (item['bookingPrice'] ?? 0).toDouble();
                        double refundAmount = (item['refundAmount'] ?? 0).toDouble();
                        int refundPercentage = (item['refundPercentage'] ?? 100).toInt();
                        String? adminFeedback = item['adminFeedback'];
                        String? requestedDateString = item['requestedAt'];
                        
                        String formattedDate = "";
                        if (requestedDateString != null) {
                          try {
                            DateTime dt = DateTime.parse(requestedDateString).toLocal();
                            formattedDate = "${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                          } catch (e) {
                            formattedDate = requestedDateString.split('T')[0];
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isPending 
                                  ? const Color(0xFFFFB300).withOpacity(0.2) 
                                  : const Color(0xFFE8E9F3),
                              width: isPending ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top details: Requester, badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: const Color(0xFF3F51B5).withOpacity(0.1),
                                        child: Text(
                                          (item['userName'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF3F51B5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['userName'] ?? "User",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF1A1F36),
                                            ),
                                          ),
                                          if (formattedDate.isNotEmpty)
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  _buildStatusBadge(status),
                                ],
                              ),
                              const Divider(height: 24, color: Color(0xFFE8E9F3)),

                              // Booking Details & Price
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "BOOKING REFERENCE",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF8792A2),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _buildItemTypeBadge(item['itemType']),
                                          const SizedBox(width: 8),
                                          Text(
                                            "#${item['bookingId']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF4F566B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "ORIGINAL PRICE",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF8792A2),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "৳${originalPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Color(0xFF1A1F36),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Refund details for non-pending
                              if (!isPending && status.toLowerCase() == 'approved') ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50).withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.15)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Refunded Payout ($refundPercentage%):",
                                        style: const TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        "৳${refundAmount.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Reason Section
                              const Text(
                                "REFUND REASON",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF8792A2),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['reason'] ?? "No reason specified.",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4F566B),
                                  height: 1.4,
                                ),
                              ),

                              // Admin feedback section
                              if (adminFeedback != null && adminFeedback.trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  "ADMIN REMARKS",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF8792A2),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  adminFeedback,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade600,
                                    height: 1.3,
                                  ),
                                ),
                              ],

                              // Payout action button for pending
                              if (isPending) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3F51B5),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _showProcessRefundSheet(context, item),
                                    child: const Text(
                                      "Process Request",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
