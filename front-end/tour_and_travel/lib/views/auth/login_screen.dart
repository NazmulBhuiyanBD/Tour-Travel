import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                const Text("NAZTRAVEL", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E),),),
                //Image.asset("assets/images/mlogo.png", height: 80),
              ],
            ),
            const SizedBox(height: 40),
            const Text("Sign in to your account", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E),),),
            const SizedBox(height: 40),
            
            _buildLabel("Username"),
            _buildTextField(emailController, "Email"),
            
            const SizedBox(height: 20),
            _buildLabel("Password"),
            _buildTextField(passwordController, "Password", isPass: true),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Checkbox(value: false, onChanged: (v){}), const Text("Remember Me")]),
                TextButton(onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD), child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey))),
              ],
            ),
            
            const SizedBox(height: 20),
            Obx(() => SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F55D4), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: authController.isLoading.value ? null : () {
                   authController.login(emailController.text, passwordController.text);
                },
                child: authController.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("SIGN IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )),
            
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Create New Account  "),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), elevation: 0),
                  onPressed: () => Get.to(() => SignupScreen()),
                  child: const Text("SIGN UP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("OR", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed('/admin-login'),
                icon: const Icon(Icons.admin_panel_settings, color: Colors.indigo, size: 20),
                label: const Text("Login as System Administrator", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600, fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.indigo),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
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