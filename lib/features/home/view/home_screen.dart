import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  String userlevel = " ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CodeUpHeader(),
              const SizedBox(height: 24),
              StatusCard(userName: userName),
              const SizedBox(height: 32),
              const FeatureGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. App Header
class CodeUpHeader extends StatelessWidget {
  const CodeUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.code_rounded, color: Colors.blueAccent, size: 32),
            const SizedBox(width: 8),
            Text(
              'CodeUp',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blueAccent,
          child: Text(
            'S',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// 2. Main Status Card
class StatusCard extends StatelessWidget {
  final String userName;

  const StatusCard({required this.userName, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.white70.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back  $userName!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Current Level: ', // Reflects the Basic/Medium/Hard system
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromARGB(255, 151, 106, 39),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Action: Leads to solving challenges and progression
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text(
              'Continue Solving Challenges',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Feature Grid
class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: const [
        FeatureCard(
          icon: Icons.emoji_events_outlined,
          label: 'Certificates',
          iconColor: Colors.blueAccent,
        ),
        FeatureCard(
          icon: Icons.bar_chart_rounded,
          label: 'Analytics',
          iconColor: Colors.orangeAccent,
        ),
        FeatureCard(
          icon: Icons.code,
          label: 'Coding Focus',
          iconColor: Colors.lightGreen,
        ),
      ],
    );
  }
}

// 3a. Individual Feature Card
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const FeatureCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle navigation to specific module (e.g., Certificate Module)
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


