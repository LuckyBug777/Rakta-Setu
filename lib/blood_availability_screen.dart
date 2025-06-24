import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodAvailabilityScreen extends StatefulWidget {
  const BloodAvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<BloodAvailabilityScreen> createState() =>
      _BloodAvailabilityScreenState();
}

class _BloodAvailabilityScreenState extends State<BloodAvailabilityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  String _selectedBloodGroup = 'All';
  bool _isLoading = true;
  String _userDistrict = 'Mumbai'; // Default district
  List<Map<String, dynamic>> _bloodBanks = [];
  List<Map<String, dynamic>> _nearbyDonors = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchBloodBanksAndDonors();
  }

  Future<void> _fetchUserData() async {
    try {
      // Get current user ID from FirebaseAuth
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (user.exists) {
        setState(() {
          _userDistrict = user.data()?['district'] ?? 'Unknown';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _userDistrict = 'Unknown';
      });
    }
  }

  Future<void> _fetchBloodBanksAndDonors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch blood banks from Firestore
      final bloodBanksSnapshot =
          await _firestore.collection('bloodBanks').get();
      List<Map<String, dynamic>> bloodBanks = [];

      for (var doc in bloodBanksSnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        bloodBanks.add(data);
      }

      // Fetch donors from Firestore
      final donorsSnapshot = await _firestore.collection('donors').get();
      List<Map<String, dynamic>> nearbyDonors = [];

      for (var doc in donorsSnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        nearbyDonors.add(data);
      }

      // Sort blood banks by district match first
      bloodBanks.sort((a, b) {
        // District match has priority
        if (a['district'] == _userDistrict && b['district'] != _userDistrict) {
          return -1;
        } else if (a['district'] != _userDistrict &&
            b['district'] == _userDistrict) {
          return 1;
        }

        // Then sort by name
        return (a['name'] as String).compareTo(b['name'] as String);
      });

      // Sort donors by last donation date
      nearbyDonors.sort((a, b) {
        String aLastDonation = a['lastDonation'] ?? '0 days ago';
        String bLastDonation = b['lastDonation'] ?? '0 days ago';

        // Extract number of days
        int aDays = int.tryParse(aLastDonation.split(' ')[0]) ?? 0;
        int bDays = int.tryParse(bLastDonation.split(' ')[0]) ?? 0;

        return bDays.compareTo(aDays); // Sort by most recent donation
      });

      setState(() {
        _bloodBanks = bloodBanks;
        _nearbyDonors = nearbyDonors;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredBloodBanks() {
    if (_selectedBloodGroup == 'All') {
      return _bloodBanks
          .where((bank) => bank['district'] == _userDistrict)
          .toList();
    }

    return _bloodBanks.where((bank) {
      final availability =
          bank['bloodAvailability'][_selectedBloodGroup] as int;
      return bank['district'] == _userDistrict && availability > 0;
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredDonors() {
    if (_selectedBloodGroup == 'All') {
      return _nearbyDonors;
    }

    return _nearbyDonors
        .where((donor) => donor['bloodGroup'] == _selectedBloodGroup)
        .toList();
  }

  Color _getAvailabilityColor(int units) {
    if (units < 3) {
      return Colors.red;
    } else if (units < 7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBloodBanks = _getFilteredBloodBanks();
    final nearbyDonors = _getFilteredDonors();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Availability'),
        backgroundColor: const Color(0xFFFF3838),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBloodBanksAndDonors,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3838)),
              ),
            )
          : Column(
              children: [
                // Blood group filter
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by Blood Group',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _bloodGroups
                              .map(
                                (group) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(group),
                                    selected: _selectedBloodGroup == group,
                                    selectedColor: const Color(0xFFFF3838)
                                        .withOpacity(0.8),
                                    labelStyle: TextStyle(
                                      color: _selectedBloodGroup == group
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: _selectedBloodGroup == group
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedBloodGroup = group;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Results
                Expanded(
                  child: filteredBloodBanks.isEmpty && nearbyDonors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bloodtype_outlined,
                                color: Colors.grey,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No ${_selectedBloodGroup} blood available in $_userDistrict',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedBloodGroup = 'All';
                                  });
                                },
                                child: const Text('Show all blood groups'),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Nearby donors within 10km
                            if (nearbyDonors.isNotEmpty) ...[
                              const Text(
                                'Available Blood Donors',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...nearbyDonors
                                  .map((donor) => Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // Blood group circle
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red
                                                      .withOpacity(0.1),
                                                  border: Border.all(
                                                      color:
                                                          Colors.red.shade300),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    donor['bloodGroup']
                                                        as String,
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              // Donor info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      donor['name'] as String,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Icon(
                                                          Icons
                                                              .calendar_today_outlined,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          donor['lastDonation'],
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Call button
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.call,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () {
                                                  // In a real app, this would call the donor
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Calling ${donor['name']}...'),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              const SizedBox(height: 24),
                            ],

                            // Blood banks
                            if (filteredBloodBanks.isNotEmpty) ...[
                              const Text(
                                'Blood Banks',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...filteredBloodBanks
                                  .map((bank) => Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Blood bank name and district
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    bank['name'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        bank['district']
                                                            as String,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Blood availability
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Blood Availability',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  GridView.count(
                                                    crossAxisCount: 4,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    childAspectRatio: 1.5,
                                                    mainAxisSpacing: 8,
                                                    crossAxisSpacing: 8,
                                                    children:
                                                        (bank['bloodAvailability']
                                                                as Map<String,
                                                                    dynamic>)
                                                            .entries
                                                            .map(
                                                                (entry) =>
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: _getAvailabilityColor(entry.value)
                                                                            .withOpacity(0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              _getAvailabilityColor(entry.value),
                                                                          width:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            entry.key,
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: _getAvailabilityColor(entry.value),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 4),
                                                                          Text(
                                                                            '${entry.value} units',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: _getAvailabilityColor(entry.value),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ))
                                                            .toList(),
                                                  ),

                                                  // Contact info
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              bank['address']
                                                                  as String,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              bank['contact']
                                                                  as String,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      ElevatedButton.icon(
                                                        icon: const Icon(
                                                            Icons.call,
                                                            size: 16),
                                                        label:
                                                            const Text('Call'),
                                                        onPressed: () {
                                                          // In a real app, this would call the blood bank
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Calling ${bank['name']}...'),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFFFF3838),
                                                          foregroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
