import 'package:flutter/material.dart';
import 'package:news_app/custom_appbar.dart';
import 'auth.dart';
import 'package:provider/provider.dart';
import 'centred_view.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);

    return CentredView(
      child: Scaffold(
        appBar:const CustomAppBar(appBarTitle: 'Sign-In',),
        body: Center(
          child: Container(
            height: 400,
            width: 400,
            decoration: BoxDecoration(
              color: Colors.blue, // Set the background color to blue
              borderRadius: BorderRadius.circular(10), // Optional: add rounded corners
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sign-in:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      
                // User ID Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: TextField(
                    controller: _userIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter User ID'),
                  ),
                ),
      
                // Organization Name Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: TextField(
                    controller: _organizationController,
                    decoration: const InputDecoration(labelText: 'Enter Organization Name'),
                  ),
                ),
      
                // Role Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(labelText: 'Enter Role (admin/user)'),
                  ),
                ),
      
                const SizedBox(height: 16,),
                // Login Button
                ElevatedButton(
                  onPressed: () {
                    final role = _roleController.text;
                    final userId = int.tryParse(_userIdController.text); // Parsing user ID as integer
                    final organization = _organizationController.text;
      
                    // Verifying if any field is empty or invalid
                    if (_userIdController.text.isEmpty ||
                        _organizationController.text.isEmpty ||
                        _roleController.text.isEmpty) {
                      // If any field is empty, show an alert dialog
                      _showAlertDialog(context, 'All fields must be filled.');
                    } else if (userId == null) {
                      // If User ID is not a valid integer, show an error message
                      _showAlertDialog(context, 'User ID must be a valid integer.');
                    } else if (role != 'admin' && role != 'user') {
                      // If the role is neither 'admin' nor 'user'
                      _showAlertDialog(context, 'Role must be either "admin" or "user".');
                    } else {
                      // If all fields are valid, perform login
                      authStore.login(role);  // Log the user in with the role
                      Navigator.pushReplacementNamed(context, '/home'); // Navigate to HomePage
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to show an AlertDialog with the error message
  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: SizedBox(
            width: 400, // Set the width of the dialog to 400
            child: Text(message), // The message content
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);  // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
