import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FreelanceScreen extends StatefulWidget {
  const FreelanceScreen({super.key});

  @override
  State<FreelanceScreen> createState() => _FreelanceScreenState();
}

class _FreelanceScreenState extends State<FreelanceScreen> {
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Available Projects'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories Section
          _buildCategories(),
          const SizedBox(height: 16),

          // Projects Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '24 Projects Available',
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

          // Projects List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: const [
                AvailableProjectCard(
                  title: 'E-commerce Website Development',
                  description:
                      'Build a complete e-commerce platform with React.js and Node.js. Experience with payment integration required.',
                  budget: '\$2,400',
                  deadline: 'Dec 15, 2025',
                  skills: ['React.js', 'Node.js', 'MongoDB'],
                  clientName: 'Tech Solutions Inc.',
                  clientRating: 4.8,
                  projectType: 'Fixed Price',
                  experienceLevel: 'Intermediate',
                  proposals: 12,
                ),
                SizedBox(height: 12),
                AvailableProjectCard(
                  title: 'Mobile App UI/UX Design',
                  description:
                      'Create modern and intuitive UI designs for a fitness tracking mobile application.',
                  budget: '\$1,200',
                  deadline: 'Dec 10, 2025',
                  skills: ['Figma', 'UI/UX', 'Mobile Design'],
                  clientName: 'HealthTech Startup',
                  clientRating: 4.9,
                  projectType: 'Fixed Price',
                  experienceLevel: 'Entry',
                  proposals: 8,
                ),
                SizedBox(height: 12),
                AvailableProjectCard(
                  title: 'Flutter Developer for Food Delivery App',
                  description:
                      'Looking for experienced Flutter developer to build cross-platform food delivery application.',
                  budget: '\$3,500',
                  deadline: 'Jan 20, 2026',
                  skills: ['Flutter', 'Dart', 'Firebase'],
                  clientName: 'Foodie Express',
                  clientRating: 4.7,
                  projectType: 'Fixed Price',
                  experienceLevel: 'Expert',
                  proposals: 15,
                ),
                SizedBox(height: 12),
                AvailableProjectCard(
                  title: 'Content Writer for Tech Blog',
                  description:
                      'Regular content creation for technology blog. Must have experience in AI and blockchain topics.',
                  budget: '\$45/hour',
                  deadline: 'Ongoing',
                  skills: ['Writing', 'SEO', 'Technology'],
                  clientName: 'Tech Insights Media',
                  clientRating: 4.6,
                  projectType: 'Hourly',
                  experienceLevel: 'Intermediate',
                  proposals: 20,
                ),
                SizedBox(height: 12),
                AvailableProjectCard(
                  title: 'Social Media Marketing Specialist',
                  description:
                      'Manage social media accounts and create engaging content for SaaS product.',
                  budget: '\$1,800',
                  deadline: 'Dec 30, 2025',
                  skills: ['Social Media', 'Marketing', 'Content Creation'],
                  clientName: 'SaaS Company',
                  clientRating: 4.8,
                  projectType: 'Fixed Price',
                  experienceLevel: 'Intermediate',
                  proposals: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Projects'),
        content: TextField(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
            ]),
            const SizedBox(height: 15),
            _buildFilterOption('Experience Level', [
              'Entry',
              'Intermediate',
              'Expert',
            ]),
            const SizedBox(height: 15),
            _buildFilterOption('Budget Range', [
              '\$0-\$500',
              '\$500-\$2000',
              '\$2000+',
            ]),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
    );
  }

  Widget _buildFilterOption(String title, List<String> options) {
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
                  selected: false,
                  onSelected: (selected) {},
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class AvailableProjectCard extends StatelessWidget {
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

  const AvailableProjectCard({
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
    super.key,
  });

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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
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
                          '$proposals proposals',
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
                  onPressed: () => _showProposalDialog(context),
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
                    'Send Proposal',
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

  void _showProposalDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProposalModal(
        projectTitle: title,
        projectBudget: budget,
        onProposalSubmitted: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Proposal sent for "$title"'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }
}

class ProposalModal extends StatefulWidget {
  final String projectTitle;
  final String projectBudget;
  final VoidCallback onProposalSubmitted;

  const ProposalModal({
    required this.projectTitle,
    required this.projectBudget,
    required this.onProposalSubmitted,
    super.key,
  });

  @override
  State<ProposalModal> createState() => _ProposalModalState();
}

class _ProposalModalState extends State<ProposalModal> {
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _bidAmountController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  String _selectedTimeline = '1 week';

  @override
  void initState() {
    super.initState();
    _bidAmountController.text = _extractBudget(widget.projectBudget);
  }

  String _extractBudget(String budget) {
    // Extract numeric value from budget string
    final regex = RegExp(r'[\d,]+\.?\d*');
    final match = regex.firstMatch(budget);
    return match?.group(0) ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
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
            'Send Proposal',
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

          // Bid Amount
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

          // Timeline
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
            items:
                [
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

          // Cover Letter
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
              hintText: 'Explain why you\'re the best fit for this project...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onProposalSubmitted();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Send Proposal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _bidAmountController.dispose();
    _timelineController.dispose();
    super.dispose();
  }
}
