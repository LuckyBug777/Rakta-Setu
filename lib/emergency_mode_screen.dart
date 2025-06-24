import 'package:flutter/material.dart';
import 'dart:async';

class EmergencyModeScreen extends StatefulWidget {
  const EmergencyModeScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _nearbyDonorsCount = 0;
  Timer? _donorCountTimer;
  final List<Map<String, dynamic>> _nearbyDonors = [];

  @override
  void initState() {
    super.initState();
    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _pulseController.forward();
        }
      });

    _pulseController.forward();

    // Simulate finding nearby donors
    _simulateNearbyDonors();
  }

  void _simulateNearbyDonors() {
    // Simulate finding donors every 3 seconds
    _donorCountTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_nearbyDonorsCount < 12) {
        // Cap at 12 donors
        setState(() {
          _nearbyDonorsCount += 1;

          // Add a simulated donor
          if (_nearbyDonorsCount <= 12) {
            _nearbyDonors.add({
              'name': 'Donor ${_nearbyDonorsCount}',
              'distance': ((_nearbyDonorsCount * 0.5) + 0.5).toStringAsFixed(1),
              'bloodGroup': _getRandomBloodGroup(),
              'lastDonation': '${_nearbyDonorsCount * 15} days ago',
              'responding': _nearbyDonorsCount % 3 == 0
                  ? true
                  : false, // Every 3rd donor is responding
            });
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _getRandomBloodGroup() {
    final groups = ['A+', 'B+', 'AB+', 'O+', 'A-', 'B-', 'AB-', 'O-'];
    return groups[DateTime.now().millisecondsSinceEpoch % groups.length];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _donorCountTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Mode'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Red background with pulse animation at the top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[900]!, Colors.red[700]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Pulsing Emergency Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Emergency Mode Text
                const Text(
                  'EMERGENCY MODE ACTIVATED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Searching for nearby compatible donors',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Counter for nearby donors
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_nearbyDonorsCount nearby donors found',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List of nearby donors responding
          Expanded(
            child: _nearbyDonors.isEmpty
                ? const Center(
                    child: Text(
                      'Searching for nearby donors...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _nearbyDonors.length,
                    itemBuilder: (context, index) {
                      final donor = _nearbyDonors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: donor['responding']
                                ? Colors.green.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.2),
                            width: donor['responding'] ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Donor blood group circle
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withOpacity(0.1),
                                  border:
                                      Border.all(color: Colors.red.shade300),
                                ),
                                child: Center(
                                  child: Text(
                                    donor['bloodGroup'],
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Donor info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      donor['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${donor['distance']} km away',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          donor['lastDonation'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Status indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: donor['responding']
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: donor['responding']
                                        ? Colors.green
                                        : Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  donor['responding']
                                      ? 'Responding'
                                      : 'Notified',
                                  style: TextStyle(
                                    color: donor['responding']
                                        ? Colors.green
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'DEACTIVATE EMERGENCY MODE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'CALL FOR MEDICAL ASSISTANCE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
