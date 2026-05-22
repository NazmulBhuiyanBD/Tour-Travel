import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/admin_management_view_model.dart';
import '../../core/constant/app_colors.dart';

class AdminUserManageScreen extends StatefulWidget {
  const AdminUserManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserManageScreen> createState() => _AdminUserManageScreenState();
}

class _AdminUserManageScreenState extends State<AdminUserManageScreen> {
  final controller = Get.find<AdminManagementViewModel>();
  final TextEditingController _searchController = TextEditingController();
  var filteredUsers = <dynamic>[].obs;

  @override
  void initState() {
    super.initState();
    filteredUsers.value = controller.users;
    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredUsers.value = controller.users;
    } else {
      filteredUsers.value = controller.users.where((user) {
        String name = (user['name'] ?? '').toString().toLowerCase();
        String email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
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
                    "Manage Users",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 8),
              const Text(
                "Manage user accounts and statuses.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF697386),
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF697386)),
                    hintText: "Search by name or email...",
                    hintStyle: const TextStyle(color: Color(0xFF697386), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // User List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)));
                  }
                  
                  // Update filtered users when controller users change
                  if (_searchController.text.isEmpty) {
                    filteredUsers.value = controller.users;
                  }

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_rounded, size: 64, color: Colors.grey.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          const Text("No users found", style: TextStyle(color: Color(0xFF697386))),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      bool isActive = user['isActive'] ?? true;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFFF0F1F4),
                              child: Text(
                                user['name']?[0].toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  color: Color(0xFF1A1F36),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1A1F36),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user['email'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF697386),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isActive,
                              activeColor: const Color(0xFF3F51B5),
                              onChanged: (val) {
                                controller.toggleUserStatus(user['id']);
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Delete User',
                                  middleText: 'Are you sure you want to delete this user?',
                                  textConfirm: 'Delete',
                                  textCancel: 'Cancel',
                                  confirmTextColor: Colors.white,
                                  buttonColor: const Color(0xFFE53935),
                                  onConfirm: () {
                                    controller.deleteUser(user['id']);
                                    Get.back();
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
