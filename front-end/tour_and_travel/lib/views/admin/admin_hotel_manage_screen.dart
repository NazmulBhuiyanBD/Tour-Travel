import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/core/constant/api_constants.dart';
import '../../view_models/admin_management_view_model.dart';
import '../../core/constant/app_colors.dart';

class AdminHotelManageScreen extends StatelessWidget {
  const AdminHotelManageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminManagementViewModel());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5),
        onPressed: () => _showHotelForm(context, controller),
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
                    "Hotels",
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
                "Manage and curate global destinations.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF697386),
                ),
              ),
              const SizedBox(height: 24),

              // Hotel List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)));
                  }
                  
                  if (controller.hotels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F51B5).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.hotel_rounded, size: 64, color: Color(0xFF3F51B5)),
                          ),
                          const SizedBox(height: 16),
                          const Text("No hotels found", style: TextStyle(color: Color(0xFF697386))),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showHotelForm(context, controller),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Add Hotel"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          )
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = controller.hotels[index];
                      
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
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: hotel['imageUrl'] != null && hotel['imageUrl'] != ""
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        "${ApiConstants.mediaBaseUrl}${hotel['imageUrl']}",
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.hotel_rounded, color: Color(0xFF3F51B5), size: 28),
                                      ),
                                    )
                                  : const Icon(Icons.hotel_rounded, color: Color(0xFF3F51B5), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1A1F36),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF697386)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          hotel['location'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF697386),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showHotelForm(context, controller, hotel: hotel),
                              icon: const Icon(Icons.edit_outlined, color: Color(0xFF3F51B5), size: 22),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Delete Hotel',
                                  middleText: 'Are you sure you want to delete this hotel?',
                                  textConfirm: 'Delete',
                                  textCancel: 'Cancel',
                                  confirmTextColor: Colors.white,
                                  buttonColor: const Color(0xFFE53935),
                                  onConfirm: () {
                                    controller.deleteHotel(hotel['id']);
                                    Get.back();
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935), size: 22),
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

  void _showHotelForm(BuildContext context, AdminManagementViewModel controller, {dynamic hotel}) {
    final isEdit = hotel != null;
    final nameController = TextEditingController(text: isEdit ? (hotel['name'] ?? '') : '');
    final locController = TextEditingController(text: isEdit ? (hotel['location'] ?? '') : '');
    final descController = TextEditingController(text: isEdit ? (hotel['description'] ?? '') : '');
    final priceController = TextEditingController(text: isEdit ? (hotel['pricePerNight']?.toString() ?? hotel['price']?.toString() ?? '') : '');
    final roomsController = TextEditingController(text: isEdit ? (hotel['availableRooms']?.toString() ?? '10') : '10');
    bool isFeatured = isEdit ? (hotel['isFeatured'] ?? false) : false;
    
    // Parse existing amenities
    List<String> existingAmenities = [];
    if (isEdit && hotel['amenities'] != null) {
      existingAmenities = (hotel['amenities'] as String).split(',').map((e) => e.trim()).toList();
    }
    
    final List<String> commonAmenities = ['Free WiFi', 'Swimming Pool', 'Gym', 'Restaurant', 'Parking', 'Air Conditioning'];
    List<String> selectedAmenities = commonAmenities.where((a) => existingAmenities.contains(a)).toList();
    List<String> otherAmenities = existingAmenities.where((a) => !commonAmenities.contains(a)).where((a) => a.isNotEmpty).toList();
    bool isOtherSelected = otherAmenities.isNotEmpty;
    final otherAmenityController = TextEditingController(text: otherAmenities.join(', '));
    
    // Sync reactive state with form
    controller.selectedHotelImagePath.value = isEdit ? (hotel['imageUrl'] ?? '') : '';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
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
                    isEdit ? 'Edit Hotel' : 'Create New Hotel',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Hotel Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.business_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price Per Night (\$)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roomsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Available Rooms',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.meeting_room_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1F36))),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...commonAmenities.map((amenity) {
                            final isSelected = selectedAmenities.contains(amenity);
                            return FilterChip(
                              label: Text(amenity),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    selectedAmenities.add(amenity);
                                  } else {
                                    selectedAmenities.remove(amenity);
                                  }
                                });
                              },
                              selectedColor: const Color(0xFF3F51B5).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF3F51B5),
                            );
                          }).toList(),
                          FilterChip(
                            label: const Text("Other"),
                            selected: isOtherSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                isOtherSelected = selected;
                                if (!selected) {
                                  otherAmenityController.clear();
                                }
                              });
                            },
                            selectedColor: const Color(0xFF3F51B5).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF3F51B5),
                          ),
                        ],
                      ),
                      if (isOtherSelected) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: otherAmenityController,
                          decoration: InputDecoration(
                            labelText: 'Custom Amenities (comma separated)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.add_circle_outline),
                          ),
                        ),
                      ],
                    ],
                  );
                }
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return SwitchListTile(
                    title: const Text("Mark as Featured", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1F36))),
                    subtitle: const Text("Show this hotel in the featured section"),
                    value: isFeatured,
                    onChanged: (val) => setModalState(() => isFeatured = val),
                    activeColor: const Color(0xFF43A047),
                    contentPadding: EdgeInsets.zero,
                  );
                }
              ),
              const SizedBox(height: 16),
              const Text('Hotel Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1F36))),
              const SizedBox(height: 12),
              Obx(() => GestureDetector(
                onTap: () => controller.pickAndUploadHotelImage(),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F1F4)),
                  ),
                  child: controller.isUploading.value 
                    ? const Center(child: CircularProgressIndicator())
                    : controller.selectedHotelImagePath.value.isNotEmpty
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                "${ApiConstants.mediaBaseUrl}${controller.selectedHotelImagePath.value}",
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error)),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt_rounded, size: 18, color: Color(0xFF3F51B5)),
                              ),
                            )
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('Add Hotel Image', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
              )),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  List<String> finalAmenities = [...selectedAmenities];
                  if (isOtherSelected && otherAmenityController.text.trim().isNotEmpty) {
                    finalAmenities.addAll(otherAmenityController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
                  }
                  
                  final data = {
                    'name': nameController.text,
                    'location': locController.text,
                    'description': descController.text,
                    'pricePerNight': double.tryParse(priceController.text) ?? 0.0,
                    'availableRooms': int.tryParse(roomsController.text) ?? 10,
                    'imageUrl': controller.selectedHotelImagePath.value,
                    'isFeatured': isFeatured,
                    'amenities': finalAmenities.join(', '),
                  };
                  if (isEdit) {
                    controller.updateHotel(hotel['id'], data);
                  } else {
                    controller.addHotel(data);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  isEdit ? 'Update Hotel Details' : 'Save Hotel Entry',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
