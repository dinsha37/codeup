import 'package:codeup/features/auth/view/information_screen.dart';
import 'package:codeup/features/auth/view/privacypolicy_screen.dart';
import 'package:codeup/features/auth/view/terms_screen.dart';
import 'package:codeup/features/auth/view/feedback_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color _primaryColor = Colors.blue;
const Color _dividerColor = Color(0xFFE0E0E0);
const TextStyle _sectionHeaderStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Colors.grey,
);
const Color _darkGreyText = Color(0xFF333333);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for the toggles
  bool _isDarkModeEnabled = false;
  bool _areNotificationsEnabled = true;
  String _currentLanguage = 'English'; // State for Language Selection display

  // Custom widget for the section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
      child: Text(title.toUpperCase(), style: _sectionHeaderStyle),
    );
  }

  // Custom widget for a standard navigation tile (used for language, legal, etc.)
  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String?
    currentValue, // Used to display the selected language or other value
    VoidCallback? onTap,
    Widget? trailingWidget,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(title, style: const TextStyle(color: _darkGreyText)),
          // Conditional trailing widget: current value or arrow
          trailing:
              trailingWidget ??
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentValue != null)
                    Text(
                      currentValue,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16.0,
                    color: Colors.grey,
                  ),
                ],
              ),
          onTap: onTap,
        ),
        const Divider(
          height: 0,
          indent: 16,
          endIndent: 16,
          color: _dividerColor,
        ),
      ],
    );
  }

  // Custom widget for a switch tile (used for Dark Mode and Notifications)
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(title, style: const TextStyle(color: _darkGreyText)),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _primaryColor,
          ),
          onTap: () => onChanged(!value), // Allows tapping the whole row
        ),
        const Divider(
          height: 0,
          indent: 16,
          endIndent: 16,
          color: _dividerColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,

        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- PROFILE/ACCOUNT QUICK ACTIONS BLOCK ---
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile Information (Left Side)
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.grey[700]),
                      const SizedBox(width: 12),
                      const Text(
                        'Profile Information',
                        style: TextStyle(color: _darkGreyText),
                      ),
                    ],
                  ),
                  // Change Password Button (Right Side)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InformationScreen(),
                        ),
                      );
                      /* Navigate to Change Password Screen */
                    },
                    child: const Text(
                      'Change Password',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0,
              indent: 16,
              endIndent: 16,
              color: _dividerColor,
            ),

            // --- APP PREFERENCES SECTION ---
            _buildSectionHeader('App Preferences'),
            // Dark Mode Tile
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: _isDarkModeEnabled,
              onChanged: (value) {
                setState(() => _isDarkModeEnabled = value);
              },
            ),
            // Language Selection Tile (Navigation-Style)
            _buildNavigationTile(
              icon: Icons.language_outlined,
              title: 'Language Selection',
              currentValue:
                  _currentLanguage, // Shows the currently selected language
              onTap: () {
                // Navigate to a language picker screen and update _currentLanguage
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open Language Picker')),
                );
              },
            ),
            // Notifications Tile
            _buildSwitchTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              value: _areNotificationsEnabled,
              onChanged: (value) {
                setState(() => _areNotificationsEnabled = value);
              },
            ),

            // --- SUPPORT SECTION ---
            _buildSectionHeader('Support'),
            _buildNavigationTile(
              icon: Icons.bug_report_outlined,
              title: 'Help & Feedback',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackScreen(),
                  ),
                );
                /* Navigate to Report Screen */
              },
            ),

            // --- LEGAL SECTION ---
            _buildSectionHeader('Legal'),
            _buildNavigationTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsScreen()),
                );
                /* Open Terms of Service */
              },
            ),
            _buildNavigationTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacypolicyScreen(),
                  ),
                );

                /* Open Privacy Policy */
              },
            ),

            // --- APP VERSION ---
            const Padding(
              padding: EdgeInsets.only(top: 32.0, bottom: 16.0),
              child: Center(
                child: Text(
                  'App Version 1.2.3',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
