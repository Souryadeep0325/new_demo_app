import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart'; // Make sure this imports your AuthStore
import 'package:fluttertoast/fluttertoast.dart'; // for toast messages

class UserProfilePanel extends StatefulWidget {
  final String? token;

  const UserProfilePanel({Key? key, required this.token}) : super(key: key);

  @override
  State<UserProfilePanel> createState() => _UserProfilePanelState();
}

class _UserProfilePanelState extends State<UserProfilePanel> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse('https://api.abcoped.shop/api/user/my-account');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        debugPrint('Error fetching user: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Exception: $e');
      setState(() => isLoading = false);
    }
  }

  void changePassword() {
    showDialog(
      context: context,
      builder: (_) => _ChangePasswordDialog(token: widget.token),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User Profile'),
      content: isLoading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : userData == null
          ? const Text('Failed to load user data.')
          : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text("Username: ${userData!['userName'] ?? ''}"),
          // Text("Email: ${userData!['userEmail'] ?? ''}"),
          // Text("Phone: ${userData!['phoneNumber'] ?? ''}"),
          // Text("Store Name: ${userData!['storeName'] ?? ''}"),
          // Text("DOB: ${userData!['dateOfBirth'] ?? 'N/A'}"),
          // Text("Role: ${userData!['userRoles'] ?? ''}"),
          Text("Username: ${userData!['userName'] ?? ''}"),
          Text("Email: ${userData!['userEmail'] ?? ''}"),
          Text("Phone: ${userData!['phoneNumber'] ?? ''}"),
          Text("DOB: ${userData!['dateOfBirth'] ?? 'N/A'}"),
          Text("Role: ${userData!['userRoles'] ?? ''}"),

          // Handle stores map
          if (userData!['stores'] != null && userData!['stores'] is Map)
            ...((userData!['stores'] as Map).entries.map((entry) =>
                Text("Store ID: ${entry.key}, Store Name: ${entry.value}")
            ))
          else
            const Text("No Store Assigned"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: changePassword,
            child: const Text("Change Password"),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        )
      ],
    );
  }
}
class _ChangePasswordDialog extends StatefulWidget {
  final String? token;

  const _ChangePasswordDialog({Key? key, required this.token}) : super(key: key);

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('https://api.abcoped.shop/api/auth/change-password');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': _oldPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Password changed successfully.');

        // Call logout and close all dialogs
        if (!mounted) return;
        final authStore = Provider.of<AuthStore>(context, listen: false);
        await _logout(context,authStore);


        Navigator.of(context)
          ..pop() // Close change password dialog
          ..pop();
        Navigator.pushReplacementNamed(context, '/login');// Close user profile panel
      } else {
        Fluttertoast.showToast(msg: 'Failed to change password.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Old Password'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Enter old password' : null,
            ),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              validator: (value) =>
              value == null || value.length < 6 ? 'Min 6 characters' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Change'),
        ),
      ],
    );
  }
}

Future<void> _logout(BuildContext context, AuthStore authStore) async {
  const logoutUrl = 'https://api.abcoped.shop/api/auth/logout';

  try {
    final response = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      authStore.logout(); // Clear user state
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showError(context, 'Logout failed with status ${response.statusCode}');
    }
  } catch (e) {
    _showError(context, 'Logout error: $e');
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

