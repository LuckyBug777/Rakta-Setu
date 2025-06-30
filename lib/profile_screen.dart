// profile_screen.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const ProfileScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _locationController;

  // Dropdown options (same as register screen)
  final List<String> _karnatakaDistricts = [
    'Bagalkot',
    'Ballari',
    'Belagavi',
    'Bengaluru Rural',
    'Bengaluru Urban',
    'Bidar',
    'Chamarajanagar',
    'Chikballapur',
    'Chikkamagaluru',
    'Chitradurga',
    'Dakshina Kannada',
    'Davanagere',
    'Dharwad',
    'Gadag',
    'Hassan',
    'Haveri',
    'Kalaburagi',
    'Kodagu',
    'Kolar',
    'Koppal',
    'Mandya',
    'Mysuru',
    'Raichur',
    'Ramanagara',
    'Shivamogga',
    'Tumakuru',
    'Udupi',
    'Uttara Kannada',
    'Vijayapura',
    'Yadgir'
  ];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
      _nameController = TextEditingController(
          text: userData != null ? userData["name"] ?? "" : "");
      _genderController = TextEditingController(
          text: userData != null ? userData["gender"] ?? "" : "");
      _bloodGroupController = TextEditingController(
          text: userData != null ? userData["bloodGroup"] ?? "" : "");
      _locationController = TextEditingController(
          text: userData != null
              ? (userData["district"] ?? userData["location"] ?? "")
              : "");

      // Initialize dropdown selections
      _selectedGender = userData != null ? userData["gender"] : null;
      _selectedBloodGroup = userData != null ? userData["bloodGroup"] : null;
      _selectedDistrict = userData != null
          ? (userData["district"] ?? userData["location"])
          : null;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      }); // Get phone number from current user data
      final phoneNumber = _userData?["phoneNumber"] ?? _userData?["phone"];
      if (phoneNumber == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final updatedData = {
        "name": _nameController.text,
        "gender": _selectedGender ?? _genderController.text,
        "bloodGroup": _selectedBloodGroup ?? _bloodGroupController.text,
        "district": _selectedDistrict ?? _locationController.text,
        "phoneNumber": phoneNumber,
      };

      try {
        // Update data in Firestore
        await _authService.createOrUpdateUser(
          phoneNumber: phoneNumber,
          userData: updatedData,
        );

        // Save updated data locally
        await _authService.saveUserData(updatedData);

        // Reload user data
        await _loadUserData();

        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Handle error (you might want to show a snackbar or toast)
        print('Error saving profile: $e');
      }
    }
  }

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      // Use the callback if provided, otherwise pop back
      if (widget.onLogout != null) {
        widget.onLogout!();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600], size: 28),
              const SizedBox(width: 10),
              const Text('Delete Account',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final phoneNumber = _userData?["phoneNumber"] ?? _userData?["phone"];
      if (phoneNumber != null) {
        // Delete from Firestore
        await _authService.deleteUserFromFirestore(phoneNumber);
      }

      // Sign out and clear local data
      await _authService.signOut();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate to login screen and clear all previous routes
        if (widget.onLogout != null) {
          widget.onLogout!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUserData = _userData != null;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading) ...[
            IconButton(
              icon: Icon(Icons.delete_forever_rounded, color: Colors.white),
              tooltip: 'Delete Account',
              onPressed: _showDeleteAccountDialog,
            ),
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit,
                  color: Colors.white),
              tooltip: _isEditing ? 'Cancel' : 'Edit',
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFF6B6B),
                        Color(0xFFFF3838),
                        Color(0xFFDC143C),
                        Color(0xFFFFE5E5),
                      ],
                      stops: [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        // Avatar with shadow and border
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(0xFFFF3838),
                              child: Text(
                                (hasUserData &&
                                        _userData!["name"] != null &&
                                        _userData!["name"]
                                            .toString()
                                            .isNotEmpty)
                                    ? _userData!["name"]
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                    fontSize: 48,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          hasUserData &&
                                  _userData!["name"] != null &&
                                  _userData!["name"].toString().isNotEmpty
                              ? _userData!["name"]
                              : "Unknown",
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasUserData &&
                                  (_userData!["phoneNumber"] != null ||
                                      _userData!["phone"] != null)
                              ? (_userData!["phoneNumber"] ??
                                  _userData!["phone"])
                              : "",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bloodtype,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              _isEditing
                                  ? SizedBox(
                                      width: 80,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedBloodGroup,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                        dropdownColor: const Color(0xFFFF3838),
                                        items: _bloodGroups.map((String item) {
                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item,
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          );
                                        }).toList(),
                                        onChanged: (value) => setState(
                                            () => _selectedBloodGroup = value),
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'Required'
                                            : null,
                                      ),
                                    )
                                  : Text(
                                      hasUserData &&
                                              _userData!["bloodGroup"] != null
                                          ? _userData!["bloodGroup"]
                                          : "N/A",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          color: Colors.white.withOpacity(0.98),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _isEditing
                                    ? _editProfileField('Name', _nameController,
                                        icon: Icons.person,
                                        iconColor: Color(0xFFFF3838))
                                    : _profileField(
                                        'Name',
                                        hasUserData &&
                                                _userData!["name"] != null
                                            ? _userData!["name"]
                                            : "Unknown",
                                        icon: Icons.person,
                                        iconColor: Color(0xFFFF3838),
                                      ),
                                const SizedBox(height: 20),
                                _profileField(
                                  'Phone Number',
                                  hasUserData &&
                                          (_userData!["phoneNumber"] != null ||
                                              _userData!["phone"] != null)
                                      ? (_userData!["phoneNumber"] ??
                                          _userData!["phone"])
                                      : "",
                                  icon: Icons.phone,
                                  iconColor: Color(0xFF2D3748),
                                ),
                                const SizedBox(height: 20),
                                _isEditing
                                    ? _editProfileDropdownField(
                                        'Gender', _selectedGender, _genders,
                                        icon: Icons.wc,
                                        iconColor: Color(0xFF6B7280),
                                        onChanged: (value) => setState(
                                            () => _selectedGender = value))
                                    : _profileField(
                                        'Gender',
                                        hasUserData &&
                                                _userData!["gender"] != null
                                            ? _userData!["gender"]
                                            : "Not specified",
                                        icon: Icons.wc,
                                        iconColor: Color(0xFF6B7280),
                                      ),
                                const SizedBox(height: 20),
                                _isEditing
                                    ? _editProfileDropdownField('Blood Group',
                                        _selectedBloodGroup, _bloodGroups,
                                        icon: Icons.bloodtype,
                                        iconColor: Color(0xFFFF3838),
                                        onChanged: (value) => setState(
                                            () => _selectedBloodGroup = value))
                                    : _profileField(
                                        'Blood Group',
                                        hasUserData &&
                                                _userData!["bloodGroup"] != null
                                            ? _userData!["bloodGroup"]
                                            : "N/A",
                                        icon: Icons.bloodtype,
                                        iconColor: Color(0xFFFF3838),
                                      ),
                                const SizedBox(height: 20),
                                _isEditing
                                    ? _editProfileDropdownField('District',
                                        _selectedDistrict, _karnatakaDistricts,
                                        icon: Icons.location_on,
                                        iconColor: Color(0xFFDC143C),
                                        onChanged: (value) => setState(
                                            () => _selectedDistrict = value))
                                    : _profileField(
                                        'District',
                                        hasUserData &&
                                                (_userData!["district"] !=
                                                        null ||
                                                    _userData!["location"] !=
                                                        null)
                                            ? (_userData!["district"] ??
                                                _userData!["location"])
                                            : "Not specified",
                                        icon: Icons.location_on,
                                        iconColor: Color(0xFFDC143C),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        _isEditing
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFFF3838),
                                  minimumSize: const Size(double.infinity, 54),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                ),
                                icon: const Icon(Icons.save),
                                label: const Text('Save',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                onPressed: _saveProfile,
                              )
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFFF3838),
                                  minimumSize: const Size(double.infinity, 54),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                ),
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                onPressed: _logout,
                              ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _profileField(String label, String value,
      {IconData? icon, Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 2),
            child: Icon(icon, color: iconColor ?? Colors.black54, size: 24),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editProfileField(String label, TextEditingController controller,
      {IconData? icon, Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 2),
            child: Icon(icon, color: iconColor ?? Colors.black54, size: 24),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: controller,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748)),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  filled: true,
                  fillColor: Color(0xFFF3F4F6),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editProfileDropdownField(
      String label, String? selectedValue, List<String> items,
      {IconData? icon,
      Color? iconColor,
      required Function(String?) onChanged}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 2),
            child: Icon(icon, color: iconColor ?? Colors.black54, size: 24),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  filled: true,
                  fillColor: Color(0xFFF3F4F6),
                ),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748)),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    // Note: gender, bloodGroup, and district are now handled by dropdowns
    // but we keep the controllers for backward compatibility
    _genderController.dispose();
    _bloodGroupController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
