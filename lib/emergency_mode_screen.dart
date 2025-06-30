import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'auth_service.dart';

class EmergencyModeScreen extends StatefulWidget {
  const EmergencyModeScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final List<Map<String, dynamic>> _nearbyDonors = [];
  final AuthService _authService = AuthService();  String _currentUserPhone = '';
  String _currentUserDistrict = '';
  String _currentUserBloodGroup = '';
  String _currentUserName = '';
  bool _isLoading = true;
  StreamSubscription<QuerySnapshot>? _donorSubscription;
  StreamSubscription<QuerySnapshot>? _emergencyRequestSubscription;
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentUserData();
  }

  void _initializeAnimations() {
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
  }
  Future<void> _loadCurrentUserData() async {
    try {
      final userData = await _authService.getUserData();
      if (userData != null) {
        setState(() {
          _currentUserPhone = userData['phoneNumber'] ?? '';
          _currentUserDistrict = userData['district'] ?? '';
          _currentUserBloodGroup = userData['bloodGroup'] ?? '';
          _currentUserName = userData['name'] ?? '';
          _isLoading = false;
        });
        
        // Get current location for distance calculations
        await _getCurrentLocation();
        
        // Start emergency mode and find donors
        await _activateEmergencyMode();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('Unable to load user profile. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error loading user data: $e');
    }
  }
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Current position: ${currentPosition.latitude}, ${currentPosition.longitude}');
    } catch (e) {
      print('Error getting current location: $e');
    }
  }Future<void> _activateEmergencyMode() async {
    try {
      // Create emergency request document
      final emergencyRequestData = {
        'requestedBy': _currentUserPhone,
        'requesterName': _currentUserName,
        'bloodGroup': _currentUserBloodGroup,
        'district': _currentUserDistrict,
        'urgency': 'emergency',
        'status': 'active',
        'createdAt': Timestamp.now(),
        'respondingDonors': [],
        'isEmergency': true,
      };      final emergencyDoc = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .add(emergencyRequestData);

      // Find compatible donors in the same district
      await _findCompatibleDonors();

      // Send notifications to compatible donors
      await _notifyCompatibleDonors(emergencyDoc.id);

    } catch (e) {
      _showError('Failed to activate emergency mode: $e');
    }
  }

  Future<void> _findCompatibleDonors() async {
    try {
      // Get compatible blood types
      final compatibleTypes = _getCompatibleBloodTypes(_currentUserBloodGroup);
      
      // Query users in the same district with compatible blood types
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('district', isEqualTo: _currentUserDistrict)
          .where('bloodGroup', whereIn: compatibleTypes)
          .limit(20) // Limit to prevent excessive queries
          .get();

      // Set up real-time listener for donor responses
      _donorSubscription = FirebaseFirestore.instance
          .collection('emergency_requests')
          .where('requestedBy', isEqualTo: _currentUserPhone)
          .where('status', isEqualTo: 'active')
          .snapshots()
          .listen(_onEmergencyRequestUpdate);

      // Process found donors
      final donors = <Map<String, dynamic>>[];
      for (final doc in querySnapshot.docs) {
        final userData = doc.data();
        // Don't include the requester themselves
        if (userData['phoneNumber'] != _currentUserPhone) {
          donors.add({
            'id': doc.id,
            'name': userData['name'] ?? 'Unknown',
            'phone': userData['phoneNumber'] ?? '',
            'bloodGroup': userData['bloodGroup'] ?? '',
            'district': userData['district'] ?? '',
            'gender': userData['gender'] ?? '',
            'responding': false,
            'distance': _calculateDistance(), // Simulated distance
            'lastDonation': 'Available',
          });
        }
      }

      setState(() {
        _nearbyDonors.clear();
        _nearbyDonors.addAll(donors);
      });

    } catch (e) {
      _showError('Error finding compatible donors: $e');
    }
  }

  void _onEmergencyRequestUpdate(QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      final emergencyData = snapshot.docs.first.data() as Map<String, dynamic>;
      final respondingDonors = List<Map<String, dynamic>>.from(
        emergencyData['respondingDonors'] ?? []
      );

      // Update donor response status
      setState(() {
        for (int i = 0; i < _nearbyDonors.length; i++) {
          final donor = _nearbyDonors[i];
          final isResponding = respondingDonors.any(
            (responder) => responder['phone'] == donor['phone']
          );
          _nearbyDonors[i]['responding'] = isResponding;
        }
      });
    }
  }

  Future<void> _notifyCompatibleDonors(String emergencyRequestId) async {
    try {
      for (final donor in _nearbyDonors) {
        // Create notification for each compatible donor
        final notificationData = {
          'userPhone': donor['phone'],
          'type': 'emergency_request',
          'title': 'EMERGENCY BLOOD REQUEST',
          'message': 'Urgent: ${_currentUserName} needs ${_currentUserBloodGroup} blood in $_currentUserDistrict. Please respond if you can help!',
          'createdAt': Timestamp.now(),
          'isRead': false,
          'emergencyRequestId': emergencyRequestId,
          'requesterPhone': _currentUserPhone,
          'requesterName': _currentUserName,
          'bloodGroup': _currentUserBloodGroup,
          'district': _currentUserDistrict,
          'urgencyLevel': 'emergency',
        };

        await FirebaseFirestore.instance
            .collection('notifications')
            .add(notificationData);
      }
    } catch (e) {
      print('Error sending emergency notifications: $e');
    }
  }

  List<String> _getCompatibleBloodTypes(String bloodGroup) {
    // Define blood compatibility rules for recipients
    switch (bloodGroup) {
      case 'A+':
        return ['A+', 'A-', 'O+', 'O-'];
      case 'A-':
        return ['A-', 'O-'];
      case 'B+':
        return ['B+', 'B-', 'O+', 'O-'];
      case 'B-':
        return ['B-', 'O-'];
      case 'AB+':
        return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      case 'AB-':
        return ['A-', 'B-', 'AB-', 'O-'];
      case 'O+':
        return ['O+', 'O-'];
      case 'O-':
        return ['O-'];
      default:
        return ['O-']; // Safest option
    }
  }
  String _calculateDistance() {
    // Simulate distance calculation
    // In a real app, you would use location services
    final distances = ['0.5', '1.2', '2.1', '3.5', '4.8', '6.2', '8.0'];
    return distances[DateTime.now().millisecond % distances.length];
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  Future<void> _deactivateEmergencyMode() async {
    try {
      // Update emergency request status
      final emergencyRequests = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .where('requestedBy', isEqualTo: _currentUserPhone)
          .where('status', isEqualTo: 'active')
          .get();

      for (final doc in emergencyRequests.docs) {
        await doc.reference.update({'status': 'deactivated'});
      }

      // Cancel subscriptions
      _donorSubscription?.cancel();
      _emergencyRequestSubscription?.cancel();

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      _showError('Error deactivating emergency mode: $e');
    }
  }

  Future<void> _callEmergencyServices() async {
    try {
      const emergencyNumber = 'tel:108'; // Emergency number in India
      final uri = Uri.parse(emergencyNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError('Unable to make emergency call');
      }
    } catch (e) {
      _showError('Error calling emergency services: $e');
    }
  }  @override
  void dispose() {
    _pulseController.dispose();
    _donorSubscription?.cancel();
    _emergencyRequestSubscription?.cancel();
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading emergency mode...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
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
                      const SizedBox(width: 8),                      Text(
                        '${_nearbyDonors.length} nearby donors found',
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
              children: [                ElevatedButton(
                  onPressed: _deactivateEmergencyMode,
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
                  onPressed: _callEmergencyServices,
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
