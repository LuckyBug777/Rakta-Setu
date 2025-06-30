import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class DonationHistoryPage extends StatefulWidget {
  final AuthService? authService;

  const DonationHistoryPage({Key? key, this.authService}) : super(key: key);

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  List<Map<String, dynamic>> _donationHistory = [];
  bool _isLoading = true;
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadDonationHistory();
  }

  Future<void> _loadDonationHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Get user phone number
      if (widget.authService != null) {
        final userData = await widget.authService!.getUserData();
        _userPhone = userData?['phoneNumber'] ?? '';
        print('🔍 Loading donations for phone: $_userPhone');
        print('🔍 User data: $userData');
      }

      if (_userPhone.isNotEmpty) {
        // Fetch donation history from Firestore (without orderBy to avoid index requirement)
        print('🔍 Querying Firestore for donations...');
        final querySnapshot = await FirebaseFirestore.instance
            .collection('donations')
            .where('donorPhone', isEqualTo: _userPhone)
            .get();

        print('🔍 Found ${querySnapshot.docs.length} donation records');
        for (var doc in querySnapshot.docs) {
          print('🔍 Donation doc: ${doc.id} -> ${doc.data()}');
        }

        // Convert to list and sort locally
        List<Map<String, dynamic>> donations = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();

        // Sort by donation date locally (newest first)
        donations.sort((a, b) {
          final dateA = a['donationDate'] as Timestamp?;
          final dateB = b['donationDate'] as Timestamp?;

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;

          return dateB.compareTo(dateA); // Descending order (newest first)
        });

        setState(() {
          _donationHistory = donations;
        });

        print('🔍 Loaded ${_donationHistory.length} donations into local list');
      } else {
        print('❌ No phone number found, cannot load donations');
      }
    } catch (e) {
      print('Error loading donation history: $e');
      // Show empty state instead of sample data
      setState(() {
        _donationHistory = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return 'Invalid date';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddDonationDialog() async {
    // Get user data first to auto-populate fields
    final userData = await widget.authService?.getUserData();
    final userBloodGroup = userData?['bloodGroup'] ?? 'A+';
    final userName = userData?['name'] ?? 'User';

    final TextEditingController recipientController = TextEditingController();
    final TextEditingController hospitalController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int units = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add Donation Record',
                style: TextStyle(
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info display for auto-populated fields
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3838).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF3838).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Color(0xFFFF3838), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Your Details (Auto-filled)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Donor: $userName',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            'Blood Group: $userBloodGroup',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recipient Name
                    TextField(
                      controller: recipientController,
                      decoration: InputDecoration(
                        labelText: 'Recipient / Blood Bank Name',
                        hintText: 'e.g. Emergency Patient, Blood Bank Reserve',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFFF3838)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hospital
                    TextField(
                      controller: hospitalController,
                      decoration: InputDecoration(
                        labelText: 'Hospital / Blood Bank',
                        hintText: 'e.g. City General Hospital',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFFF3838)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Color(0xFFFF3838)),
                            const SizedBox(width: 12),
                            Text(
                              'Donation Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Units
                    Row(
                      children: [
                        const Text('Units Donated: ',
                            style: TextStyle(fontSize: 16)),
                        const Spacer(),
                        IconButton(
                          onPressed: units > 1
                              ? () {
                                  setDialogState(() {
                                    units--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Text('$units',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              units++;
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFFF3838)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (recipientController.text.isNotEmpty &&
                        hospitalController.text.isNotEmpty) {
                      await _addDonationRecord(
                        recipientName: recipientController.text,
                        bloodGroup:
                            userBloodGroup, // Use auto-populated blood group
                        hospital: hospitalController.text,
                        donationDate: selectedDate,
                        units: units,
                        notes: notesController.text,
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3838),
                  ),
                  child: const Text('Add Donation',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addDonationRecord({
    required String recipientName,
    required String bloodGroup,
    required String hospital,
    required DateTime donationDate,
    required int units,
    required String notes,
  }) async {
    try {
      final userData = await widget.authService?.getUserData();
      final userPhone = userData?['phoneNumber'] ?? '';
      final donorName = userData?['name'] ?? 'User';

      print('💾 Saving donation for phone: $userPhone');
      print('💾 User data: $userData');

      // Create donation record with donor info from profile
      final donationData = {
        'donorPhone': userPhone,
        'donorName': donorName, // Added donor name from profile
        'recipientName': recipientName,
        'bloodGroup': bloodGroup,
        'hospital': hospital,
        'donationDate': Timestamp.fromDate(donationDate),
        'units': units,
        'notes': notes,
        'status': 'completed',
        'createdAt': Timestamp.now(),
      };

      print('💾 Donation data to save: $donationData');

      // Add to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('donations')
          .add(donationData);

      print(
          '💾 Saved donation with ID: ${docRef.id}'); // Create notification for 3 days before 120 days (117 days after donation)
      final reminderDate = donationDate.add(const Duration(days: 117));
      final reminderNotificationData = {
        'userPhone': userPhone,
        'type': 'donation_reminder',
        'title': 'Ready to Donate Again Soon!',
        'message':
            'You\'ll be eligible to donate blood again in 3 days (${_formatDate(donationDate.add(const Duration(days: 120)))}). Start preparing for your next donation!',
        'createdAt': Timestamp.fromDate(reminderDate),
        'isRead': false,
        'scheduledFor': Timestamp.fromDate(reminderDate),
        'eligibleDate':
            Timestamp.fromDate(donationDate.add(const Duration(days: 120))),
      };

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(reminderNotificationData);

      // Create notification for exactly 120 days (eligibility day)
      final eligibilityDate = donationDate.add(const Duration(days: 120));
      final eligibilityNotificationData = {
        'userPhone': userPhone,
        'type': 'donation_reminder',
        'title': 'Ready to Donate Again!',
        'message':
            'It\'s been 120 days since your last donation. You can donate blood again now!',
        'createdAt': Timestamp.fromDate(eligibilityDate),
        'isRead': false,
        'scheduledFor': Timestamp.fromDate(eligibilityDate),
      };

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(eligibilityNotificationData);

      // Create immediate notification for successful donation record
      final immediateNotificationData = {
        'userPhone': userPhone,
        'type': 'donation_success',
        'title': 'Donation Record Added!',
        'message':
            'Thank you for donating blood! Your donation of $units unit${units > 1 ? 's' : ''} of $bloodGroup blood has been recorded.',
        'createdAt': Timestamp.now(),
        'isRead': false,
        'relatedDonationId': docRef.id,
      };

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(immediateNotificationData);

      // Add to local list
      setState(() {
        _donationHistory.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          ...donationData,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation record added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error adding donation record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add donation record'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Donation History',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFFF3838)),
            onPressed: _showAddDonationDialog,
            tooltip: 'Add Donation',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF3838)),
            onPressed: _loadDonationHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3838)),
              ),
            )
          : _donationHistory.isEmpty
              ? _buildEmptyState()
              : _buildDonationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bloodtype_outlined,
                size: 60,
                color: Color(0xFFFF3838),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Donations Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your donation history will appear here once you start donating blood.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showAddDonationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3838),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Donation',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF3838),
                      side: const BorderSide(color: Color(0xFFFF3838)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationList() {
    return RefreshIndicator(
      onRefresh: _loadDonationHistory,
      color: const Color(0xFFFF3838),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _donationHistory.length,
        itemBuilder: (context, index) {
          final donation = _donationHistory[index];
          return _buildDonationCard(donation);
        },
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with blood group and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3838),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          donation['bloodGroup'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation['recipientName'] ?? 'Unknown Recipient',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          _formatDate(donation['donationDate']),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(donation['status'] ?? 'completed')
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (donation['status'] ?? 'completed').toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(donation['status'] ?? 'completed'),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hospital and units info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_hospital,
                          color: Color(0xFFFF3838), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          donation['hospital'] ?? 'Unknown Hospital',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.water_drop,
                          color: Color(0xFFFF3838), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${donation['units'] ?? 1} Unit${(donation['units'] ?? 1) > 1 ? 's' : ''} Donated',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notes if available
            if (donation['notes'] != null && donation['notes'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      donation['notes'],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
