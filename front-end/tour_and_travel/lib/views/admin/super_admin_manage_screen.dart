import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/admin_management_view_model.dart';
import '../../core/constant/app_colors.dart';

class SuperAdminManageScreen extends StatelessWidget {
  const SuperAdminManageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminManagementViewModel());
    controller.fetchAdmins();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF673AB7),
        onPressed: () => _showAdminForm(context, controller),
        child: const Icon(Icons.add_moderator_rounded, color: Colors.white),
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
                    "Manage Admins",
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
                "System administrator controls and access.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF697386),
                ),
              ),
              const SizedBox(height: 24),

              // Admin List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.adminsList.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)));
                  }
                  
                  if (controller.adminsList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF673AB7).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.admin_panel_settings_rounded, size: 64, color: Color(0xFF673AB7)),
                          ),
                          const SizedBox(height: 16),
                          const Text("No administrators found", style: TextStyle(color: Color(0xFF697386))),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.adminsList.length,
                    itemBuilder: (context, index) {
                      final admin = controller.adminsList[index];
                      bool isSuper = admin['role'] == 'SuperAdmin';
                      
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
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isSuper ? const Color(0xFFEDE7F6) : const Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSuper ? Icons.security_rounded : Icons.shield_rounded,
                                color: isSuper ? const Color(0xFF673AB7) : const Color(0xFF3F51B5),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    admin['name'] ?? 'Admin',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1A1F36),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    admin['email'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF697386),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSuper ? const Color(0xFF673AB7).withOpacity(0.1) : const Color(0xFF3F51B5).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      admin['role'] ?? 'Admin',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSuper ? const Color(0xFF673AB7) : const Color(0xFF3F51B5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isSuper) 
                              IconButton(
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: 'Delete Admin',
                                    middleText: 'Are you sure you want to remove this administrator?',
                                    textConfirm: 'Delete',
                                    textCancel: 'Cancel',
                                    confirmTextColor: Colors.white,
                                    buttonColor: const Color(0xFFE53935),
                                    onConfirm: () {
                                      controller.deleteAdmin(admin['id']);
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

  void _showAdminForm(BuildContext context, AdminManagementViewModel controller) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'Admin';

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
              const Text(
                "Create New Admin",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
              ),
              const SizedBox(height: 24),
              _buildField(nameController, 'Full Name', Icons.person_rounded),
              const SizedBox(height: 16),
              _buildField(emailController, 'Email Address', Icons.email_rounded),
              const SizedBox(height: 16),
              _buildField(phoneController, 'Phone Number', Icons.phone_rounded),
              const SizedBox(height: 16),
              _buildField(passwordController, 'Password', Icons.lock_rounded, isPassword: true),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: ['Admin', 'SuperAdmin']
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedRole = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.security_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill required fields');
                    return;
                  }
                  final data = {
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'password': passwordController.text,
                    'role': selectedRole,
                  };
                  controller.createAdmin(data);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Provision Admin Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
