import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthStore extends ChangeNotifier {
  bool _isAuthenticated = false;
  int qc = 0;
  int listed = 0;
  int sold = 0;
  int factory = 0;
  int scraped = 0;
  int totalTickets = 0;
  int completedTickets = 0;
  int pendingTickets = 0;
  String _role = 'guest';
  String? _token;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  String get role => _role;
  String? get token => _token;
  String? get username => _username;

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('https://api.abcoped.shop/api/auth/login');


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
          _role = roles[0];
          _isAuthenticated = true;
          _username = email.split('@')[0];
          await fetchTicketStatusCounts();
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
    _username = null;
    notifyListeners();
  }


  Future<void> fetchTicketStatusCounts() async {
    final url = Uri.parse('https://api.abcoped.shop/api/ticket/search-ticket/all-status/count');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      qc = data['QC'] ?? 0;
      listed = data['LISTED'] ?? 0;
      sold = data['SOLD'] ?? 0;
      factory = data['FACTORY'] ?? 0;
      scraped = data['SCRAPED'] ?? 0;
      totalTickets = qc +listed + factory+ sold + scraped;
      completedTickets = listed + qc+ factory;
      pendingTickets = sold +scraped;
    } else {
      throw Exception('Failed to fetch ticket counts. Status: ${response.statusCode}');
    }
  }
}
