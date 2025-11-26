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
        backgroundColor: Colors.blue,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [],
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
            border: Border.all(color: Colors.blue, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 40,
            backgroundColor: Color.fromARGB(196, 98, 159, 228),

            child: Icon(Icons.person_rounded, size: 60, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        // Name
        const Text(
          'Sarah K.',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Current Level Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: const Text(
            'Current Level: MEDIUM',
            style: TextStyle(
              color: Colors.blue,
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
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.7,
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
          color: Colors.deepOrangeAccent,
        ),
        MetricCard(
          value: '12h',
          label: 'Total Study Time',
          icon: Icons.access_time_outlined,
          color: Colors.deepPurpleAccent,
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
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
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
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black, fontSize: 10),
            overflow: TextOverflow.visible,
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
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Certifications',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: Colors.black),
          const SizedBox(height: 10),

          // Certificate Item Example
          const CertificateItem(
            title: 'Basic Level Completion',
            date: 'Issued: July 2025',
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 12),

          // No Medium Level Cert yet (Current Level is Medium)
          const CertificateItem(
            title: 'Medium Level Certificate',
            date: 'Status: In Progress',
            color: Colors.blueAccent,
          ),

          const SizedBox(height: 20),
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
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
