import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class AuthRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> loginApi(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.login, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> adminLoginApi(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminLogin, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> registerApi(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.register, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> changePasswordApi(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.changePassword, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> verifyEmailApi(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.verifyEmail, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> forgotPasswordApi(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.forgotPassword, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> resetPasswordApi(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.resetPassword, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
