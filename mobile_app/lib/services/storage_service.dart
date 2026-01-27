import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'token';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'userId';
  static const String _companyIdKey = 'companyId';
  static const String _companyNameKey = 'companyName';

  // Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Role
  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  // User ID
  Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Company Info
  Future<void> saveCompanyId(String id) async {
    await _storage.write(key: _companyIdKey, value: id);
  }

  Future<String?> getCompanyId() async {
    return await _storage.read(key: _companyIdKey);
  }

  Future<void> saveCompanyName(String name) async {
    await _storage.write(key: _companyNameKey, value: name);
  }

  Future<String?> getCompanyName() async {
    return await _storage.read(key: _companyNameKey);
  }

  // Clear All (Logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
