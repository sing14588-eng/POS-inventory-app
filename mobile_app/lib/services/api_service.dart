import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pos_app/utils/constants.dart';
import 'package:pos_app/services/storage_service.dart';

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = '${Constants.baseUrl}$endpoint';
    try {
      debugPrint('ApiService: POST to $url');
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('ApiService: Response from $url [${response.statusCode}]');
      return _processResponse(response);
    } catch (e) {
      debugPrint('ApiService ERROR on $url: $e');
      throw e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<dynamic> postAuth(String endpoint, Map<String, dynamic> body) async {
    final url = '${Constants.baseUrl}$endpoint';
    try {
      final headers = await _getHeaders();
      debugPrint('ApiService: POST AUTH to $url');
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('ApiService: Response from $url [${response.statusCode}]');
      return _processResponse(response);
    } catch (e) {
      debugPrint('ApiService ERROR on $url: $e');
      throw e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = '${Constants.baseUrl}$endpoint';
    try {
      final headers = await _getHeaders();
      debugPrint('ApiService: GET from $url');
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('ApiService: Response from $url [${response.statusCode}]');
      return _processResponse(response);
    } catch (e) {
      debugPrint('ApiService ERROR on $url: $e');
      throw e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = '${Constants.baseUrl}$endpoint';
    try {
      final headers = await _getHeaders();
      debugPrint('ApiService: PUT to $url');
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('ApiService: Response from $url [${response.statusCode}]');
      return _processResponse(response);
    } catch (e) {
      debugPrint('ApiService ERROR on $url: $e');
      throw Exception('Connection Error: $e');
    }
  }

  Future<String?> uploadImage(String filePath) async {
    final url = '${Constants.baseUrl}/upload';
    try {
      debugPrint('ApiService: Uploading image to $url');
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      final response =
          await request.send().timeout(const Duration(seconds: 30));
      debugPrint('ApiService: Upload Response Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final fullUrl = '${Constants.baseUrl}$resStr';
        debugPrint('ApiService: Image Uploaded: $fullUrl');
        return fullUrl;
      }
      return null;
    } catch (e) {
      debugPrint('ApiService UPLOAD ERROR: $e');
      return null;
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      String message = 'API Error ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) message = body['message'];
      } catch (_) {}
      throw message;
    }
  }
}
