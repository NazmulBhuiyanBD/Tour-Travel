import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/core/utils/positive_number_input_formatter.dart';
import '../../view_models/admin_management_view_model.dart';

class AdminRoomManageScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;

  const AdminRoomManageScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
  });

  @override
  State<AdminRoomManageScreen> createState() => _AdminRoomManageScreenState();
}

class _AdminRoomManageScreenState extends State<AdminRoomManageScreen> {
  final controller = Get.find<AdminManagementViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchHotelRooms(widget.hotelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5),
        onPressed: () => _showRoomForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
                  Expanded(
                    child: Text(
                      widget.hotelName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F36),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage room categories, prices, and facilities.",
                style: TextStyle(fontSize: 14, color: Color(0xFF697386)),
              ),
              const SizedBox(height: 24),

              // Rooms List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3F51B5),
                      ),
                    );
                  }

                  if (controller.hotelRooms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF3F51B5,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.meeting_room_rounded,
                              size: 64,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No rooms configured for this hotel",
                            style: TextStyle(
                              color: Color(0xFF697386),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showRoomForm(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Configure Room"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.hotelRooms.length,
                    itemBuilder: (context, index) {
                      final room = controller.hotelRooms[index];
                      final acLabel = room['isAc'] == false ? 'Non AC' : 'AC';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0F1F4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.meeting_room_outlined,
                                color: Color(0xFF43A047),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room['type'] ?? 'Room Type',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1A1F36),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${room['bedType'] ?? 'King Bed'} • ${room['viewType'] ?? 'City View'} • $acLabel",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF697386),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "৳${room['price']} per night • ${room['availableRooms']} Rooms Total",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3F51B5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _showRoomForm(context, room: room),
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Color(0xFF3F51B5),
                                size: 22,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Delete Room Category',
                                  middleText:
                                      'Are you sure you want to delete this room category?',
                                  textConfirm: 'Delete',
                                  textCancel: 'Cancel',
                                  confirmTextColor: Colors.white,
                                  buttonColor: const Color(0xFFE53935),
                                  onConfirm: () {
                                    controller.deleteHotelRoom(
                                      widget.hotelId,
                                      room['id'],
                                    );
                                    Get.back();
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFE53935),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomForm(BuildContext context, {dynamic room}) {
    final isEdit = room != null;
    final priceController = TextEditingController(
      text: isEdit ? (room['price']?.toString() ?? '') : '',
    );
    final qtyController = TextEditingController(
      text: isEdit ? (room['availableRooms']?.toString() ?? '') : '10',
    );

    String selectedType = isEdit
        ? (room['type'] ?? 'Standard Room')
        : 'Standard Room';
    String selectedBed = isEdit ? (room['bedType'] ?? 'King Bed') : 'King Bed';
    String selectedView = isEdit
        ? (room['viewType'] ?? 'City View')
        : 'City View';
    bool isAc = isEdit ? (room['isAc'] ?? true) : true;

    final roomTypes = ['Standard Room', 'Deluxe Room', 'Suite Room'];
    if (!roomTypes.contains(selectedType)) roomTypes.add(selectedType);

    final bedTypes = ['King Bed', 'Queen Bed', 'Twin Bed', 'Sofa Bed'];
    if (!bedTypes.contains(selectedBed)) bedTypes.add(selectedBed);

    final viewTypes = ['City View', 'Sea View', 'Garden View', 'Pool View'];
    if (!viewTypes.contains(selectedView)) viewTypes.add(selectedView);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Room Category' : 'Add Room Category',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Category / Room Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category_rounded),
                        ),
                        items: roomTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setModalState(() => selectedType = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedBed,
                        decoration: InputDecoration(
                          labelText: 'Bed Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.bed_rounded),
                        ),
                        items: bedTypes
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setModalState(() => selectedBed = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedView,
                        decoration: InputDecoration(
                          labelText: 'View Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.landscape_rounded),
                        ),
                        items: viewTypes
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setModalState(() => selectedView = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text(
                          "AC Configured",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                        subtitle: Text(
                          isAc ? "Air Conditioned Room" : "Non AC Room",
                        ),
                        value: isAc,
                        onChanged: (val) => setModalState(() => isAc = val),
                        activeThumbColor: const Color(0xFF43A047),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [PositiveDecimalInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Price Per Night (৳)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                inputFormatters: [PositiveIntegerInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Total Rooms Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.numbers_rounded),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceController.text) ?? 0.0;
                  final availableRooms = int.tryParse(qtyController.text) ?? 0;

                  if (price <= 0 || availableRooms <= 0) {
                    Get.snackbar(
                      'Invalid Input',
                      'Price and room quantity must be greater than zero.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withValues(alpha: 0.85),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  final data = {
                    'type': selectedType,
                    'bedType': selectedBed,
                    'viewType': selectedView,
                    'isAc': isAc,
                    'price': price,
                    'availableRooms': availableRooms,
                  };

                  if (isEdit) {
                    controller.updateHotelRoom(
                      widget.hotelId,
                      room['id'],
                      data,
                    );
                  } else {
                    controller.addHotelRoom(widget.hotelId, data);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEdit ? 'Update Room Configuration' : 'Save Room Category',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
