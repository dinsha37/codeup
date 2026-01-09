import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

import '../../../utils/variables/global_variables.dart';
import '../../levels/model/mainlevel_model.dart';


// ============================================================================
// CERTIFICATES SCREEN - Main Entry Point
// ============================================================================
class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Certificate categories
  int selectedCategory = 0;
  List<String> categories = ['All'];
  List<String> categoryIds = ['all']; // To store mainLevelIds

  List<_Certificate> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCategoriesAndCertificates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  Future<void> _loadCategoriesAndCertificates() async {
    try {
      final userId = globalUser?.uid;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get all main levels to populate categories
      final mainLevelsSnapshot = await _db
          .collection('mainLevels')
          .orderBy('order')
          .get();
      
      final Map<String, MainLevel> mainLevelsMap = {};
      final List<String> categoryNames = ['All'];
      final List<String> categoryMainLevelIds = ['all'];
      
      for (var doc in mainLevelsSnapshot.docs) {
        final mainLevel = MainLevel.fromFirestore(doc);
        mainLevelsMap[doc.id] = mainLevel;
        categoryNames.add(mainLevel.name);
        categoryMainLevelIds.add(doc.id);
      }

      // Get user's completed sublevels
      final userDoc = await _db.collection('userStatus').doc(userId).get();
      final completedSubLevels =
          List<String>.from(userDoc.data()?['completedSubLevels'] ?? []);

      // Get all certificates for the user
      final certificatesSnapshot = await _db
          .collection('userStatus')
          .doc(userId)
          .collection('certificates')
          .orderBy('issuedAt', descending: true)
          .get();

      // Build certificate list - only for completed main levels
      final certificates = <_Certificate>[];
      
      for (var certDoc in certificatesSnapshot.docs) {
        final data = certDoc.data();
        final mainLevelId = data['mainLevelId'] as String?;
        final issuedAt = data['issuedAt'] as Timestamp?;

        if (mainLevelId != null && mainLevelsMap.containsKey(mainLevelId)) {
          final mainLevel = mainLevelsMap[mainLevelId]!;
          
          // Get all sublevels for this main level
          final subLevelsDocs = await _db
              .collection('subLevels')
              .where('mainLevelId', isEqualTo: mainLevelId)
              .get();
          
          final totalSubLevels = subLevelsDocs.docs.length;
          final mainLevelSubLevelIds =
              subLevelsDocs.docs.map((doc) => doc.id).toList();
          
          // Count how many are completed
          final completedCount = mainLevelSubLevelIds
              .where((id) => completedSubLevels.contains(id))
              .length;

          // Only add certificate if ALL sublevels are completed
          if (totalSubLevels > 0 && completedCount == totalSubLevels) {
            certificates.add(_Certificate(
              title: '${mainLevel.name} Master',
              subtitle: 'Completed all ${mainLevel.name} levels',
              issueDate: _formatDate(issuedAt),
              icon: _getIconForLevel(mainLevel.name),
              gradientColors: mainLevel.gradientColors,
              isMaster: true,
              level: _getLevelCategory(mainLevel.name),
              achievements: '$completedCount levels completed',
              mainLevelId: mainLevelId,
              mainLevelName: mainLevel.name,
            ));
          }
        }
      }

      setState(() {
        categories = categoryNames;
        categoryIds = categoryMainLevelIds;
        _certificates = certificates;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading certificates: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    final date = timestamp.toDate();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  IconData _getIconForLevel(String levelName) {
    final lowerName = levelName.toLowerCase();
    if (lowerName.contains('python')) return Icons.code;
    if (lowerName.contains('javascript') || lowerName.contains('js')) {
      return Icons.javascript;
    }
    if (lowerName.contains('algorithm')) return Icons.psychology;
    if (lowerName.contains('web') || lowerName.contains('full stack')) {
      return Icons.web;
    }
    if (lowerName.contains('data')) return Icons.storage;
    return Icons.emoji_events;
  }

  String _getLevelCategory(String levelName) {
    final lowerName = levelName.toLowerCase();
    if (lowerName.contains('master') || lowerName.contains('expert')) {
      return 'Master';
    }
    if (lowerName.contains('advanced')) return 'Advanced';
    return 'Basic';
  }

  int _getMasterCount() =>
      _certificates.where((c) => c.level == 'Master').length;
  
  int _getAdvancedCount() =>
      _certificates.where((c) => c.level == 'Advanced').length;
  
  int _getBasicCount() =>
      _certificates.where((c) => c.level == 'Basic').length;

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
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildContent(),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Custom header with gradient background
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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
          const SizedBox(height: 20),
          _buildStatsRow(),
        ],
      ),
    );
  }

  // Stats row showing achievement counts
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatBox('${_certificates.length}', 'Total', Icons.emoji_events),
        Container(width: 1, height: 40, color: Colors.white30),
        _buildStatBox('${_getMasterCount()}', 'Master', Icons.stars),
        Container(width: 1, height: 40, color: Colors.white30),
        _buildStatBox('${_getAdvancedCount()}', 'Advanced', Icons.trending_up),
      ],
    );
  }

  Widget _buildStatBox(String count, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  // Main content area
  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildCategoryFilter(),
          const SizedBox(height: 20),
          Expanded(child: _buildCertificatesList()),
        ],
      ),
    );
  }

  // Category filter chips
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => selectedCategory = index);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF667eea),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF667eea)
                      : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // List of all certificates
  Widget _buildCertificatesList() {
    final certificates = _getFilteredCertificates();

    if (certificates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Certificates Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete all levels in a main level\nto earn a certificate!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final cert = certificates[index];
        return _buildCertificateCard(cert, index);
      },
    );
  }

  // Get filtered certificates based on category
  List<_Certificate> _getFilteredCertificates() {
    // If "All" is selected (index 0)
    if (selectedCategory == 0) return _certificates;
    
    // Get the mainLevelId for the selected category
    final selectedMainLevelId = categoryIds[selectedCategory];
    
    // Filter certificates by mainLevelId
    return _certificates
        .where((c) => c.mainLevelId == selectedMainLevelId)
        .toList();
  }

  // Individual certificate card
  Widget _buildCertificateCard(_Certificate cert, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () => _showCertificateDetail(cert),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: cert.gradientColors,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: cert.gradientColors[0].withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned(
                  right: -20,
                  top: -20,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(cert.icon, size: 120, color: Colors.white),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              cert.icon,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cert.subtitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (cert.isMaster)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: cert.gradientColors[0],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Master',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: cert.gradientColors[0],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Issued Date',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                cert.issueDate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _downloadCertificate(cert),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: cert.gradientColors[0],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show certificate detail dialog
  void _showCertificateDetail(_Certificate cert) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: cert.gradientColors),
                  shape: BoxShape.circle,
                ),
                child: Icon(cert.icon, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 20),
              Text(
                cert.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cert.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Issued', cert.issueDate),
                    const Divider(height: 20),
                    _buildDetailRow('Level', cert.level),
                    const Divider(height: 20),
                    _buildDetailRow('Achievements', cert.achievements),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _downloadCertificate(cert);
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cert.gradientColors[0],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  // Download certificate action
  void _downloadCertificate(_Certificate cert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Downloading "${cert.title}" certificate...')),
          ],
        ),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Show share dialog
  void _showShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share Certificates',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.link, 'Copy Link', Colors.blue),
                _buildShareOption(Icons.facebook, 'Facebook', Colors.indigo),
                _buildShareOption(Icons.share, 'LinkedIn', Colors.cyan),
                _buildShareOption(Icons.telegram, 'Twitter', Colors.lightBlue),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sharing via $label...')));
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ============================================================================
// CERTIFICATE DATA MODEL
// ============================================================================
class _Certificate {
  final String title;
  final String subtitle;
  final String issueDate;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isMaster;
  final String level;
  final String achievements;
  final String mainLevelId;
  final String mainLevelName;

  _Certificate({
    required this.title,
    required this.subtitle,
    required this.issueDate,
    required this.icon,
    required this.gradientColors,
    required this.isMaster,
    required this.level,
    required this.achievements,
    required this.mainLevelId,
    required this.mainLevelName,
  });
}