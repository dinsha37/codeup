// main_level_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sub_level_screen.dart';

class MainLevelScreen extends StatefulWidget {
  const MainLevelScreen({Key? key}) : super(key: key);

  @override
  State<MainLevelScreen> createState() => _MainLevelScreenState();
}

class _MainLevelScreenState extends State<MainLevelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Main Levels'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('mainLevels')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final mainLevels = snapshot.data?.docs ?? [];

          if (mainLevels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Main Levels Yet',
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
            itemCount: mainLevels.length,
            itemBuilder: (context, index) {
              final doc = mainLevels[index];
              final data = doc.data() as Map<String, dynamic>;
              final levelName = data['name'] ?? 'Unnamed Level';
              final order = data['order'] ?? 0;

              return GestureDetector(
                onTap: () {
                  // Navigate to Sub Level Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminSubLevelScreen(
                        mainLevelId: doc.id,
                        mainLevelName: levelName,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getLevelColor(order).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.layers_rounded,
                          color: _getLevelColor(order),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              levelName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('subLevels')
                                  .where('mainLevelId', isEqualTo: doc.id)
                                  .snapshots(),
                              builder: (context, subSnapshot) {
                                final subCount =
                                    subSnapshot.data?.docs.length ?? 0;
                                return Text(
                                  '$subCount Sub Levels',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(doc.id, levelName, order);
                          } else if (value == 'delete') {
                            _showDeleteDialog(doc.id, levelName);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: Colors.blue),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Main Level'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Color _getLevelColor(int order) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[order % colors.length];
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final orderController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Main Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Level Name (e.g., Basic, Intermediate)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: orderController,
              decoration: const InputDecoration(
                labelText: 'Order (1, 2, 3...)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }

              await _firestore.collection('mainLevels').add({
                'name': nameController.text.trim(),
                'order': int.tryParse(orderController.text) ?? 1,
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Main level created!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String docId, String currentName, int currentOrder) {
    final nameController = TextEditingController(text: currentName);
    final orderController = TextEditingController(text: currentOrder.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Main Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Level Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: orderController,
              decoration: const InputDecoration(
                labelText: 'Order',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }

              await _firestore.collection('mainLevels').doc(docId).update({
                'name': nameController.text.trim(),
                'order': int.tryParse(orderController.text) ?? 1,
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Main level updated!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String docId, String levelName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Main Level'),
        content: Text(
          'Are you sure you want to delete "$levelName"?\n\nThis will also delete all sub-levels and questions under it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Delete all sub-levels and their questions
              final subLevels = await _firestore
                  .collection('subLevels')
                  .where('mainLevelId', isEqualTo: docId)
                  .get();

              for (var subDoc in subLevels.docs) {
                // Delete questions in this sub-level
                final questions = await _firestore
                    .collection('questions')
                    .where('subLevelId', isEqualTo: subDoc.id)
                    .get();

                for (var qDoc in questions.docs) {
                  await qDoc.reference.delete();
                }

                // Delete sub-level
                await subDoc.reference.delete();
              }

              // Delete main level
              await _firestore.collection('mainLevels').doc(docId).delete();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Main level deleted!')),
              );
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
}