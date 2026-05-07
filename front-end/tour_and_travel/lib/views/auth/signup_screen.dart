import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class SignupScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text("Create New Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const Text("Enter Your Account Details", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            
            _buildField("Your Name", nameController, "Enter Your Name"),
            _buildField("Your Email", emailController, "Enter Your Email"),
            _buildField("Password", passController, "Password", isPass: true),
            _buildField("Confirm Password", confirmPassController, "Confirm Password", isPass: true),
            
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
                  authController.register(
                    nameController.text, 
                    emailController.text, 
                    passController.text, 
                    "0000000000" // Default phone for now
                  );
                },
                child: authController.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )),
            
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have Account?  "),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), elevation: 0),
                  onPressed: () => Get.back(),
                  child: const Text("SIGN IN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                )
              ],
            )
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