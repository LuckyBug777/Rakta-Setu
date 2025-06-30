import 'package:cloud_firestore/cloud_firestore.dart';

class BloodDonorDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Future<void> seedSampleDonors() async {
    final sampleDonors = [
      {
        'name': 'Rahul Sharma',
        'bloodGroup': 'O+',
        'district': 'Bengaluru',
        'lastDonation': '45 days ago',
        'phone': '+91 9876543210',
        'age': 28,
        'available': true,
      },
      {
        'name': 'Priya Patel',
        'bloodGroup': 'A+',
        'district': 'Bengaluru',
        'lastDonation': '60 days ago',
        'phone': '+91 9876543211',
        'age': 32,
        'available': true,
      },
      {
        'name': 'Amit Kumar',
        'bloodGroup': 'B+',
        'district': 'Mysuru',
        'lastDonation': '30 days ago',
        'phone': '+91 9876543212',
        'age': 26,
        'available': true,
      },
      {
        'name': 'Sneha Reddy',
        'bloodGroup': 'AB+',
        'district': 'Bengaluru',
        'lastDonation': '90 days ago',
        'phone': '+91 9876543213',
        'age': 29,
        'available': true,
      },
      {
        'name': 'Vikram Singh',
        'bloodGroup': 'O-',
        'district': 'Hubli',
        'lastDonation': '120 days ago',
        'phone': '+91 9876543214',
        'age': 35,
        'available': true,
      },
      {
        'name': 'Anita Joshi',
        'bloodGroup': 'A-',
        'district': 'Bengaluru',
        'lastDonation': '75 days ago',
        'phone': '+91 9876543215',
        'age': 31,
        'available': true,
      },
      {
        'name': 'Suresh Gupta',
        'bloodGroup': 'B-',
        'district': 'Mangaluru',
        'lastDonation': '50 days ago',
        'phone': '+91 9876543216',
        'age': 40,
        'available': true,
      },
      {
        'name': 'Deepika Mehta',
        'bloodGroup': 'AB-',
        'district': 'Bengaluru',
        'lastDonation': '100 days ago',
        'phone': '+91 9876543217',
        'age': 27,
        'available': true,
      },
      {
        'name': 'Rajesh Kumar',
        'bloodGroup': 'O+',
        'district': 'Mysuru',
        'lastDonation': '35 days ago',
        'phone': '+91 9876543218',
        'age': 33,
        'available': true,
      },
      {
        'name': 'Kavitha Rao',
        'bloodGroup': 'A+',
        'district': 'Hubli',
        'lastDonation': '80 days ago',
        'phone': '+91 9876543219',
        'age': 28,
        'available': true,
      },
    ];
    try {
      // Delete existing Mumbai-based data and add Karnataka data
      final existingDonors = await _firestore.collection('donors').get();

      // Check if we have Mumbai data that needs to be replaced
      bool hasMumbaiData = existingDonors.docs.any((doc) =>
          (doc.data() as Map<String, dynamic>)['district'] == 'Mumbai');

      if (existingDonors.docs.isEmpty || hasMumbaiData) {
        // Delete all existing donors
        for (final doc in existingDonors.docs) {
          await doc.reference.delete();
        }

        // Add Karnataka-based sample donors
        for (final donor in sampleDonors) {
          await _firestore.collection('donors').add(donor);
        }
        print('Karnataka sample donors added successfully!');
      } else {
        print('Donors collection already has Karnataka data.');
      }
    } catch (e) {
      print('Error seeding sample donors: $e');
    }
  }

  static Future<void> seedSampleBloodBanks() async {
    final sampleBloodBanks = [
      {
        'name': 'Bengaluru Central Blood Bank',
        'district': 'Bengaluru',
        'address': 'MG Road, Bengaluru - 560001',
        'contact': '+91 80 2345 6789',
        'bloodAvailability': {
          'A+': 15,
          'A-': 5,
          'B+': 12,
          'B-': 3,
          'AB+': 8,
          'AB-': 2,
          'O+': 20,
          'O-': 7,
        },
      },
      {
        'name': 'Victoria Hospital Blood Bank',
        'district': 'Bengaluru',
        'address': 'Fort, Bengaluru - 560002',
        'contact': '+91 80 2345 6790',
        'bloodAvailability': {
          'A+': 10,
          'A-': 3,
          'B+': 8,
          'B-': 2,
          'AB+': 5,
          'AB-': 1,
          'O+': 18,
          'O-': 4,
        },
      },
      {
        'name': 'JSS Hospital Blood Bank',
        'district': 'Mysuru',
        'address': 'SS Nagar, Mysuru - 570015',
        'contact': '+91 821 2345 6791',
        'bloodAvailability': {
          'A+': 12,
          'A-': 4,
          'B+': 10,
          'B-': 3,
          'AB+': 6,
          'AB-': 2,
          'O+': 16,
          'O-': 5,
        },
      },
      {
        'name': 'KIMS Hospital Blood Bank',
        'district': 'Hubli',
        'address': 'Vidyanagar, Hubli - 580021',
        'contact': '+91 836 2345 6792',
        'bloodAvailability': {
          'A+': 8,
          'A-': 2,
          'B+': 6,
          'B-': 1,
          'AB+': 4,
          'AB-': 1,
          'O+': 14,
          'O-': 3,
        },
      },
    ];
    try {
      // Delete existing Mumbai-based data and add Karnataka data
      final existingBanks = await _firestore.collection('bloodBanks').get();

      // Check if we have Mumbai data that needs to be replaced
      bool hasMumbaiData = existingBanks.docs.any((doc) =>
          (doc.data() as Map<String, dynamic>)['district'] == 'Mumbai');

      if (existingBanks.docs.isEmpty || hasMumbaiData) {
        // Delete all existing blood banks
        for (final doc in existingBanks.docs) {
          await doc.reference.delete();
        }

        // Add Karnataka-based sample blood banks
        for (final bank in sampleBloodBanks) {
          await _firestore.collection('bloodBanks').add(bank);
        }
        print('Karnataka sample blood banks added successfully!');
      } else {
        print('Blood banks collection already has Karnataka data.');
      }
    } catch (e) {
      print('Error seeding sample blood banks: $e');
    }
  }
}
