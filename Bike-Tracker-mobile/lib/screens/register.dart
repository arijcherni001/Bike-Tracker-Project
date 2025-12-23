import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _cinController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _cinController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save additional user data to Firestore (DO NOT store password!)
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userCredential.user!.uid)
          .set({
        'Nom d\'utilisateur': _usernameController.text.trim(),
        'Email': _emailController.text.trim(),
        'Num Tel': int.parse(_phoneController.text.trim()),
        'CIN': int.parse(_cinController.text.trim()),
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user', // default role
      });

      // Update display name
      await userCredential.user!
          .updateDisplayName(_usernameController.text.trim());

      if (mounted) {
        _showSnackBar("Account created successfully!", isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: ${e.toString()}',
          isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BikeTracker - Create Account'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              const Text(
                "Create your account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // Username
              TextFormField(
                controller: _usernameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your username' : null,
              ),
              const SizedBox(height: 20),

              // CIN
              TextFormField(
                controller: _cinController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CIN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your CIN';
                  if (int.tryParse(value) == null)
                    return 'CIN must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email
              TextFormField(
                controller: _emailController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your email';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone
              TextFormField(
                controller: _phoneController,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Num Tel',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your phone number';
                  if (int.tryParse(value) == null)
                    return 'Phone number must be numeric';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a password' : null,
              ),
              const SizedBox(height: 20),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                enabled: !_isLoading,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) => value != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),

              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
