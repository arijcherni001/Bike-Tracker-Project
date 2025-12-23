import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController =
      TextEditingController(text: "John Doe");
  final TextEditingController _emailController =
      TextEditingController(text: "john.doe@example.com");
  final TextEditingController _phoneController =
      TextEditingController(text: "+1 234 567 890");

  bool _isEditing = false;

  // Temporary local profile picture (no backend)
  final String _profileImage = 'assets/images/profile_placeholder.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(_profileImage),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          // You can add an image picker here later
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Image picker not implemented"),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera_alt, color: Colors.black),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Name Field
            TextField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 20),

            // Email Field
            TextField(
              controller: _emailController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 20),

            // Phone Field
            TextField(
              controller: _phoneController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 30),

            // Save Button (only visible in edit mode)
            if (_isEditing)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
