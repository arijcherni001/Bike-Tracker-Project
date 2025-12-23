import 'package:bike_tracker_app/screens/login.dart';
import 'package:bike_tracker_app/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/constants.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  void _showAdminPinDialog(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    String errorMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Admin Access',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter 6-digit PIN code',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: blueColor, width: 2),
                      ),
                      hintText: '● ● ● ● ● ●',
                      errorText: errorMessage.isEmpty ? null : errorMessage,
                    ),
                    onChanged: (value) {
                      if (errorMessage.isNotEmpty) {
                        setState(() {
                          errorMessage = '';
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (pinController.text == '123456') {
                      Navigator.of(dialogContext).pop();
                      Navigator.pushNamed(context, '/admin');
                    } else {
                      setState(() {
                        errorMessage = 'Invalid PIN code';
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Image.asset(
                'assets/images/map1.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Admin Button (top right)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.admin_panel_settings,
                  color: blueColor,
                  size: 32,
                ),
                onPressed: () {
                  _showAdminPinDialog(context);
                },
                tooltip: 'Admin Dashboard',
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Track your rides, monitor your performance, and enjoy a smarter cycling experience with BikeTracker.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Logo
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 111,
                      height: 111,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(
                      'BikeTracker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 95),
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Create Account (text button)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen()),
                      );
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
