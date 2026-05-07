import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tour_and_travel/data/api/app_exceptions.dart';
import 'package:tour_and_travel/data/services/storage_service.dart';
import 'api_client.dart';


class NetworkApiService extends BaseApiService {
  @override
  Future getGetApiResponse(String url) async {
    dynamic responseJson;
    try {
      final token = StorageService.to.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }

    return responseJson;
  }

  @override
  Future getPostApiResponse(String url, dynamic data) async {
    dynamic responseJson;
    try {
      final token = StorageService.to.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }

    return responseJson;
  }

  @override
  Future getPutApiResponse(String url, dynamic data) async {
    dynamic responseJson;
    try {
      final token = StorageService.to.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .put(Uri.parse(url), headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }

    return responseJson;
  }

  @override
  Future getDeleteApiResponse(String url) async {
    dynamic responseJson;
    try {
      final token = StorageService.to.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }

    return responseJson;
  }

  @override
  Future getMultipartApiResponse(String url, String filePath) async {
    dynamic responseJson;
    try {
      final token = StorageService.to.getToken();
      var request = http.MultipartRequest('POST', Uri.parse(url));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }

    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return response.body; // Return plain text if not JSON
        }
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          if (body.containsKey('error')) {
            throw UnauthorisedException(body['error'].toString());
          }
        } catch (e) {
          if (e is UnauthorisedException) rethrow;
        }
        throw UnauthorisedException('Invalid email or password or session expired');
      case 500:
        throw InternalServerErrorException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occurred while communicating with server with status code : ${response.statusCode}');
    }
  }
}
