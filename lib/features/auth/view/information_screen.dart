import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  // 1. Data and State Management
  bool _isEditing = false; // Controls view vs. edit mode

  // Current User Data (These would typically come from a model or API)
  String _mobileNumber = '+91 9876543210';
  String _dateOfBirth = '05 Oct 2002';
  String _skillLevel = 'Beginner';

  // Controllers for TextField inputs when in edit mode
  late TextEditingController _mobileController;
  late TextEditingController _dobController;
  late TextEditingController _skillController;
  @override
  void initState() {
    super.initState();
    // Initialize controllers with current data
    _mobileController = TextEditingController(text: _mobileNumber);
    _dobController = TextEditingController(text: _dateOfBirth);
    _skillController = TextEditingController(text: _skillLevel);
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _dobController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  // Function to toggle the editing mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      // If switching to view mode, call the save function
      if (!_isEditing) {
        _saveChanges();
      }
      // If switching to edit mode, reset controllers to current data
      if (_isEditing) {
        _mobileController.text = _mobileNumber;
        _dobController.text = _dateOfBirth;
        _skillController.text = _skillLevel;
      }
    });
  }

  // Function to save changes
  void _saveChanges() {
    // 1. Update the state variables with new values from controllers
    _mobileNumber = _mobileController.text;
    _dateOfBirth = _dobController.text;
    _skillLevel = _skillController.text;

    // 2. Here you would typically call an API to save the data
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile changes saved!')));
  }

  // --- Helper Widget for the Editable Cards ---
  Widget _buildEditableInfoCard({
    required IconData icon,
    required String title,
    required String currentValue,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(icon, color: Colors.black, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    // 2. Conditional Widget Rendering (The Core of In-Place Edit)
                    isEditable
                        ? TextField(
                            controller: controller,
                            keyboardType: title == 'Mobile Number'
                            ? TextInputType.phone
                            : TextInputType.text,
                            style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none, // Removes underline
                            ),
                          )
                        : Text(
                            currentValue,
                            style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: const BackButton(),
        actions: [
          // The Edit/Save Button
          TextButton(
            onPressed: _toggleEditMode,
            child: Text(
              _isEditing ? 'Save' : 'Edit', // Toggle Text
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. User Avatar and Details Section (Static)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue[100],
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Fida Fathima',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'fida@example.com',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Account Information Title
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 8.0),
              child: Text(
                'Account Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 3. Editable Information Cards (Using the helper widget)
            _buildEditableInfoCard(
              icon: Icons.phone,
              title: 'Mobile Number',
              currentValue: _mobileNumber,
              controller: _mobileController,
              isEditable: _isEditing,
            ),
            _buildEditableInfoCard(
              icon: Icons.calendar_today,
              title: 'Date of Birth',
              currentValue: _dateOfBirth,
              controller: _dobController,
              isEditable: _isEditing,
            ),
            _buildEditableInfoCard(
              icon: Icons.school,
              title: 'Skill Level',
              currentValue: _skillLevel,
              controller: _skillController,
              isEditable: _isEditing,
            ),

            // 4. Non-Editable Action Buttons (Change Password & Logout)
            // These would still navigate to a separate screen.
            _ActionCard(
              icon: Icons.lock,
              title: 'Change Password',
              isDestructive: false,
              onTap: () {
                // Navigate to Change Password Screen
              },
            ),
            _ActionCard(
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true,
              onTap: () {
                // Handle logout logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for action buttons (reused from the previous answer)
class _ActionCard extends StatelessWidget {
  // ... (Code for _ActionCard is the same as the previous response)
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.isDestructive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
