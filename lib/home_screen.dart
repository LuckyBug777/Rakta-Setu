import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import only the necessary pages
import 'blood_availability_screen.dart';
import 'blood_request_screen.dart';
import 'blood_requests_list_screen.dart';
import 'donation_scheduling_screen.dart';
import 'emergency_mode_screen.dart';
import 'profile_screen.dart';
import 'about_page.dart';
import 'accepted_donors_page.dart';
import 'blood_tips_page.dart';
import 'donation_history_page.dart';
import 'blood_bank_finder_page.dart';
import 'notifications_page.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLogout;

  const HomeScreen({
    Key? key,
    required this.authService,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  String _userName = '';
  // ignore: unused_field
  String _userBloodGroup =
      ''; // Used for data loading, may be displayed in future UI updates
  // ignore: unused_field
  String _userDistrict =
      ''; // Used for data loading, may be displayed in future UI updates
  String _userRole = 'donor'; // donor, recipient, admin
  bool _isLoading = true;
  bool _emergencyMode = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
    _fetchAndStoreUserData();
  }

  /// Fetch user data from Firestore, store locally, then load for UI
  void _fetchAndStoreUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final phone = await widget.authService.getStoredPhoneNumber();
      if (phone != null) {
        final firestoreData =
            await widget.authService.getUserFromFirestore(phone);
        print('Fetched from Firestore: $firestoreData');
        if (firestoreData != null) {
          await widget.authService.saveUserData(firestoreData);
          _loadUserData();
          return;
        }
      }
      // fallback: load whatever is in local storage
      _loadUserData();
    } catch (e) {
      print('Error fetching/storing user data: $e');
      _loadUserData();
    }
  }

  void _loadUserData() async {
    try {
      final userData = await widget.authService.getUserData();
      print('Loaded from local: $userData');
      if (userData != null) {
        setState(() {
          _userName = userData['name'] ?? 'User';
          _userBloodGroup = userData['bloodGroup'] ?? 'Not specified';
          _userDistrict = userData['district'] ?? 'Not specified';
          _userRole = userData['role'] ?? 'donor';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _userName = 'User';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _userName = 'User';
      });
      print('Error loading user data: $e');
    }
  }

  void _toggleEmergencyMode() {
    setState(() {
      _emergencyMode = !_emergencyMode;
    });
    if (_emergencyMode) {
      _navigateToPage(const EmergencyModeScreen());
    }

    // Show confirmation toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _emergencyMode
              ? 'Emergency mode activated'
              : 'Emergency mode deactivated',
        ),
        backgroundColor: _emergencyMode ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/rakta_setu_logo.png',
              height: 40,
            ),
            const SizedBox(width: 12),
            const Text(
              'Rakta Setu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color:
                    Color(0xFF00FF41), // Matrix green color like splash screen
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          // Notifications Icon
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined,
                    color: Color(0xFFFF3838)),
                // You can add a badge here later for unread notifications count
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => _navigateToPage(
                NotificationsPage(authService: widget.authService)),
            tooltip: 'Notifications',
          ),
          // Profile Icon
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFFFF3838)),
            onPressed: () =>
                _navigateToPage(ProfileScreen(onLogout: widget.onLogout)),
            tooltip: 'My Profile',
          ),
          // About Icon
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFFF3838)),
            onPressed: () => _navigateToPage(AboutPage()),
            tooltip: 'About Rakta Setu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF3838),
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with user info and emergency toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Emergency Mode Toggle
                            Text(
                              'Emergency',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: _emergencyMode,
                              onChanged: (value) => _toggleEmergencyMode(),
                              activeColor: Colors.red,
                              activeTrackColor: Colors.red.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Emergency mode banner
                    if (_emergencyMode)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Emergency Mode Active',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Nearby donors are being notified of your emergency request',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(
                        height:
                            30), // Blood Requests Container (show only for donors) or Accepted Donors (for recipients)
                    if (_userRole == 'recipient')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FutureBuilder<int>(
                          future: _getAcceptedDonorCount(),
                          builder: (context, snapshot) {
                            int notifyCount = snapshot.data ?? 0;
                            return GestureDetector(
                              onTap: () =>
                                  _navigateToPage(AcceptedDonorsPage()),
                              child: Container(
                                width: double.infinity,
                                constraints:
                                    const BoxConstraints(minHeight: 70),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF38A169),
                                      const Color(0xFF2ECC71)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38A169)
                                          .withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        const Icon(Icons.people,
                                            color: Colors.white, size: 32),
                                        if (notifyCount > 0)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                notifyCount.toString(),
                                                style: const TextStyle(
                                                  color: Color(0xFF38A169),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),
                                    const Expanded(
                                      child: Text(
                                        'Accepted Donors',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const Tooltip(
                                      message:
                                          'View donors who accepted your request',
                                      child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 22),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else if (_userRole == 'donor')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _getLatestBloodRequests(),
                          builder: (context, snapshot) {
                            final requests = snapshot.data ?? [];
                            return GestureDetector(
                              onTap: () => _navigateToPage(
                                  const BloodRequestsListScreen()),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFF6B6B),
                                      const Color(0xFFFF3838)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B6B)
                                          .withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Stack(
                                          children: [
                                            const Icon(Icons.volunteer_activism,
                                                color: Colors.white, size: 28),
                                            if (requests.isNotEmpty)
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    requests.length.toString(),
                                                    style: const TextStyle(
                                                      color: Color(0xFFFF3838),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Latest Blood Requests',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (requests.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'No active blood requests at the moment',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    else
                                      Column(
                                        children:
                                            requests.take(2).map((request) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                // Blood group circle
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      request['bloodGroup'] ??
                                                          '',
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFFFF3838),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        request['patientName'] ??
                                                            'Patient',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${request['hospital'] ?? ''} • ${request['urgency'] ?? ''}',
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${request['requiredUnits'] ?? 0} units',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 30),

                    Text(
                      'Quick Actions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),

                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildActionCard(
                          title: 'Blood Availability',
                          icon: Icons.bloodtype_outlined,
                          color: Colors.red,
                          onTap: () =>
                              _navigateToPage(const BloodAvailabilityScreen()),
                        ),
                        _buildActionCard(
                          title: 'Request Blood',
                          icon: Icons.volunteer_activism_outlined,
                          color: Colors.orange,
                          onTap: () =>
                              _navigateToPage(const BloodRequestScreen()),
                        ),
                        _buildActionCard(
                          title: 'Donate Blood',
                          icon: Icons.calendar_today_outlined,
                          color: Colors.green,
                          onTap: () =>
                              _navigateToPage(const DonationSchedulingScreen()),
                        ),
                        _buildActionCard(
                          title: 'Donation History',
                          icon: Icons.history,
                          color: Colors.blue,
                          onTap: () => _navigateToPage(DonationHistoryPage(
                              authService: widget.authService)),
                        ),
                        _buildActionCard(
                          title: 'Blood Bank Finder',
                          icon: Icons.local_hospital,
                          color: Colors.teal,
                          onTap: () =>
                              _navigateToPage(const BloodBankFinderPage()),
                        ),
                        _buildActionCard(
                          title: 'Health Tips',
                          icon: Icons.health_and_safety,
                          color: Colors.purple,
                          onTap: () => _navigateToPage(const BloodTipsPage()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileInfoItem(
      {required String title, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getActiveRequestCount() async {
    // For donors: count all active (pending) blood requests
    try {
      final query = await FirebaseFirestore.instance
          .collection('blood_requests')
          .where('status', isEqualTo: 'pending')
          .get();
      return query.docs.length;
    } catch (e) {
      print('Error getting active request count: $e');
      return 0;
    }
  }

  Future<int> _getAcceptedDonorCount() async {
    // For recipients: count all donors who accepted their request
    try {
      final userData = await widget.authService.getUserData();
      final phone = userData != null ? userData['phoneNumber'] ?? '' : '';
      if (phone.isEmpty) return 0;

      final query = await FirebaseFirestore.instance
          .collection('blood_requests')
          .where('requestedBy', isEqualTo: phone)
          .orderBy('createdAt', descending: true)
          .get();
      int count = 0;
      for (var doc in query.docs) {
        final donorDetails = (doc['donorDetails'] ?? []) as List;
        count += donorDetails.length;
      }
      return count;
    } catch (e) {
      print('Error getting accepted donor count: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _getLatestBloodRequests() async {
    try {
      final userData = await widget.authService.getUserData();
      final userPhone = userData?['phoneNumber'] ?? '';

      final query = await FirebaseFirestore.instance
          .collection('blood_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      return query.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .where((req) =>
              req['requestedBy'] != userPhone) // Exclude user's own requests
          .toList();
    } catch (e) {
      print('Error getting latest blood requests: $e');
      return [];
    }
  }
}
