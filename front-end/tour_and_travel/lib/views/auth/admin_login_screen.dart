import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class AdminLoginScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: const Text('Admin Access'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 60, color: Colors.indigo),
                const SizedBox(width: 10),
                const Text("SYSADMIN", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E),),),
              ],
            ),
            const SizedBox(height: 40),
            const Text("System Administration Login", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E),),),
            const SizedBox(height: 40),
            
            _buildLabel("Admin Email"),
            _buildTextField(emailController, "Enter email"),
            
            const SizedBox(height: 20),
            _buildLabel("Password"),
            _buildTextField(passwordController, "Enter password", isPass: true),
            
            const SizedBox(height: 40),
            Obx(() => SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: authController.isLoading.value ? null : () {
                   authController.adminLogin(emailController.text, passwordController.text);
                },
                child: authController.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("ACCESS DASHBOARD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
  );

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isPass = false}) => TextField(
    controller: ctrl,
    obscureText: isPass,
    decoration: InputDecoration(
      hintText: hint, filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    ),
  );
}
