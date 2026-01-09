import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFreelanceListingScreen extends StatefulWidget {
  const UserFreelanceListingScreen({Key? key}) : super(key: key);

  @override
  State<UserFreelanceListingScreen> createState() =>
      _UserFreelanceListingScreenState();
}

class _UserFreelanceListingScreenState extends State<UserFreelanceListingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _selectedCategory = 0;
  final List<String> categories = [
    'All',
    'Web Dev',
    'Mobile',
    'Design',
    'Writing',
    'Marketing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

     
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFFf5f7fa)],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'My Certificates',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
            ],
          ),

        ],
      ),
    ),
            // Categories Section
            _buildCategories(),
            const SizedBox(height: 16),
        
            // Projects List with FireStore Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getProjectsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    log("Error ${snapshot.error}");
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
        
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
        
                  final projects = snapshot.data?.docs ?? [];
        
                  if (projects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Projects Available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
        
                  // Projects Count
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              '${projects.length} Projects Available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Sorted by: Newest',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final doc = projects[index];
                            final data = doc.data() as Map<String, dynamic>;
        
                            return Column(
                              children: [
                                FreelanceProjectCard(
                                  projectId: doc.id,
                                  title: data['title'] ?? 'Unnamed Project',
                                  description: data['description'] ?? '',
                                  budget: data['budget'] ?? '\$0',
                                  deadline: data['deadline'] ?? 'No deadline',
                                  skills: List<String>.from(data['skills'] ?? []),
                                  clientName: data['clientName'] ?? 'Unknown Client',
                                  clientRating: (data['clientRating'] ?? 4.5).toDouble(),
                                  projectType: data['projectType'] ?? 'Fixed Price',
                                  experienceLevel: data['experienceLevel'] ?? 'Intermediate',
                                  proposals: data['proposals'] ?? 0,
                                ),
                                if (index < projects.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getProjectsStream() {
    if (_selectedCategory == 0) {
      return _firestore
          .collection('Freelance')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      String categoryName = categories[_selectedCategory];
      return _firestore
          .collection('Freelance')
          .where('category', isEqualTo: categoryName)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: _selectedCategory == index,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = index;
                });
              },
              selectedColor: Colors.blueAccent,
              labelStyle: TextStyle(
                color: _selectedCategory == index
                    ? Colors.white
                    : Colors.grey[700],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Projects'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search by skills, title, or keywords...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSearchResults(searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showSearchResults(String query) {
    final lowerQuery = query.toLowerCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Results'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('Freelance').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allProjects = snapshot.data?.docs ?? [];
              final filteredProjects = allProjects.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = (data['title'] ?? '').toString().toLowerCase();
                final skills = List<String>.from(data['skills'] ?? []);
                final skillsMatch = skills.any((skill) => skill.toLowerCase().contains(lowerQuery));

                return title.contains(lowerQuery) || skillsMatch;
              }).toList();

              if (filteredProjects.isEmpty) {
                return Center(
                  child: Text('No projects found for "$query"'),
                );
              }

              return ListView.builder(
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  final doc = filteredProjects[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['title'] ?? 'Unnamed'),
                    subtitle: Text(data['budget'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
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

  void _showFilterDialog() {
    String? selectedProjectType;
    String? selectedExperienceLevel;

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Projects',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Project Type', [
                'Fixed Price',
                'Hourly',
                'Both',
              ], (selected) {
                setState(() {
                  selectedProjectType = selected;
                });
              }, selectedProjectType),
              const SizedBox(height: 15),
              _buildFilterOption('Experience Level', [
                'Entry',
                'Intermediate',
                'Expert',
              ], (selected) {
                setState(() {
                  selectedExperienceLevel = selected;
                });
              }, selectedExperienceLevel),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedProjectType = null;
                          selectedExperienceLevel = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    String title,
    List<String> options,
    Function(String) onSelected,
    String? selectedValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options
              .map(
                (option) => FilterChip(
                  label: Text(option),
                  selected: selectedValue == option,
                  onSelected: (selected) {
                    onSelected(option);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class FreelanceProjectCard extends StatelessWidget {
  final String projectId;
  final String title;
  final String description;
  final String budget;
  final String deadline;
  final List<String> skills;
  final String clientName;
  final double clientRating;
  final String projectType;
  final String experienceLevel;
  final int proposals;

  const FreelanceProjectCard({
    required this.projectId,
    required this.title,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.skills,
    required this.clientName,
    required this.clientRating,
    required this.projectType,
    required this.experienceLevel,
    required this.proposals,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    budget,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Client info and rating
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  clientName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, size: 14, color: Colors.orange[400]),
                const SizedBox(width: 2),
                Text(
                  clientRating.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Skills required
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Project details and action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          deadline,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$proposals applications',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showApplyDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApplyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationModal(
        projectId: projectId,
        projectTitle: title,
        projectBudget: budget,
        category: experienceLevel,
      ),
    );
  }
}

class ApplicationModal extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  final String projectBudget;
  final String category;

  const ApplicationModal({
    required this.projectId,
    required this.projectTitle,
    required this.projectBudget,
    required this.category,
    Key? key,
  }) : super(key: key);

  @override
  State<ApplicationModal> createState() => _ApplicationModalState();
}

class _ApplicationModalState extends State<ApplicationModal> {
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _bidAmountController = TextEditingController();
  String _selectedTimeline = '1 week';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bidAmountController.text = _extractBudget(widget.projectBudget);
  }

  String _extractBudget(String budget) {
    final regex = RegExp(r'[\d,]+\.?\d*');
    final match = regex.firstMatch(budget);
    return match?.group(0) ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Apply for Project',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.projectTitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Bid Amount (\$)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bidAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your bid amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Estimated Timeline',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: _selectedTimeline,
              items: [
                '1 week',
                '2 weeks',
                '3 weeks',
                '1 month',
                '2 months',
                '3+ months',
              ]
                  .map(
                    (timeline) => DropdownMenuItem(
                      value: timeline,
                      child: Text(timeline),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimeline = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Cover Letter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _coverLetterController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell why you are the best fit for this project...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Apply'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (_coverLetterController.text.trim().isEmpty ||
        _bidAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid ?? '';

      await _firestore.collection('FreelanceApplications').add({
        'projectId': widget.projectId,
        'userId': userId,
        'projectTitle': widget.projectTitle,
        'projectBudget': widget.projectBudget,
        'category': widget.category,
        'bidAmount': double.tryParse(_bidAmountController.text) ?? 0,
        'timeline': _selectedTimeline,
        'coverLetter': _coverLetterController.text.trim(),
        'status': 'Active',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied for "${widget.projectTitle}"'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _bidAmountController.dispose();
    super.dispose();
  }
}