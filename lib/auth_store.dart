import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore extends ChangeNotifier {
  @observable
  bool isAuthenticated = false;

  @observable
  String role = 'guest'; // Can be 'admin', 'user', etc.

  @action
  void login(String userRole) {
    isAuthenticated = true;
    role = userRole;
    notifyListeners();  // Notify listeners when the state changes
  }

  @action
  void logout() {
    isAuthenticated = false;
    role = 'guest';
    notifyListeners();  // Notify listeners when the state changes
  }
}
