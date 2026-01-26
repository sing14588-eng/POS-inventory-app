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
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}$endpoint'),
      headers: {'Content-Type': 'application/json'}, // Login doesn't need token usually, or handle separately
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> postAuth(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}$endpoint'),
      headers: headers,
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}
