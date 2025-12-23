import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  Future<void> signUserIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _isLoading = true;
    });

    try {
      // Debug: mark start of sign-in
      // ignore: avoid_print
      print('signUserIn: starting sign-in for ${_emailController.text.trim()}');
      // Sign in with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Debug: sign-in returned successfully
      // ignore: avoid_print
      print(
          'signUserIn: signInWithEmailAndPassword returned, uid=${userCredential.user?.uid}');

      // Optionally fetch user data from Firestore (non-blocking)
      try {
        final String? uid = FirebaseAuth.instance.currentUser?.uid;
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('user').doc(uid).get();
        // Debug: firestore user document fetched
        // ignore: avoid_print
        print(
            'signUserIn: fetched userDoc for uid=${uid} data=${userDoc.data()}');
      } catch (e, st) {
        // Firestore permission errors should not block login navigation
        // ignore: avoid_print
        print('signUserIn: Firestore fetch failed: $e');
        // ignore: avoid_print
        print(st);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged in, but profile data not accessible.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );
        Navigator.pushReplacementNamed(context, '/ble');
      }
    } on FirebaseAuthException catch (e, st) {
      String message = 'Invalid email or password.';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Invalid email or password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          // keep default
          break;
      }

      // Log the detailed FirebaseAuthException to console for debugging
      // and show a SnackBar with the friendly message.
      // Also set the field error so it appears under the password field.
      // This gives the user clearer feedback when login fails.
      // Example: e.code may be 'wrong-password', 'user-not-found', etc.
      // Print full error for developer inspection.
      // Note: avoid exposing raw e.message to users in production.
      // For now we show a concise friendly message and log details.
      //
      // Developer log:
      // ignore: avoid_print
      print(
          'FirebaseAuthException during sign in: code=${e.code} message=${e.message}');
      // ignore: avoid_print
      print(st);

      if (mounted) {
        setState(() {
          _passwordError = message;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      // Generic error handler: log and show the error so we can debug.
      // ignore: avoid_print
      print('Error during sign in: $e');
      // ignore: avoid_print
      print(st);
      final String message = 'An error occurred. Please try again.';
      if (mounted) {
        setState(() {
          _passwordError = message;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('BikeTracker Login')),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/images/login.jpg', height: 140),
                  const SizedBox(height: 20),
                  const Text(
                    "Sign in",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // --- Email field ---
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      errorText: _emailError,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- Password field ---
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText: _passwordError,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ForgotPasswordPage(),
                        //   ),
                        // );
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Login button ---
                  ElevatedButton(
                    onPressed: _isLoading ? null : signUserIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Sign in"),
                  ),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Not a member?'),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateAccountScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
