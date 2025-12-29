import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/variables/global_variables.dart';
import '../model/user_model.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  bool _isEditing = false;
  bool _isLoading = true;

  // Current User Data from Firebase
  String _mobileNumber = '';
  String _dateOfBirth = '';
  String _skillLevel = '';
  String _userName = '';
  String _userEmail = '';

  // Controllers for TextField inputs when in edit mode
  late TextEditingController _mobileController;
  late TextEditingController _dobController;
  late TextEditingController _skillController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchUserData();
  }

  void _initializeControllers() {
    _mobileController = TextEditingController(text: _mobileNumber);
    _dobController = TextEditingController(text: _dateOfBirth);
    _skillController = TextEditingController(text: _skillLevel);
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the current user's UID from your global variable
      final uid = globalUser?.uid;
      
      if (uid == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        
        setState(() {
          _userName = data['name'] ?? 'User';
          _userEmail = data['email'] ?? '';
          _mobileNumber = data['mobileNumber'] ?? '';
          _dateOfBirth = data['dateOfBirth'] ?? '';
          _skillLevel = data['skillLevel'] ?? 'Not Set';
          _isLoading = false;
        });

        // Update controllers
        _mobileController.text = _mobileNumber;
        _dobController.text = _dateOfBirth;
        _skillController.text = _skillLevel;
      } else {
        _showErrorSnackBar('User document not found');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching user data: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveChanges();
      }
      if (_isEditing) {
        _mobileController.text = _mobileNumber;
        _dobController.text = _dateOfBirth;
        _skillController.text = _skillLevel;
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      final uid = globalUser?.uid;
      
      if (uid == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      // Update local state
      _mobileNumber = _mobileController.text;
      _dateOfBirth = _dobController.text;
      _skillLevel = _skillController.text;

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update({
            'mobileNumber': _mobileNumber,
            'dateOfBirth': _dateOfBirth,
            'skillLevel': _skillLevel,
          });
final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
           final userData = userDoc.data()!;
            final userModel = UserModel.fromJson(userDoc.data()!);
         globalUser = userModel;
      if (mounted) {
        _showSuccessSnackBar('Profile changes saved!');
      }
    } catch (e) {
      _showErrorSnackBar('Error saving changes: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

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
                              border: InputBorder.none,
                            ),
                          )
                        : Text(
                            currentValue.isEmpty ? 'Not Set' : currentValue,
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: const BackButton(),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: _toggleEditMode,
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
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
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _userEmail,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 8.0),
              child: Text(
                'Account Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
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
            
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _dobController.dispose();
    _skillController.dispose();
    super.dispose();
  }
}

class _ActionCard extends StatelessWidget {
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