import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodTipsPage extends StatefulWidget {
  const BloodTipsPage({Key? key}) : super(key: key);

  @override
  State<BloodTipsPage> createState() => _BloodTipsPageState();
}

class _BloodTipsPageState extends State<BloodTipsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Health Guide'),
        backgroundColor: const Color(0xFFFF3838),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blood Group Compatibility Section
            _buildCompatibilitySection(),
            const SizedBox(height: 24),

            // Who Can Donate Section
            _buildDonorEligibilitySection(),
            const SizedBox(height: 24),

            // Pre-Donation Guidelines
            _buildPreDonationSection(),
            const SizedBox(height: 24),

            // Post-Donation Care
            _buildPostDonationSection(),
            const SizedBox(height: 24),

            // Nutrition for Blood Health
            _buildNutritionSection(),
            const SizedBox(height: 24),

            // Blood Facts & Myths
            _buildFactsSection(),
            const SizedBox(height: 24),

            // Emergency Blood Types
            _buildEmergencyTypesSection(),
            const SizedBox(height: 24),

            // Health Benefits of Donating
            _buildBenefitsSection(),
            const SizedBox(height: 24),

            // Donation Process
            _buildDonationProcessSection(),
            const SizedBox(height: 24),

            // Blood Storage & Testing
            _buildBloodStorageSection(),
            const SizedBox(height: 24),

            // Important Links
            // _buildLinksSection(),
            // const SizedBox(height: 24),

            // Contact Information
            _buildContactSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilitySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bloodtype, color: Color(0xFFFF3838), size: 28),
                SizedBox(width: 12),
                Text('Blood Group Compatibility',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Understanding blood compatibility is crucial for safe transfusions. Each blood type can only receive from specific donor types.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFFF3838).withOpacity(0.1),
                ),
                columns: const [
                  DataColumn(
                      label: Text('Recipient',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Can Receive From',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Can Donate To',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('A+',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('A+, A-, O+, O-')),
                    DataCell(Text('A+, AB+')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('A-',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('A-, O-')),
                    DataCell(Text('A+, A-, AB+, AB-')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('B+',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('B+, B-, O+, O-')),
                    DataCell(Text('B+, AB+')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('B-',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('B-, O-')),
                    DataCell(Text('B+, B-, AB+, AB-')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('AB+',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.green))),
                    DataCell(Text('All Blood Types')),
                    DataCell(Text('AB+ Only')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('AB-',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('AB-, A-, B-, O-')),
                    DataCell(Text('AB+, AB-')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('O+',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('O+, O-')),
                    DataCell(Text('A+, B+, AB+, O+')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('O-',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.blue))),
                    DataCell(Text('O- Only')),
                    DataCell(Text('All Blood Types')),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('AB+ Universal Receiver',
                      style: TextStyle(fontSize: 12, color: Colors.green)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('O- Universal Donor',
                      style: TextStyle(fontSize: 12, color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorEligibilitySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.how_to_reg, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Who Can Donate Blood?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Eligibility Criteria:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildEligibilityItem(
                      Icons.cake, 'Age: 18-65 years old', Colors.blue),
                  _buildEligibilityItem(Icons.monitor_weight,
                      'Weight: At least 50 kg (110 lbs)', Colors.green),
                  _buildEligibilityItem(Icons.favorite,
                      'Hemoglobin: At least 12.5 g/dL', Colors.red),
                  _buildEligibilityItem(Icons.health_and_safety,
                      'Good general health', Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Temporary Deferral Periods:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      '• Recent illness: 2-4 weeks after recovery\n• Dental work: 24-72 hours\n• Travel to malaria areas: 3 months\n• Pregnancy/breastfeeding: 6 months after delivery\n• Recent vaccination: 1-4 weeks (varies by vaccine)',
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '⚠️ Always consult with blood bank staff about your specific situation. When in doubt, it\'s better to ask!',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreDonationSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.schedule, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text('Pre-Donation Guidelines',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.restaurant_menu,
              title: 'Eat Well Before Donating',
              content:
                  '• Have a good meal 3-4 hours before donation\n• Include iron-rich foods like spinach, red meat, beans\n• Avoid fatty foods on donation day\n• Eat foods rich in Vitamin C to enhance iron absorption',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.local_drink,
              title: 'Hydration is Key',
              content:
                  '• Drink at least 16-20 oz of water before donation\n• Avoid alcohol 24 hours before donation\n• Avoid caffeine 2-3 hours before donation\n• Continue drinking water after donation',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.bedtime,
              title: 'Rest & Preparation',
              content:
                  '• Get 7-8 hours of sleep the night before\n• Avoid strenuous exercise 24 hours before\n• Bring a valid ID and donor card\n• Wear comfortable clothing with sleeves that roll up easily',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostDonationSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.healing, color: Colors.teal, size: 28),
                SizedBox(width: 12),
                Text('Post-Donation Care',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Immediate Care (First 15 minutes):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      '• Rest and remain seated for 10-15 minutes\n• Apply pressure if bleeding occurs\n• Keep bandage on for 4-6 hours\n• Drink fluids and have a snack'),
                  const SizedBox(height: 16),
                  const Text(
                    'First 24 Hours:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      '• Avoid heavy lifting or strenuous exercise\n• Drink extra fluids (non-alcoholic)\n• Eat iron-rich foods\n• Avoid hot baths or saunas'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warning, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Call your doctor if you experience: Persistent bleeding, severe bruising, dizziness that doesn\'t improve, or arm pain that worsens.',
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.restaurant, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Nutrition for Blood Health',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientCard(
                    'Iron Rich Foods',
                    'Red meat, spinach, beans, lentils, tofu, quinoa, fortified cereals',
                    Icons.fitness_center,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNutrientCard(
                    'Vitamin C Sources',
                    'Oranges, strawberries, bell peppers, broccoli, tomatoes, kiwi',
                    Icons.local_florist,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientCard(
                    'B Vitamins',
                    'Eggs, dairy, leafy greens, nuts, seeds, whole grains',
                    Icons.egg,
                    Colors.yellow.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNutrientCard(
                    'Hydration',
                    'Water, herbal teas, fresh fruit juices (avoid excessive caffeine)',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Text('Blood Facts & Myths',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            _buildFactCard(
              'Amazing Blood Facts',
              '• Your body produces 2 million red blood cells every second\n• Blood makes up about 7% of your body weight\n• One donation can save up to 3 lives\n• It takes 24-48 hours to replenish plasma\n• Red blood cells live for about 120 days',
              Icons.favorite,
              Colors.red,
              isMyth: false,
            ),
            const SizedBox(height: 16),
            _buildFactCard(
              'Common Myths Debunked',
              '❌ "Donation makes you weak" - Your body quickly replenishes donated blood\n❌ "You can get diseases from donating" - All equipment is sterile and single-use\n❌ "Vegetarians can\'t donate" - Diet doesn\'t disqualify you if you meet other criteria\n❌ "You need to wait years between donations" - You can donate every 3-4 months',
              Icons.cancel,
              Colors.orange,
              isMyth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTypesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.emergency, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('Emergency Blood Types',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Most Needed Blood Types:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildEmergencyTypeCard(
                          'O-', 'Universal\nDonor', Colors.blue),
                      const SizedBox(width: 12),
                      _buildEmergencyTypeCard(
                          'O+', 'Most Common\n(37%)', Colors.green),
                      const SizedBox(width: 12),
                      _buildEmergencyTypeCard(
                          'A-', 'Rare\n(6%)', Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '💡 Did you know? O- blood is used in emergencies when there\'s no time to determine the patient\'s blood type. That\'s why O- donors are called "universal donors"!',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.health_and_safety, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text('Health Benefits of Donating',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.green.withOpacity(0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBenefitItem(
                      Icons.monitor_heart,
                      'Cardiovascular Health',
                      'Regular donation may reduce risk of heart disease and help maintain healthy iron levels'),
                  const Divider(),
                  _buildBenefitItem(Icons.psychology, 'Mental Wellbeing',
                      'Studies show donors experience reduced stress and increased life satisfaction'),
                  const Divider(),
                  _buildBenefitItem(
                      Icons.medical_services,
                      'Free Health Screening',
                      'Each donation includes checks for blood pressure, pulse, temperature, and hemoglobin'),
                  const Divider(),
                  _buildBenefitItem(Icons.refresh, 'Cellular Renewal',
                      'Stimulates production of fresh blood cells, potentially improving overall health'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildLinksSection() {
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: const [
  //               Icon(Icons.link, color: Colors.indigo, size: 28),
  //               SizedBox(width: 12),
  //               Text('Helpful Resources',
  //                   style:
  //                       TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           _buildLinkItem(
  //             'WHO Blood Safety Guidelines',
  //             'https://www.who.int/news-room/fact-sheets/detail/blood-safety-and-availability',
  //             Icons.public,
  //           ),
  //           _buildLinkItem(
  //             'Indian Red Cross Society',
  //             'https://indianredcross.org/blood-donation.htm',
  //             Icons.favorite,
  //           ),
  //           _buildLinkItem(
  //             'e-RaktKosh Blood Bank Portal',
  //             'https://www.eraktkosh.in/',
  //             Icons.location_on,
  //           ),
  //           _buildLinkItem(
  //             'National Health Portal - Blood Donation',
  //             'https://www.nhp.gov.in/blood-donation_pg',
  //             Icons.health_and_safety,
  //           ),
  //           _buildLinkItem(
  //             'Blood Donation Guidelines - MoHFW',
  //             'https://main.mohfw.gov.in/Organisation/Departments-of-Health-and-Family-Welfare/National-AIDS-Control-Organization-NACO/Blood-Transfusion',
  //             Icons.article,
  //           ),
  //           _buildLinkItem(
  //             'Find Nearby Blood Banks',
  //             'https://www.bloodbankindia.net/',
  //             Icons.search,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildContactSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF6B6B).withOpacity(0.1),
              const Color(0xFFFF3838).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.contact_support, color: Color(0xFFFF3838), size: 28),
                SizedBox(width: 12),
                Text('Emergency Contacts',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactItem(
                Icons.local_hospital, 'National Blood Helpline', '1910'),
            _buildContactItem(Icons.phone, 'Emergency Services', '102 / 108'),
            _buildContactItem(
                Icons.web, 'e-Raktkosh Portal', 'www.eraktkosh.in'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'In medical emergencies, always call 102/108 or visit the nearest hospital immediately.',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(
      String title, String foods, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(foods, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFactCard(
      String title, String content, IconData icon, Color color,
      {required bool isMyth}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildEmergencyTypeCard(
      String bloodType, String description, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              bloodType,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, String url, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _launchURL(url),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.indigo, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                    ),
                    Text(
                      url,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, color: Colors.indigo, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF3838), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  contact,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFF3838),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
        // Show user-friendly error message
        _showErrorSnackbar(
            'Unable to open this link. Please check your internet connection.');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      _showErrorSnackbar('Error opening link: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDonationProcessSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.timeline, color: Colors.indigo, size: 28),
                SizedBox(width: 12),
                Text('The Donation Process',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            _buildProcessStep(
                1,
                'Registration & Health Screening',
                'Present ID, fill forms, basic health questions (5-10 minutes)',
                Colors.blue),
            _buildProcessStep(
                2,
                'Physical Examination',
                'Blood pressure, pulse, temperature, hemoglobin check (5 minutes)',
                Colors.green),
            _buildProcessStep(3, 'The Donation',
                'Actual blood collection process (8-12 minutes)', Colors.red),
            _buildProcessStep(
                4,
                'Rest & Refreshments',
                'Recovery time with snacks and fluids (10-15 minutes)',
                Colors.orange),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Total Time: 45-60 minutes',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.indigo),
                  ),
                  SizedBox(height: 8),
                  Text(
                      'The actual donation takes only 8-12 minutes. Most time is spent on safety checks and recovery.',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodStorageSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.science, color: Colors.purple, size: 28),
                SizedBox(width: 12),
                Text('Blood Storage & Testing',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.indigo.withOpacity(0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Testing Process:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildTestingItem(Icons.biotech, 'Blood Type & Rh Factor',
                      'ABO and Rh testing'),
                  _buildTestingItem(
                      Icons.shield,
                      'Infectious Disease Screening',
                      'HIV, Hepatitis B & C, Syphilis'),
                  _buildTestingItem(Icons.coronavirus, 'Additional Tests',
                      'HTLV, West Nile Virus (seasonal)'),
                  const SizedBox(height: 16),
                  const Text(
                    'Storage Conditions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStorageCard(
                            'Red Blood Cells', '1-6°C\n35-42 days', Colors.red),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStorageCard(
                            'Platelets', '20-24°C\n5 days', Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStorageCard(
                            'Plasma', '-18°C\n1 year', Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStorageCard(
                            'Whole Blood', '1-6°C\n21 days', Colors.purple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✅ Only blood that passes ALL safety tests is used for transfusions. Your donation is thoroughly screened to ensure patient safety.',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProcessStep(
      int step, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestingItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(String component, String conditions, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            component,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            conditions,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
