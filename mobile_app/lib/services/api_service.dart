import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Constants.baseUrl}$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  Future<dynamic> postAuth(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${Constants.baseUrl}$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${Constants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${Constants.baseUrl}$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('${Constants.baseUrl}/upload'));
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      final response =
          await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        return '${Constants.baseUrl}$resStr';
      }
      return null;
    } catch (e) {
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
      throw Exception(message);
    }
  }
}
