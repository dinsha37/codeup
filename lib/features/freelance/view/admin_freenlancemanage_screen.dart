import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFreelanceManagementScreen extends StatefulWidget {
  const AdminFreelanceManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminFreelanceManagementScreen> createState() =>
      _AdminFreelanceManagementScreenState();
}

class _AdminFreelanceManagementScreenState
    extends State<AdminFreelanceManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Freelance Posts'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Freelance')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data?.docs ?? [];

          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Freelance Posts Yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + button to create one',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final doc = projects[index];
              final data = doc.data() as Map<String, dynamic>;

              return _buildProjectCard(context, doc.id, data);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Post'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'Unnamed Project',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['category'] ?? 'General',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    data['budget'] ?? '\$0',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applications',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data['proposals'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deadline',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['deadline'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['projectType'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: (data['skills'] as List<dynamic>?)
                      ?.cast<String>()
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          labelStyle: const TextStyle(fontSize: 11),
                        ),
                      )
                      .toList() ??
                  [],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    onPressed: () => _showEditProjectBottomSheet(context, docId, data),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                    onPressed: () => _showProjectDetails(context, data),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    onPressed: () => _showDeleteDialog(context, docId, data['title']),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProjectBottomSheet(BuildContext context) {
    _showProjectFormBottomSheet(context, isEditing: false);
  }

  void _showEditProjectBottomSheet(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    _showProjectFormBottomSheet(context, isEditing: true, docId: docId, initialData: data);
  }

  void _showProjectFormBottomSheet(
    BuildContext context, {
    required bool isEditing,
    String? docId,
    Map<String, dynamic>? initialData,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => _ProjectFormBottomSheetContent(
        isEditing: isEditing,
        docId: docId,
        initialData: initialData,
        firestore: _firestore,
      ),
    );
  }

  void _showProjectDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Title:', data['title'] ?? 'N/A'),
              _buildDetailRow('Category:', data['category'] ?? 'N/A'),
              _buildDetailRow('Budget:', data['budget'] ?? 'N/A'),
              _buildDetailRow('Deadline:', data['deadline'] ?? 'N/A'),
              _buildDetailRow('Client:', data['clientName'] ?? 'N/A'),
              _buildDetailRow('Rating:', data['clientRating'].toString()),
              _buildDetailRow('Type:', data['projectType'] ?? 'N/A'),
              _buildDetailRow('Level:', data['experienceLevel'] ?? 'N/A'),
              _buildDetailRow('Applications:', (data['proposals'] ?? 0).toString()),
              const SizedBox(height: 12),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(data['description'] ?? 'N/A'),
              const SizedBox(height: 12),
              const Text(
                'Skills:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: (data['skills'] as List<dynamic>?)
                        ?.cast<String>()
                        .map((skill) => Chip(label: Text(skill)))
                        .toList() ??
                    [],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('Freelance').doc(docId).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Project deleted!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectFormBottomSheetContent extends StatefulWidget {
  final bool isEditing;
  final String? docId;
  final Map<String, dynamic>? initialData;
  final FirebaseFirestore firestore;

  const _ProjectFormBottomSheetContent({
    required this.isEditing,
    this.docId,
    this.initialData,
    required this.firestore,
  });

  @override
  State<_ProjectFormBottomSheetContent> createState() =>
      _ProjectFormBottomSheetContentState();
}

class _ProjectFormBottomSheetContentState
    extends State<_ProjectFormBottomSheetContent> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController budgetController;
  late TextEditingController deadlineController;
  late TextEditingController clientNameController;
  late TextEditingController clientRatingController;
  late TextEditingController skillController;

  late String selectedCategory;
  late String projectType;
  late String experienceLevel;
  late List<String> selectedSkills;

  final categories = ['Web Dev', 'Mobile', 'Design', 'Writing', 'Marketing'];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.initialData?['title'] ?? '');
    descriptionController =
        TextEditingController(text: widget.initialData?['description'] ?? '');
    budgetController =
        TextEditingController(text: widget.initialData?['budget'] ?? '');
    deadlineController =
        TextEditingController(text: widget.initialData?['deadline'] ?? '');
    clientNameController =
        TextEditingController(text: widget.initialData?['clientName'] ?? '');
    clientRatingController = TextEditingController(
      text: (widget.initialData?['clientRating'] ?? 4.5).toString(),
    );
    skillController = TextEditingController();

    selectedCategory = widget.initialData?['category'] ?? 'Web Dev';
    projectType = widget.initialData?['projectType'] ?? 'Fixed Price';
    experienceLevel = widget.initialData?['experienceLevel'] ?? 'Intermediate';
    selectedSkills = List<String>.from(widget.initialData?['skills'] ?? []);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    budgetController.dispose();
    deadlineController.dispose();
    clientNameController.dispose();
    clientRatingController.dispose();
    skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEditing ? 'Edit Project' : 'Create New Project',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isEditing
                        ? 'Update project details'
                        : 'Add a new freelance opportunity',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Form content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildInputField('Project Title', titleController),
                  const SizedBox(height: 16),
                  _buildInputField(
                    'Description',
                    descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField('Category', selectedCategory, categories,
                      (value) {
                    setState(() => selectedCategory = value!);
                  }),
                  const SizedBox(height: 16),
                  _buildInputField('Budget (e.g., \$2,400 or \$45/hour)',
                      budgetController),
                  const SizedBox(height: 16),
                  _buildInputField('Deadline (e.g., Dec 15, 2025)',
                      deadlineController),
                  const SizedBox(height: 16),
                  _buildSkillsSection(),
                  const SizedBox(height: 16),
                  _buildInputField('Client Name', clientNameController),
                  const SizedBox(height: 16),
                  _buildInputField('Client Rating (0-5)', clientRatingController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildDropdownField('Project Type', projectType,
                      ['Fixed Price', 'Hourly'], (value) {
                    setState(() => projectType = value!);
                  }),
                  const SizedBox(height: 16),
                  _buildDropdownField('Experience Level', experienceLevel,
                      ['Entry', 'Intermediate', 'Expert'], (value) {
                    setState(() => experienceLevel = value!);
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Icon(
                              widget.isEditing ? Icons.edit : Icons.add,
                              size: 18,
                            ),
                      label: Text(widget.isEditing ? 'Update' : 'Create'),
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

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills Required',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: skillController,
                decoration: InputDecoration(
                  hintText: 'Add a skill',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.indigo, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                color: Colors.white,
                onPressed: () {
                  if (skillController.text.trim().isNotEmpty) {
                    setState(() {
                      selectedSkills.add(skillController.text.trim());
                      skillController.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedSkills
              .map(
                (skill) => Chip(
                  label: Text(skill),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      selectedSkills.remove(skill);
                    });
                  },
                  backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: Colors.indigo),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        budgetController.text.trim().isEmpty ||
        selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final projectData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategory,
        'budget': budgetController.text.trim(),
        'deadline': deadlineController.text.trim(),
        'skills': selectedSkills,
        'clientName': clientNameController.text.trim(),
        'clientRating': double.tryParse(clientRatingController.text) ?? 4.5,
        'projectType': projectType,
        'experienceLevel': experienceLevel,
      };

      if (widget.isEditing && widget.docId != null) {
        await widget.firestore
            .collection('Freelance')
            .doc(widget.docId)
            .update(projectData);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        projectData['proposals'] = 0;
        projectData['createdAt'] = FieldValue.serverTimestamp();
        await widget.firestore.collection('Freelance').add(projectData);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}