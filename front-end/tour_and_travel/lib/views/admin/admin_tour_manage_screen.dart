import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/core/constant/api_constants.dart';
import '../../controllers/admin_management_controller.dart';
import '../../core/constant/app_colors.dart';

class AdminTourManageScreen extends StatelessWidget {
  const AdminTourManageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminManagementController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5),
        onPressed: () => _showTourForm(context, controller),
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1F36), size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Tours",
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
                "Local experiences and adventures.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF697386),
                ),
              ),
              const SizedBox(height: 24),

              // Tour List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)));
                  }
                  
                  if (controller.tours.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flag_rounded, size: 64, color: Color(0xFFE53935)),
                          ),
                          const SizedBox(height: 16),
                          const Text("No tour packages found", style: TextStyle(color: Color(0xFF697386))),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.tours.length,
                    itemBuilder: (context, index) {
                      final tour = controller.tours[index];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12),
                                image: tour['imageUrl'] != null && tour['imageUrl'].toString().isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage("${ApiConstants.mediaBaseUrl}${tour['imageUrl']}"),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: tour['imageUrl'] == null || tour['imageUrl'].toString().isEmpty
                                  ? const Icon(Icons.tour_rounded, color: Color(0xFFE53935), size: 28)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tour['title'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1A1F36),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${tour['durationDays']} Days • \$${tour['price']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF697386),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showTourForm(context, controller, tour: tour),
                                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF3F51B5), size: 22),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: 'Delete Tour',
                                      middleText: 'Remove this tour package?',
                                      textConfirm: 'Delete',
                                      textCancel: 'Cancel',
                                      confirmTextColor: Colors.white,
                                      buttonColor: const Color(0xFFE53935),
                                      onConfirm: () {
                                        controller.deleteTour(tour['id']);
                                        Get.back();
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935), size: 22),
                                ),
                              ],
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

  void _showTourForm(BuildContext context, AdminManagementController controller, {dynamic tour}) {
    final isEdit = tour != null;
    final titleController = TextEditingController(text: isEdit ? (tour['title'] ?? '') : '');
    final descController = TextEditingController(text: isEdit ? (tour['description'] ?? '') : '');
    final durController = TextEditingController(text: isEdit ? (tour['durationDays'].toString()) : '');
    final priceController = TextEditingController(text: isEdit ? (tour['price'].toString()) : '');
    bool isTop = isEdit ? (tour['isTopDestination'] ?? false) : false;
    
    // Reset or set initial image path
    controller.selectedTourImagePath.value = isEdit ? (tour['imageUrl'] ?? '') : '';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                isEdit ? 'Edit Tour' : 'Create Tour Package',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
              ),
              const SizedBox(height: 24),
              _buildField(titleController, 'Tour Title', Icons.title_rounded),
              const SizedBox(height: 16),
              _buildField(descController, 'Description', Icons.description_rounded, maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _buildField(durController, 'Duration (Days)', Icons.timer_rounded, isNum: true)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildField(priceController, 'Price (\$)', Icons.attach_money_rounded, isNum: true)),
                ],
              ),
              const SizedBox(height: 16),
              
              const Text('Tour Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1F36))),
              const SizedBox(height: 12),
              Obx(() => GestureDetector(
                onTap: () => controller.pickAndUploadTourImage(),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    image: controller.selectedTourImagePath.value.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage("${ApiConstants.mediaBaseUrl}${controller.selectedTourImagePath.value}"),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.selectedTourImagePath.value.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, color: Colors.grey[400], size: 40),
                            const SizedBox(height: 8),
                            Text('Add Tour Image', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          ],
                        )
                      : controller.isUploading.value 
                        ? const Center(child: CircularProgressIndicator())
                        : Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                ),
              )),
              const SizedBox(height: 16),

              StatefulBuilder(
                builder: (context, setModalState) {
                  return SwitchListTile(
                    title: const Text("Top Destination", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1F36))),
                    subtitle: const Text("Highlight this as a premium destination"),
                    value: isTop,
                    onChanged: (val) => setModalState(() => isTop = val),
                    activeColor: const Color(0xFF3F51B5),
                    contentPadding: EdgeInsets.zero,
                  );
                }
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final data = {
                    'title': titleController.text,
                    'description': descController.text,
                    'durationDays': int.parse(durController.text),
                    'price': double.parse(priceController.text),
                    'itinerary': tour?['itinerary'] ?? "Day 1: Arrival, Day 2: Sightseeing, Day 3: Departure",
                    'isTopDestination': isTop,
                    'imageUrl': controller.selectedTourImagePath.value,
                  };
                  if (isEdit) {
                    controller.updateTour(tour['id'], data);
                  } else {
                    controller.addTour(data);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(isEdit ? 'Update Tour' : 'Save Tour'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNum = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
