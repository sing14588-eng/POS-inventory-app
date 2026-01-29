import 'package:flutter/material.dart';
import 'package:pos_app/models/user_model.dart';
import 'package:pos_app/services/api_service.dart';
import 'package:pos_app/utils/constants.dart';
import 'package:pos_app/services/storage_service.dart';
import 'package:pos_app/models/company_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  bool _isAuthenticated = false;
  String? _token;
  String? _role;
  List<String> _roles = [];
  String? _name;
  String? _email;
  String? _userId;
  String? _companyId;
  String? _companyName;
  Company? _currentCompany;
  String? _branchId;
  String? _branchName;
  bool _onboardingCompleted = false;
  bool _passwordChanged = true;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get passwordChanged => _passwordChanged;
  String? get role => _role;
  List<String> get roles => _roles;
  String? get name => _name;
  Company? get currentCompany => _currentCompany;
  String? get branchId => _branchId;
  String? get branchName => _branchName;

  // Temporary User object for backward compatibility
  User? get user => _isAuthenticated
      ? User(
          id: _userId ?? '',
          name: _name ?? '',
          email: _email ?? '',
          role: _role ?? '',
          roles: _roles,
          token: _token ?? '',
          companyId: _companyId,
          companyName: _companyName,
          branchId: _branchId,
          branchName: _branchName,
          onboardingCompleted: _onboardingCompleted,
          passwordChanged: _passwordChanged,
        )
      : null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      notifyListeners();

      final url = '${Constants.baseUrl}/auth/login';
      debugPrint('Attempting login to: $url with email: $email');

      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        // ... (rest of success logic)
        _token = response['token'];
        _isAuthenticated = true;
        _name = response['name'];

        if (response['user'] != null && response['user']['id'] != null) {
          _userId = response['user']['id'];
        } else if (response['id'] != null) {
          _userId = response['id'];
        }

        if (response['roles'] != null) {
          _roles = List<String>.from(response['roles']);
          _role = _roles.isNotEmpty ? _roles.first : null;
        } else {
          _role = response['role'];
          if (_role != null) _roles = [_role!];
        }

        if (response['company'] != null) {
          _currentCompany = Company.fromJson(response['company']);
          _companyId = _currentCompany!.id;
          _companyName = _currentCompany!.name;
          await _storage.saveCompanyId(_companyId!);
          await _storage.saveCompanyName(_companyName!);
        }

        if (response['branch'] != null) {
          _branchId = response['branch']['_id'];
          _branchName = response['branch']['name'];
        }

        _onboardingCompleted = response['onboardingCompleted'] ?? false;
        _passwordChanged = response['passwordChanged'] ?? true;
        _email = response['email'];

        if (response['user'] != null) {
          _email ??= response['user']['email'];
          if (response['user']['onboardingCompleted'] != null) {
            _onboardingCompleted = response['user']['onboardingCompleted'];
          }
          if (response['user']['passwordChanged'] != null) {
            _passwordChanged = response['user']['passwordChanged'];
          }
        }

        await _storage.saveToken(_token!);
        if (_role != null) await _storage.saveRole(_role!);
        if (_userId != null) await _storage.saveUserId(_userId!);

        notifyListeners();
        return true;
      }
      _errorMessage = 'Invalid response from server';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
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

  Future<void> refreshUserData() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response != null) {
        if (response['company'] != null) {
          _currentCompany = Company.fromJson(response['company']);
        }
        if (response['branch'] != null) {
          _branchId = response['branch']['_id'];
          _branchName = response['branch']['name'];
        }
        _name = response['name'];
        _email = response['email'];
        _roles = List<String>.from(response['roles'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh user data error: $e');
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _role = null;
    _userId = null;
    _roles = [];
    _name = null;
    _email = null;

    await _storage.clearAll();

    notifyListeners();
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      await _apiService
          .put('/users/change-password', {'newPassword': newPassword});
      return true;
    } catch (e) {
      debugPrint("Change password error: $e");
      return false;
    }
  }

  Future<bool> completeOnboarding() async {
    try {
      await _apiService.put('/users/onboarding-complete', {});
      _onboardingCompleted = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Complete onboarding error: $e");
      return false;
    }
  }

  Future<void> resetOnboardingLocal() async {
    _onboardingCompleted = false;
    notifyListeners();
  }

  String getDashboardRoute() {
    if (_role == 'super_admin') return '/super-admin';
    if (_role == 'admin') return '/admin';
    if (_role == 'picker') return '/picker';
    if (_role == 'accountant') return '/accountant';
    if (_role == 'warehouse') return '/warehouse';
    return '/sales'; // Default
  }
}
