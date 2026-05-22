import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/auth_view_model.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final AuthViewModel authViewModel = Get.find<AuthViewModel>();
  final TextEditingController emailController = TextEditingController();

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
            const Text("Forgot Password", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const Text("Enter your email to receive a reset code", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            _buildField("Email Address", emailController, "Enter your email"),
            
            const SizedBox(height: 30),
            Obx(() => SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F55D4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: authViewModel.isLoading.value ? null : () {
                  authViewModel.forgotPassword(emailController.text);
                },
                child: authViewModel.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SEND CODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )),
            
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => Get.back(),
              child: const Center(child: Text("Back to Login", style: TextStyle(color: Color(0xFF2F55D4)))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
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
