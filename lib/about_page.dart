import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect if dark theme is active
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text('About Rakta Setu'),
        backgroundColor: const Color(0xFFFF3838),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3838).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/images/rakta_setu_logo.png',
                      height: 80,
                      width: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Rakta Setu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF3838),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bridging Lives Through Blood',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // About the App
            Text(
              'About the App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: Text(
                'Rakta Setu is a comprehensive blood donation and request platform designed to save lives by connecting blood donors with those in need. Our mission is to create a seamless, efficient, and reliable network that ensures no life is lost due to blood shortage.\n\n'
                'Features:\n'
                '• Quick blood requests and donations\n'
                '• Real-time blood availability tracking\n'
                '• Emergency mode for urgent requests\n'
                '• Location-based donor matching\n'
                '• Secure user profiles and data management\n'
                '• Health tips and blood compatibility guide',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color:
                      isDarkMode ? Colors.grey[300] : const Color(0xFF4A5568),
                ),
              ),
            ),

            // const SizedBox(height: 40), // About Developers
            // Text(
            //   'About the Developers',
            //   style: TextStyle(
            //     fontSize: 22,
            //     fontWeight: FontWeight.bold,
            //     color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
            //   ),
            // ),
            // const SizedBox(height: 16),
            // Container(
            //   padding: const EdgeInsets.all(25),
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         Color(0xFF667eea),
            //         Color(0xFF764ba2),
            //         Color(0xFF6B73FF),
            //       ],
            //       stops: [0.0, 0.5, 1.0],
            //     ),
            //     borderRadius: BorderRadius.circular(20),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Color(0xFF667eea).withOpacity(0.3),
            //         blurRadius: 15,
            //         offset: Offset(0, 8),
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: [
            //           Container(
            //             padding: const EdgeInsets.all(12),
            //             decoration: BoxDecoration(
            //               gradient: LinearGradient(
            //                 colors: [
            //                   Colors.white,
            //                   Colors.grey[50]!,
            //                 ],
            //               ),
            //               borderRadius: BorderRadius.circular(15),
            //               boxShadow: [
            //                 BoxShadow(
            //                   color: Colors.black.withOpacity(0.1),
            //                   blurRadius: 8,
            //                   offset: Offset(0, 4),
            //                 ),
            //               ],
            //             ),
            //             child: Image.asset(
            //               'assets/images/pro.png',
            //               height: 35,
            //               width: 35,
            //             ),
            //           ),
            //           const SizedBox(width: 16),
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 const Text(
            //                   'Projectory Solutions',
            //                   style: TextStyle(
            //                     fontSize: 22,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.white,
            //                     letterSpacing: 0.5,
            //                   ),
            //                 ),
            //                 const SizedBox(height: 4),
            //                 Container(
            //                   padding: const EdgeInsets.symmetric(
            //                     horizontal: 12,
            //                     vertical: 4,
            //                   ),
            //                   decoration: BoxDecoration(
            //                     color: Colors.white.withOpacity(0.2),
            //                     borderRadius: BorderRadius.circular(20),
            //                   ),
            //                   child: const Text(
            //                     'Innovation • Quality • Excellence',
            //                     style: TextStyle(
            //                       fontSize: 12,
            //                       color: Colors.white,
            //                       fontWeight: FontWeight.w500,
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 20),
            //       Container(
            //         padding: const EdgeInsets.all(20),
            //         decoration: BoxDecoration(
            //           color: Colors.white.withOpacity(0.1),
            //           borderRadius: BorderRadius.circular(15),
            //           border: Border.all(
            //             color: Colors.white.withOpacity(0.2),
            //             width: 1,
            //           ),
            //         ),
            //         child: const Text(
            //           'We are a passionate team of developers dedicated to creating innovative solutions that make a positive impact on society. Our expertise spans mobile app development, web solutions, and digital transformation.',
            //           style: TextStyle(
            //             fontSize: 16,
            //             color: Colors.white,
            //             height: 1.6,
            //             fontWeight: FontWeight.w400,
            //           ),
            //         ),
            //       ),
            //       const SizedBox(height: 25),
            //       Row(
            //         children: [
            //           Expanded(
            //             child: GestureDetector(
            //               onTap: () =>
            //                   _launchURL('https://projectorysolutions.com'),
            //               child: Container(
            //                 padding: const EdgeInsets.symmetric(
            //                     vertical: 16, horizontal: 20),
            //                 decoration: BoxDecoration(
            //                   gradient: LinearGradient(
            //                     colors: [
            //                       Colors.white,
            //                       Colors.grey[50]!,
            //                     ],
            //                   ),
            //                   borderRadius: BorderRadius.circular(15),
            //                   boxShadow: [
            //                     BoxShadow(
            //                       color: Colors.black.withOpacity(0.1),
            //                       blurRadius: 10,
            //                       offset: Offset(0, 5),
            //                     ),
            //                   ],
            //                 ),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: [
            //                     Container(
            //                       padding: const EdgeInsets.all(8),
            //                       decoration: BoxDecoration(
            //                         color: Color(0xFF667eea).withOpacity(0.1),
            //                         borderRadius: BorderRadius.circular(8),
            //                       ),
            //                       child: const Icon(
            //                         Icons.language,
            //                         color: Color(0xFF667eea),
            //                         size: 20,
            //                       ),
            //                     ),
            //                     const SizedBox(width: 10),
            //                     const Flexible(
            //                       child: Text(
            //                         'Visit Website',
            //                         style: TextStyle(
            //                           color: Color(0xFF667eea),
            //                           fontWeight: FontWeight.bold,
            //                           fontSize: 15,
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //           const SizedBox(width: 15),
            //           Expanded(
            //             child: GestureDetector(
            //               onTap: () => _launchURL('tel:8105287105'),
            //               child: Container(
            //                 padding: const EdgeInsets.symmetric(
            //                     vertical: 16, horizontal: 20),
            //                 decoration: BoxDecoration(
            //                   gradient: LinearGradient(
            //                     colors: [
            //                       Colors.white,
            //                       Colors.grey[50]!,
            //                     ],
            //                   ),
            //                   borderRadius: BorderRadius.circular(15),
            //                   boxShadow: [
            //                     BoxShadow(
            //                       color: Colors.black.withOpacity(0.1),
            //                       blurRadius: 10,
            //                       offset: Offset(0, 5),
            //                     ),
            //                   ],
            //                 ),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: [
            //                     Container(
            //                       padding: const EdgeInsets.all(8),
            //                       decoration: BoxDecoration(
            //                         color: Color(0xFF764ba2).withOpacity(0.1),
            //                         borderRadius: BorderRadius.circular(8),
            //                       ),
            //                       child: const Icon(
            //                         Icons.phone,
            //                         color: Color(0xFF764ba2),
            //                         size: 20,
            //                       ),
            //                     ),
            //                     const SizedBox(width: 10),
            //                     const Flexible(
            //                       child: Text(
            //                         'Call Us',
            //                         style: TextStyle(
            //                           color: Color(0xFF764ba2),
            //                           fontWeight: FontWeight.bold,
            //                           fontSize: 15,
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 40), // Contact & Support
            Text(
              'Contact & Support',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.blue[200]!,
                ),
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'raktasetu@gmail.com',
                    onTap: () => _launchURL('mailto:raktasetu@gmail.com'),
                    isDarkMode: isDarkMode,
                  ),
                  const Divider(height: 30),
                  _buildContactItem(
                    icon: Icons.bug_report,
                    title: 'Report Issues',
                    subtitle: 'Help us improve the app',
                    onTap: () => _launchURL(
                        'mailto:raktasetu@gmail.com?subject=Rakta%20Setu%20Issue%20Report'),
                    isDarkMode: isDarkMode,
                  ),
                  const Divider(height: 30),
                  _buildContactItem(
                    icon: Icons.star,
                    title: 'Rate the App',
                    subtitle: 'Share your feedback',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for your support!'),
                          backgroundColor: Color(0xFFFF3838),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // App Version
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF4A5568),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2025 Rakta Setu',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }
}
