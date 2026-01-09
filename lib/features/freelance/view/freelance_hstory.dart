import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFreelanceHistoryScreen extends StatefulWidget {
  const UserFreelanceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UserFreelanceHistoryScreen> createState() =>
      _UserFreelanceHistoryScreenState();
}

class _UserFreelanceHistoryScreenState extends State<UserFreelanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveApplications(userId),
          _buildApplicationHistory(userId),
          _buildStatistics(userId),
        ],
      ),
    );
  }

  Widget _buildActiveApplications(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('FreelanceApplications')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Active')
          .orderBy('appliedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final applications = snapshot.data?.docs ?? [];

        if (applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No Active Applications',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apply for projects to get started',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final doc = applications[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildApplicationCard(context, doc.id, data, isActive: true);
          },
        );
      },
    );
  }

  Widget _buildApplicationHistory(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('FreelanceApplications')
          .where('userId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final applications = snapshot.data?.docs ?? [];

        if (applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No Application History',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final doc = applications[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildApplicationCard(
              context,
              doc.id,
              data,
              isActive: data['status'] == 'Active',
            );
          },
        );
      },
    );
  }

  Widget _buildStatistics(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('FreelanceApplications')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final applications = snapshot.data?.docs ?? [];
        final totalApplications = applications.length;
        final activeApplications = applications
            .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'Active')
            .length;
        final acceptedApplications = applications
            .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'Accepted')
            .length;
        final rejectedApplications = applications
            .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'Rejected')
            .length;

        final acceptanceRate = totalApplications > 0
            ? ((acceptedApplications / totalApplications) * 100).toStringAsFixed(1)
            : '0';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard(
              title: 'Total Applications',
              value: totalApplications.toString(),
              icon: Icons.assignment,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Active',
              value: activeApplications.toString(),
              icon: Icons.hourglass_empty,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Accepted',
              value: acceptedApplications.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Rejected',
              value: rejectedApplications.toString(),
              icon: Icons.cancel,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Success Rate',
              value: '$acceptanceRate%',
              icon: Icons.trending_up,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Tips to Increase Success Rate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTipItem('Write personalized, detailed cover letters'),
                    const SizedBox(height: 12),
                    _buildTipItem('Highlight relevant skills and experience'),
                    const SizedBox(height: 12),
                    _buildTipItem('Be competitive with your bid amount'),
                    const SizedBox(height: 12),
                    _buildTipItem('Respond quickly to project postings'),
                    const SizedBox(height: 12),
                    _buildTipItem('Build a strong portfolio with past work'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    String appId,
    Map<String, dynamic> data,
    {required bool isActive}
  ) {
    final status = data['status'] ?? 'Active';
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['projectTitle'] ?? 'Unknown Project',
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bid Amount',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${data['bidAmount'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['timeline'] ?? 'Not specified',
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
                      'Applied',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(
                        (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                      ),
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

            // Cover Letter Preview
            if ((data['coverLetter'] as String?)?.isNotEmpty ?? false) ...[
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Your Proposal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data['coverLetter'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showApplicationDetails(context, appId, data),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isActive)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showEditApplicationDialog(context, appId, data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                if (isActive)
                  const SizedBox(width: 8),
                if (isActive)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showWithdrawDialog(context, appId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Withdraw',
                        style: TextStyle(fontSize: 12),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            tip,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showApplicationDetails(
    BuildContext context,
    String appId,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Project:', data['projectTitle'] ?? 'N/A'),
              _buildDetailRow('Budget:', data['projectBudget'] ?? 'N/A'),
              _buildDetailRow('Your Bid:', '\$${data['bidAmount'] ?? 'N/A'}'),
              _buildDetailRow('Timeline:', data['timeline'] ?? 'N/A'),
              _buildDetailRow('Status:', data['status'] ?? 'N/A'),
              _buildDetailRow(
                'Applied:',
                _formatDate(
                  (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your Proposal:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                data['coverLetter'] ?? 'No cover letter',
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
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

  void _showEditApplicationDialog(
    BuildContext context,
    String appId,
    Map<String, dynamic> data,
  ) {
    final bidController = TextEditingController(text: data['bidAmount'].toString());
    final coverLetterController = TextEditingController(text: data['coverLetter']);
    String selectedTimeline = data['timeline'] ?? '1 week';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Application'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bidController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bid Amount',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTimeline,
                  items: [
                    '1 week',
                    '2 weeks',
                    '3 weeks',
                    '1 month',
                    '2 months',
                    '3+ months',
                  ]
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTimeline = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Timeline',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: coverLetterController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Proposal',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore
                      .collection('FreelanceApplications')
                      .doc(appId)
                      .update({
                    'bidAmount': double.tryParse(bidController.text) ?? 0,
                    'timeline': selectedTimeline,
                    'coverLetter': coverLetterController.text.trim(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Application updated!'),
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
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, String appId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: const Text(
          'Are you sure you want to withdraw this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore
                    .collection('FreelanceApplications')
                    .doc(appId)
                    .delete();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application withdrawn!'),
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
            child: const Text('Withdraw'),
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