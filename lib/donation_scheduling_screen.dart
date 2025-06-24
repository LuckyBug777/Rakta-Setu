// donation_scheduling_screen.dart
import 'package:flutter/material.dart';

class DonationSchedulingScreen extends StatelessWidget {
  const DonationSchedulingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Donation'),
        backgroundColor: const Color(0xFF38A169),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Donation Scheduling Screen - Coming Soon'),
      ),
    );
  }
}