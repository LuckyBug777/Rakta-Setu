import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_service.dart';

class EmergencyResponseHandler {
  static Future<void> showEmergencyRequestDialog(
    BuildContext context, 
    Map<String, dynamic> notificationData
  ) async {
    final emergencyRequestId = notificationData['emergencyRequestId'];
    final requesterName = notificationData['requesterName'];
    final bloodGroup = notificationData['bloodGroup'];
    final district = notificationData['district'];
    final requesterPhone = notificationData['requesterPhone'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.red, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'EMERGENCY REQUEST',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'URGENT BLOOD NEEDED',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Patient: $requesterName'),
                  Text('Blood Group: $bloodGroup'),
                  Text('Location: $district'),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Can you help with this emergency blood request?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Your quick response can save a life!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _respondToEmergency(context, emergencyRequestId, requesterPhone, false);
            },
            child: Text(
              'Cannot Help',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _respondToEmergency(context, emergencyRequestId, requesterPhone, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('I CAN HELP!'),
          ),
        ],
      ),
    );
  }

  static Future<void> _respondToEmergency(
    BuildContext context,
    String emergencyRequestId,
    String requesterPhone,
    bool canHelp,
  ) async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();
      
      if (userData == null) {
        _showMessage(context, 'Error: Unable to load your profile', isError: true);
        return;
      }

      final donorPhone = userData['phoneNumber'] ?? '';
      final donorName = userData['name'] ?? '';
      final donorBloodGroup = userData['bloodGroup'] ?? '';

      if (canHelp) {
        // Add donor to responding donors list
        await FirebaseFirestore.instance
            .collection('emergency_requests')
            .doc(emergencyRequestId)
            .update({
          'respondingDonors': FieldValue.arrayUnion([
            {
              'name': donorName,
              'phone': donorPhone,
              'bloodGroup': donorBloodGroup,
              'respondedAt': Timestamp.now(),
              'status': 'available',
            }
          ])
        });

        // Create notification for the requester
        await FirebaseFirestore.instance
            .collection('notifications')
            .add({
          'userPhone': requesterPhone,
          'type': 'emergency_response',
          'title': 'Emergency Donor Found!',
          'message': '$donorName ($donorBloodGroup) is available to help with your emergency blood request. Please contact them immediately.',
          'createdAt': Timestamp.now(),
          'isRead': false,
          'emergencyRequestId': emergencyRequestId,
          'donorPhone': donorPhone,
          'donorName': donorName,
          'donorBloodGroup': donorBloodGroup,
          'urgencyLevel': 'emergency',
        });

        // Create confirmation notification for donor
        await FirebaseFirestore.instance
            .collection('notifications')
            .add({
          'userPhone': donorPhone,
          'type': 'emergency_confirmation',
          'title': 'Emergency Response Confirmed',
          'message': 'Thank you for responding to the emergency! The patient will contact you shortly. Please be ready to donate.',
          'createdAt': Timestamp.now(),
          'isRead': false,
          'emergencyRequestId': emergencyRequestId,
          'requesterPhone': requesterPhone,
        });

        _showMessage(context, 'Thank you! Your response has been sent to the patient.');
        
        // Show contact options
        _showContactOptions(context, requesterPhone);
        
      } else {
        _showMessage(context, 'Thank you for your response. We understand you cannot help at this time.');
      }

    } catch (e) {
      _showMessage(context, 'Error responding to emergency: $e', isError: true);
    }
  }

  static void _showContactOptions(BuildContext context, String requesterPhone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Patient'),
        content: Text('Would you like to contact the patient directly?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final phoneUri = Uri.parse('tel:$requesterPhone');
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              } else {
                _showMessage(context, 'Unable to make phone call', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Call Now'),
          ),
        ],
      ),
    );
  }

  static void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  // Method to check for active emergency requests when app starts
  static Future<void> checkForActiveEmergencyRequests(BuildContext context) async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();
      
      if (userData == null) return;

      final userPhone = userData['phoneNumber'] ?? '';
      final userDistrict = userData['district'] ?? '';
      final userBloodGroup = userData['bloodGroup'] ?? '';

      // Get compatible blood types that this user can donate to
      final compatibleTypes = _getCompatibleRecipients(userBloodGroup);

      // Check for active emergency requests in same district
      final emergencyRequests = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .where('status', isEqualTo: 'active')
          .where('district', isEqualTo: userDistrict)
          .where('bloodGroup', whereIn: compatibleTypes)
          .get();

      for (final doc in emergencyRequests.docs) {
        final data = doc.data();
        if (data['requestedBy'] != userPhone) {
          // Check if user already responded
          final respondingDonors = List<Map<String, dynamic>>.from(
            data['respondingDonors'] ?? []
          );
          
          final alreadyResponded = respondingDonors.any(
            (donor) => donor['phone'] == userPhone
          );

          if (!alreadyResponded) {
            // Show emergency notification
            await showEmergencyRequestDialog(context, {
              'emergencyRequestId': doc.id,
              'requesterName': data['requesterName'],
              'bloodGroup': data['bloodGroup'],
              'district': data['district'],
              'requesterPhone': data['requestedBy'],
            });
            break; // Show only one emergency at a time
          }
        }
      }
    } catch (e) {
      print('Error checking for emergency requests: $e');
    }
  }

  static List<String> _getCompatibleRecipients(String donorBloodGroup) {
    // Define who can receive blood from this donor
    switch (donorBloodGroup) {
      case 'A+':
        return ['A+', 'AB+'];
      case 'A-':
        return ['A+', 'A-', 'AB+', 'AB-'];
      case 'B+':
        return ['B+', 'AB+'];
      case 'B-':
        return ['B+', 'B-', 'AB+', 'AB-'];
      case 'AB+':
        return ['AB+'];
      case 'AB-':
        return ['AB+', 'AB-'];
      case 'O+':
        return ['A+', 'B+', 'AB+', 'O+'];
      case 'O-':
        return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      default:
        return [];
    }
  }
}
