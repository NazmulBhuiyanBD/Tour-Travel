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
    await _prefs.clear();
  }
}
