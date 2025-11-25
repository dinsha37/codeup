import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color _primaryBlue = Colors.blue;
const Color _goldenYellow = Color(0xFFDAA520); // A nice golden yellow
const Color _lightGrey = Color(0xFFF5F5F5);
const Color _darkGreyText = Color(0xFF333333);

const TextStyle _headerTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Colors.grey,
  letterSpacing: 0.8,
);

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        // Using an actual back button for navigation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Navigator.pop(context); // Actual navigation back
          },
        ),
        title: const Text(
          'Certificates',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // --- Featured Certificate Card ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: _goldenYellow, width: 3.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events, // Trophy icon for certificate
                      color: _goldenYellow,
                      size: 60,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'MASTER CODER ACHIEVER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _darkGreyText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Certificate of Completion',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Text(
                      'Awarded to',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Text(
                      'Alex Johnson',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'for successfully completing 100+ Advanced\nCoding Challenges',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const Text(
                      'Issued: July 20, 2024',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle download certificate
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading Certificate...'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _goldenYellow,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Download Certificate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Earned Certificates Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('EARNED CERTIFICATES', style: _headerTextStyle),
            ),
            const SizedBox(height: 10),

            // --- List of Earned Certificates ---
            _buildCertificateListItem(
              context,
              icon: Icons.code, // Python
              title: 'Python Fundamentals',
              issueDate: 'July 20, 2024',
            ),
            _buildCertificateListItem(
              context,
              icon: Icons.javascript, // JavaScript
              title: 'JavaScript Algorithms',
              issueDate: 'June 15, 2024',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String issueDate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryBlue),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _darkGreyText,
            ),
          ),
          subtitle: Text(
            'Issued: $issueDate',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.download, color: _primaryBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading "$title" Certificate...')),
              );
            },
          ),
          onTap: () {
            // Example navigation to a detail screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Viewing "$title" Certificate...')),
            );
          },
        ),
      ),
    );
  }
}
