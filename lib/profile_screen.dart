// profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFFF3838),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Profile Screen - Coming Soon'),
      ),
    );
  }
}