import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class AcceptedDonorsPage extends StatelessWidget {
  const AcceptedDonorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Donors'),
        backgroundColor: Color(0xFFFF3838),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAcceptedDonors(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final donors = snapshot.data ?? [];
          if (donors.isEmpty) {
            return const Center(
                child: Text('No donors have accepted your requests yet.'));
          }
          return ListView.builder(
            itemCount: donors.length,
            itemBuilder: (context, index) {
              final donor = donors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF38A169)),
                  title: Text(donor['name'] ?? 'Donor'),
                  subtitle: Text(
                      'Blood Group: ${donor['bloodGroup'] ?? ''}\nPhone: ${donor['phone'] ?? ''}'),
                  onTap: () => _showDonorDetails(context, donor),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAcceptedDonors(
      BuildContext context) async {
    final authService =
        (context.findAncestorWidgetOfExactType<HomeScreen>() as HomeScreen)
            .authService;
    final userData = await authService.getUserData();
    final phone = userData != null ? userData['phoneNumber'] ?? '' : '';
    final query = await FirebaseFirestore.instance
        .collection('blood_requests')
        .where('requestedBy', isEqualTo: phone)
        .get();
    List<Map<String, dynamic>> donors = [];
    for (var doc in query.docs) {
      final donorDetails = (doc['donorDetails'] ?? []) as List;
      for (var donor in donorDetails) {
        donors.add(Map<String, dynamic>.from(donor));
      }
    }
    return donors;
  }

  void _showDonorDetails(BuildContext context, Map<String, dynamic> donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donor Submission Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${donor['name'] ?? ''}'),
            Text('Blood Group: ${donor['bloodGroup'] ?? ''}'),
            Text('Phone: ${donor['phone'] ?? ''}'),
            Text('Location: ${donor['location'] ?? ''}'),
            Text('Age: ${donor['age'] ?? ''}'),
            Text('Gender: ${donor['gender'] ?? ''}'),
            if (donor['submittedAt'] != null)
              Text('Submitted At: ${donor['submittedAt'].toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
