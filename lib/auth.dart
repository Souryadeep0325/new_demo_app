import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthStore extends ChangeNotifier {
  bool _isAuthenticated = false;

  String _role = 'guest';
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String get role => _role;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('http://35.154.252.161:8080/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userEmail': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roles = List<String>.from(data['roles'] ?? []);

        if (roles.contains('ROLE_MANAGER')) {
          _token = data['token'];
          _role = 'ROLE_MANAGER';
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Login failed: $e');
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _role = 'guest';
    _token = null;
    notifyListeners();
  }
}
