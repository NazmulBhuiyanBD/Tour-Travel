import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user_model.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Token Management
  Future<bool> setToken(String token) async {
    return await _prefs.setString('jwt_token', token);
  }

  String? getToken() {
    return _prefs.getString('jwt_token');
  }

  // User Data Management
  Future<bool> setUser(UserModel user) async {
    return await _prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    String? userData = _prefs.getString('user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Clear Storage
  Future<void> clear() async {
    // Only clear auth data, preserve saved credentials if any
    await _prefs.remove('jwt_token');
    await _prefs.remove('user_data');
  }

  // Remember Me Credentials
  Future<bool> setSavedEmail(String email) async {
    return await _prefs.setString('saved_email', email);
  }

  String? getSavedEmail() {
    return _prefs.getString('saved_email');
  }

  Future<bool> setSavedPassword(String password) async {
    return await _prefs.setString('saved_password', password);
  }

  String? getSavedPassword() {
    return _prefs.getString('saved_password');
  }

  Future<void> clearSavedCredentials() async {
    await _prefs.remove('saved_email');
    await _prefs.remove('saved_password');
  }
}
