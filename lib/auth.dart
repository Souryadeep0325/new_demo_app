import 'package:flutter/material.dart';

class AuthStore extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _role = 'guest'; // Default role can be 'admin', 'user', etc.

  bool get isAuthenticated => _isAuthenticated;
  String get role => _role;

  // Login method to authenticate the user and set role
  void login(String userRole) {
    _isAuthenticated = true;
    _role = userRole;
    notifyListeners(); // Notify listeners when the state changes
  }

  // Logout method to reset authentication
  void logout() {
    _isAuthenticated = false;
    _role = 'guest'; // Reset to guest after logout
    notifyListeners(); // Notify listeners when the state changes
  }
}
