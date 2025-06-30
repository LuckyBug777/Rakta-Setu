// blood_requests_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class BloodRequestsListScreen extends StatefulWidget {
  const BloodRequestsListScreen({Key? key}) : super(key: key);

  @override
  State<BloodRequestsListScreen> createState() =>
      _BloodRequestsListScreenState();
}

class _BloodRequestsListScreenState extends State<BloodRequestsListScreen> {
  List<Map<String, dynamic>> _requests = [];
  String _userBloodGroup = 'A+';
  String _userPhone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndRequests();
  }

  Future<void> _fetchUserDataAndRequests() async {
    final userData = await AuthService().getUserData();
    setState(() {
      _userBloodGroup = userData?['bloodGroup'] ?? 'A+';
      _userPhone = userData?['phoneNumber'] ?? '';
    });
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final query = await FirebaseFirestore.instance
        .collection('blood_requests')
        .where('status', isEqualTo: 'pending')
        .get();
    setState(() {
      _requests = query.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .where((req) => req['requestedBy'] != _userPhone)
          .toList(); // Exclude requests created by the current user
      _isLoading = false;
    });
  }

  bool _isCompatible(String recipientGroup) {
    // Simple compatibility check (expand as needed)
    return recipientGroup == _userBloodGroup;
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient: ${request['patientName'] ?? ''}'),
            Text('Blood Group: ${request['bloodGroup'] ?? ''}'),
            Text('Urgency: ${request['urgency'] ?? ''}'),
            Text('Hospital: ${request['hospital'] ?? ''}'),
            Text('Units: ${request['requiredUnits'] ?? ''}'),
            Text('Location: ${request['address'] ?? ''}'),
            Text('Contact: ${request['contactNumber'] ?? ''}'),
            if ((request['additionalNotes'] ?? '').toString().isNotEmpty)
              Text('Notes: ${request['additionalNotes']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (request['requestedBy'] == _userPhone) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('You cannot accept your own request.')),
                );
                return;
              }
              _showDonorForm(request);
            },
            child: Text('Available'),
          ),
        ],
      ),
    );
  }

  void _showDonorForm(Map<String, dynamic> request) async {
    final _formKey = GlobalKey<FormState>();
    // Fetch donor info from user data for robustness
    final userData = await AuthService().getUserData();
    String donorName = userData?['name'] ?? '';
    String donorBloodGroup = userData?['bloodGroup'] ?? _userBloodGroup;
    String donorPhone = userData?['phoneNumber'] ?? _userPhone;
    String donorLocation = '';
    String donorAge = userData?['age']?.toString() ?? '';
    String donorGender = userData?['gender'] ?? '';
    bool isSubmitting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Submit Donor Details'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: donorName,
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (v) => donorName = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: donorBloodGroup,
                    decoration: InputDecoration(labelText: 'Blood Group'),
                    onChanged: (v) => donorBloodGroup = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: donorPhone,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    onChanged: (v) => donorPhone = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: donorLocation,
                    decoration: InputDecoration(labelText: 'Location/Address'),
                    onChanged: (v) => donorLocation = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: donorAge,
                    decoration: InputDecoration(labelText: 'Age'),
                    onChanged: (v) => donorAge = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: donorGender,
                    decoration: InputDecoration(labelText: 'Gender'),
                    onChanged: (v) => donorGender = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => isSubmitting = true);
                        try {
                          final donorDetails = {
                            'name': donorName,
                            'bloodGroup': donorBloodGroup,
                            'phone': donorPhone,
                            'location': donorLocation,
                            'age': donorAge,
                            'gender': donorGender,
                            'submittedAt': DateTime.now().toIso8601String(),
                          };
                          print('Submitting donor details:');
                          print('Request ID: ${request['id']}');
                          print('Donor details: ${donorDetails.toString()}');
                          await FirebaseFirestore.instance
                              .collection('blood_requests')
                              .doc(request['id'])
                              .update({
                            // Only update donorDetails, do not change status
                            'donorDetails':
                                FieldValue.arrayUnion([donorDetails]),
                          });

                          // Create notification for the requester
                          final requesterNotificationData = {
                            'userPhone': request['requestedBy'],
                            'type': 'donor_response',
                            'title': 'Donor Found!',
                            'message':
                                '$donorName has volunteered to donate ${request['bloodGroup']} blood for your request.',
                            'createdAt': Timestamp.now(),
                            'isRead': false,
                            'relatedRequestId': request['id'],
                          };

                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .add(requesterNotificationData);

                          // Create notification for the donor
                          final donorNotificationData = {
                            'userPhone': donorPhone,
                            'type': 'donation_accepted',
                            'title': 'Request Accepted',
                            'message':
                                'You have successfully volunteered to help with a ${request['bloodGroup']} blood request. The recipient will contact you soon.',
                            'createdAt': Timestamp.now(),
                            'isRead': false,
                            'relatedRequestId': request['id'],
                          };

                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .add(donorNotificationData);
                          Navigator.pop(context);
                          _fetchRequests();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'You have accepted the request! The recipient will see your details.')),
                          );
                        } catch (e) {
                          setState(() => isSubmitting = false);
                          print(
                              'Error submitting donor details: ${e.toString()}');
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to submit details. Please try again.')),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Blood Requests'),
        backgroundColor: const Color(0xFF38A169),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                final compatible = _isCompatible(req['bloodGroup'] ?? '');
                return InkWell(
                  onTap: () => _showRequestDetails(req),
                  borderRadius: BorderRadius.circular(14),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: compatible
                            ? Colors.green.withOpacity(0.5)
                            : Colors.red.withOpacity(0.2),
                        width: compatible ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Blood group circle
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: compatible
                                  ? Colors.green.withOpacity(0.08)
                                  : Colors.red.withOpacity(0.08),
                              border: Border.all(
                                  color: compatible
                                      ? Colors.green
                                      : Colors.red.shade300),
                            ),
                            child: Center(
                              child: Text(
                                req['bloodGroup'] ?? '',
                                style: TextStyle(
                                  color: compatible ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Recipient info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req['patientName'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.local_hospital_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        req['hospital'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.location_on_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        req['address'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      req['urgency'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.opacity,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Units: ${req['requiredUnits'] ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: compatible
                                  ? Colors.green.withOpacity(0.13)
                                  : Colors.red.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              compatible ? 'Compatible' : 'Not Compatible',
                              style: TextStyle(
                                color: compatible ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
