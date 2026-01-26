import 'package:flutter/material.dart';
import 'package:pos_app/models/user_model.dart';
import 'package:pos_app/services/api_service.dart';
import 'package:pos_app/utils/constants.dart';
import 'package:pos_app/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  bool _isAuthenticated = false;
  String? _token;
  String? _role;
  List<String> _roles = [];
  String? _name;
  String? _userId;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  List<String> get roles => _roles;
  String? get name => _name;

  // Temporary User object for backward compatibility
  User? get user => _isAuthenticated
      ? User(
          id: _userId ?? '',
          name: _name ?? '',
          email: '', // Email not always stored locally
          role: _role ?? '',
          token: _token ?? '',
        )
      : null;

  Future<bool> login(String email, String password) async {
    try {
      final url = '${Constants.baseUrl}/auth/login';
      debugPrint('Attempting login to: $url with email: $email');

      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        _token = response['token'];
        _isAuthenticated = true;
        _name = response['name'];

        // Handle User ID
        if (response['user'] != null && response['user']['id'] != null) {
          _userId = response['user']['id'];
        } else if (response['id'] != null) {
          _userId = response['id'];
        }

        // Handle roles array
        if (response['roles'] != null) {
          _roles = List<String>.from(response['roles']);
          // Default to first role or null if empty
          _role = _roles.isNotEmpty ? _roles.first : null;
        } else {
          // Fallback for old backend/data
          _role = response['role'];
          if (_role != null) _roles = [_role!];
        }

        // Securely save data
        await _storage.saveToken(_token!);
        if (_role != null) await _storage.saveRole(_role!);
        // Note: StorageService implementation might need saveUserId or we skip it if not present
        if (_userId != null) await _storage.saveUserId(_userId!);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  void setCurrentRole(String role) {
    if (_roles.contains(role)) {
      _role = role;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.getToken();
    if (token == null) return false;

    _token = token;
    _role = await _storage.getRole();
    _userId = await _storage.getUserId();
    _isAuthenticated = true;

    // Note: We might want to re-fetch user details (roles/name) here calling an API
    // For now we just restore the token and role we have.

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _role = null;
    _userId = null;
    _roles = [];
    _name = null;

    await _storage.clearAll();

    notifyListeners();
  }
}
