import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';

// Import only the necessary pages
import 'blood_availability_screen.dart';
import 'blood_request_screen.dart';
import 'donation_scheduling_screen.dart';
import 'emergency_mode_screen.dart';
import 'profile_screen.dart';

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
  String _userBloodGroup = '';
  String _userDistrict = '';
  String _userRole = 'donor'; // donor, recipient, admin
  bool _isLoading = true;
  bool _emergencyMode = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize animations
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

    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final userData = await widget.authService.getUserData();
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

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    // Show confirmation toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDarkMode ? 'Dark mode activated' : 'Light mode activated',
        ),
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    // In a real app, this would change the app theme
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
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/images/rakta_setu_logo.png',
          height: 40,
        ),
        actions: [
          // Dark Mode Toggle
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: _isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
            onPressed: _toggleDarkMode,
            tooltip: 'Toggle Theme',
          ),
          // Logout Button
          IconButton(
            icon: Icon(
              Icons.logout,
              color: _isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
            onPressed: widget.onLogout,
            tooltip: 'Logout',
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
                                color: _isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF2D3748),
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
                                color: _isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
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

                    const SizedBox(height: 30),

                    // Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B6B),
                            Color(0xFFFF3838),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3838).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your Blood Type',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _userBloodGroup,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _navigateToPage(const ProfileScreen()),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildProfileInfoItem(
                                title: _userDistrict,
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(width: 16),
                              _buildProfileInfoItem(
                                title: _userRole.toUpperCase(),
                                icon: Icons.local_hospital_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode
                            ? Colors.white
                            : const Color(0xFF2D3748),
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
                          title: 'My Profile',
                          icon: Icons.person_outline,
                          color: Colors.blue,
                          onTap: () => _navigateToPage(const ProfileScreen()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Emergency Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode
                            ? Colors.white
                            : const Color(0xFF2D3748),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: _toggleEmergencyMode,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _emergencyMode
                              ? Colors.red.withOpacity(0.15)
                              : _isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _emergencyMode
                                ? Colors.red
                                : _isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: _emergencyMode
                                    ? Colors.red.withOpacity(0.2)
                                    : _isDarkMode
                                        ? Colors.grey[700]
                                        : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.emergency,
                                color: _emergencyMode
                                    ? Colors.red
                                    : _isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[800],
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _emergencyMode
                                        ? 'Emergency Mode Active'
                                        : 'Emergency Blood Request',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _emergencyMode
                                          ? Colors.red
                                          : _isDarkMode
                                              ? Colors.white
                                              : Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _emergencyMode
                                        ? 'Tap to deactivate emergency mode'
                                        : 'Tap to activate emergency mode',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _emergencyMode
                                          ? Colors.red.withOpacity(0.8)
                                          : _isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: _emergencyMode
                                  ? Colors.red
                                  : _isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          foregroundColor:
                              _isDarkMode ? Colors.white : Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
          color: _isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
