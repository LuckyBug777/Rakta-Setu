import 'package:flutter/material.dart';
import 'utils/responsive_dimensions.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({Key? key}) : super(key: key);

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedBloodGroup = 'A+';
  String _selectedUrgency = 'Normal';
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientAgeController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _requiredUnitsController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _additionalNotesController =
      TextEditingController();
  bool _isEmergency = false;

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
  final List<String> _urgencyLevels = ['Normal', 'Urgent', 'Critical'];

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _hospitalController.dispose();
    _requiredUnitsController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveDimensions.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood'),
        backgroundColor: const Color(0xFFFF3838),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3838),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Blood Request Form',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please fill in the details to request blood',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Emergency toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isEmergency
                          ? Colors.red[800]
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Mode',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isEmergency
                                  ? 'Active - Will notify nearby donors'
                                  : 'Inactive - Standard request',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isEmergency,
                          onChanged: (value) {
                            setState(() {
                              _isEmergency = value;
                              if (value) {
                                _selectedUrgency = 'Critical';
                              }
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.red[800],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patient Name
                    TextFormField(
                      controller: _patientNameController,
                      decoration: InputDecoration(
                        labelText: 'Patient Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Patient Age & Blood Group (Row)
                    Row(
                      children: [
                        // Patient Age
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _patientAgeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon:
                                  const Icon(Icons.calendar_today_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid age';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Blood Group Dropdown
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedBloodGroup,
                            decoration: InputDecoration(
                              labelText: 'Blood Group',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.water_drop_outlined),
                            ),
                            items: _bloodGroups.map((String group) {
                              return DropdownMenuItem<String>(
                                value: group,
                                child: Text(group),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedBloodGroup = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Hospital/Clinic
                    TextFormField(
                      controller: _hospitalController,
                      decoration: InputDecoration(
                        labelText: 'Hospital/Clinic Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hospital name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Units & Urgency (Row)
                    Row(
                      children: [
                        // Required Units
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _requiredUnitsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Units Required',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.bloodtype_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid units';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Urgency Dropdown
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedUrgency,
                            decoration: InputDecoration(
                              labelText: 'Urgency',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon:
                                  const Icon(Icons.priority_high_outlined),
                            ),
                            items: _urgencyLevels.map((String level) {
                              return DropdownMenuItem<String>(
                                value: level,
                                child: Text(level),
                              );
                            }).toList(),
                            onChanged: _isEmergency
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _selectedUrgency = newValue!;
                                    });
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact Number
                    TextFormField(
                      controller: _contactNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Hospital Address
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Hospital Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hospital address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Additional Notes
                    TextFormField(
                      controller: _additionalNotesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.note_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _showRequestConfirmation(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3838),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _isEmergency
                              ? 'SUBMIT EMERGENCY REQUEST'
                              : 'SUBMIT REQUEST',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _isEmergency ? 'Confirm Emergency Request' : 'Confirm Request',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You are about to submit a request for ${_requiredUnitsController.text} units of $_selectedBloodGroup blood with $_selectedUrgency urgency.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (_isEmergency)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This will notify nearby donors immediately about your emergency.',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitRequest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3838),
              ),
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );
  }

  void _submitRequest() {
    // This would normally connect to a backend service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEmergency
              ? 'Emergency blood request submitted! Nearby donors are being notified.'
              : 'Blood request submitted successfully!',
        ),
        backgroundColor: _isEmergency ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );

    // Reset form after successful submission
    _formKey.currentState!.reset();
    _patientNameController.clear();
    _patientAgeController.clear();
    _hospitalController.clear();
    _requiredUnitsController.clear();
    _contactNumberController.clear();
    _addressController.clear();
    _additionalNotesController.clear();

    setState(() {
      _selectedBloodGroup = 'A+';
      _selectedUrgency = 'Normal';
      _isEmergency = false;
    });
  }
}
