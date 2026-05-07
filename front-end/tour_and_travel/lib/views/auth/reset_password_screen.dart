import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final String email = Get.arguments ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const Text("Reset Password", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            Text("Enter the code sent to $email and your new password", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            _buildField("Reset Code", codeController, "Enter 6-digit code"),
            _buildField("New Password", passController, "Enter new password", isPass: true),
            _buildField("Confirm Password", confirmPassController, "Confirm new password", isPass: true),
            
            const SizedBox(height: 30),
            Obx(() => SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F55D4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: authController.isLoading.value ? null : () {
                  if (passController.text != confirmPassController.text) {
                    Get.snackbar("Error", "Passwords do not match");
                    return;
                  }
                  authController.resetPassword(email, codeController.text, passController.text);
                },
                child: authController.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("RESET PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, {bool isPass = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl, obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint, filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
      const SizedBox(height: 15),
    ],
  );
}
