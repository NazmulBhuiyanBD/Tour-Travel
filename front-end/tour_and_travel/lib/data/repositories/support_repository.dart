import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class SupportRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> createTicket(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.createTicket, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUserTickets(int userId) async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          '${ApiConstants.baseUrl}${ApiConstants.userTickets}/$userId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAllTickets() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminTickets);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTicketDetails(int ticketId) async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          '${ApiConstants.baseUrl}${ApiConstants.ticketDetails}/$ticketId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> sendMessage(int ticketId, dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          '${ApiConstants.baseUrl}${ApiConstants.sendMessage}/$ticketId/message', data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> closeTicket(int ticketId) async {
    try {
      dynamic response = await _apiService.getPutApiResponse(
          '${ApiConstants.baseUrl}${ApiConstants.closeTicket}/$ticketId/close', {});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
