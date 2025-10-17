import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {
              // Action: Navigate to Settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User Header (Avatar, Name, Level)
              const UserHeader(),
              const SizedBox(height: 40),

              // 2. Performance Metrics Grid
              const PerformanceMetricsGrid(),
              const SizedBox(height: 40),

              // 3. Featured Certificates Section
              const CertificatesSection(),
              const SizedBox(height: 30),

              // 4. Action Button: View Full Analytics
              ElevatedButton.icon(
                onPressed: () {
                  // Action: Navigate to Performance Analytics Module
                },
                icon: const Icon(Icons.analytics_outlined, size: 24),
                label: const Text(
                  'View Full Performance Analytics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget Components ---

// 1. User Header
class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.limeAccent, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.limeAccent.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Color(
              0xFF303030,
            ), // Dark grey background for image
            child: Icon(Icons.person_rounded, size: 60, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        // Name
        const Text(
          'Sarah K.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Current Level Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orangeAccent, width: 1),
          ),
          child: const Text(
            'Current Level: MEDIUM',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// 2. Performance Metrics Grid
class PerformanceMetricsGrid extends StatelessWidget {
  const PerformanceMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: const [
        MetricCard(
          value: '45',
          label: 'Challenges Solved',
          icon: Icons.check_circle_outline,
          color: CupertinoColors.activeGreen,
        ),
        MetricCard(
          value: '82%',
          label: 'Average Accuracy',
          icon: Icons.speed_outlined,
          color: Colors.limeAccent,
        ),
        MetricCard(
          value: '12h',
          label: 'Total Study Time',
          icon: Icons.access_time_outlined,
          color: Colors.white,
        ),
      ],
    );
  }
}

// 2a. Individual Metric Card
class MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// 3. Certificates Section
class CertificatesSection extends StatelessWidget {
  const CertificatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Certifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),

          // Certificate Item Example
          const CertificateItem(
            title: 'Basic Level Completion',
            date: 'Issued: July 2025',
            color: CupertinoColors.activeGreen,
          ),
          const SizedBox(height: 12),

          // No Medium Level Cert yet (Current Level is Medium)
          const CertificateItem(
            title: 'Medium Level Certificate',
            date: 'Status: In Progress',
            color: Colors.white30,
          ),

          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              // Action: Navigate to the full Certificate Module
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.limeAccent,
            ),
            label: const Text(
              'Manage & Share Certificates',
              style: TextStyle(
                color: Colors.limeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3a. Individual Certificate Item
class CertificateItem extends StatelessWidget {
  final String title;
  final String date;
  final Color color;

  const CertificateItem({
    required this.title,
    required this.date,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.verified_user_rounded, color: color, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
