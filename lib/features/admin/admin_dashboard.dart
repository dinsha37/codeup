import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class User {
  final int id;
  String name;
  String email;
  String role;
  String status;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}

class SubLevel {
  final int id;
  final String name;
  final List<String> questions;

  SubLevel({required this.id, required this.name, required this.questions});
}

class Level {
  final int id;
  final String name;
  final List<SubLevel> subLevels;

  Level({required this.id, required this.name, required this.subLevels});
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String activeTab = 'dashboard';

  List<User> users = [
    User(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      role: 'student',
      status: 'active',
    ),
    User(
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'teacher',
      status: 'active',
    ),
  ];

  final List<Level> levels = [
    Level(
      id: 1,
      name: 'Level 1',
      subLevels: [
        SubLevel(
          id: 1,
          name: 'Sub 1.1',
          questions: ['Q1', 'Q2', 'Q3', 'Q4', 'Q5'],
        ),
        SubLevel(
          id: 2,
          name: 'Sub 1.2',
          questions: ['Q6', 'Q7', 'Q8', 'Q9', 'Q10'],
        ),
        SubLevel(
          id: 3,
          name: 'Sub 1.3',
          questions: ['Q11', 'Q12', 'Q13', 'Q14', 'Q15'],
        ),
      ],
    ),
    Level(
      id: 2,
      name: 'Level 2',
      subLevels: [
        SubLevel(
          id: 4,
          name: 'Sub 2.1',
          questions: ['Q16', 'Q17', 'Q18', 'Q19', 'Q20'],
        ),
        SubLevel(
          id: 5,
          name: 'Sub 2.2',
          questions: ['Q21', 'Q22', 'Q23', 'Q24', 'Q25'],
        ),
        SubLevel(
          id: 6,
          name: 'Sub 2.3',
          questions: ['Q26', 'Q27', 'Q28', 'Q29', 'Q30'],
        ),
      ],
    ),
    Level(
      id: 3,
      name: 'Level 3',
      subLevels: [
        SubLevel(
          id: 7,
          name: 'Sub 3.1',
          questions: ['Q31', 'Q32', 'Q33', 'Q34', 'Q35'],
        ),
        SubLevel(
          id: 8,
          name: 'Sub 3.2',
          questions: ['Q36', 'Q37', 'Q38', 'Q39', 'Q40'],
        ),
        SubLevel(
          id: 9,
          name: 'Sub 3.3',
          questions: ['Q41', 'Q42', 'Q43', 'Q44', 'Q45'],
        ),
      ],
    ),
  ];

  int get totalQuestions {
    return levels.fold(
      0,
      (sum, level) =>
          sum +
          level.subLevels.fold(
            0,
            (subSum, subLevel) => subSum + subLevel.questions.length,
          ),
    );
  }

  void openUserModal({User? user}) {
    showDialog(
      context: context,
      builder: (context) => UserModal(
        user: user,
        onSave: (name, email, role) {
          setState(() {
            if (user != null) {
              user.name = name;
              user.email = email;
              user.role = role;
            } else {
              users.add(
                User(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: name,
                  email: email,
                  role: role,
                  status: 'active',
                ),
              );
            }
          });
        },
      ),
    );
  }

  void deleteUser(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                users.removeWhere((u) => u.id == id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF1F2937),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildNavButton('dashboard', Icons.bar_chart, 'Dashboard'),
                _buildNavButton('users', Icons.people, 'Users'),
                _buildNavButton('levels', Icons.book, 'Levels'),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        activeTab[0].toUpperCase() + activeTab.substring(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    color: const Color(0xFFF3F4F6),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String tab, IconData icon, String label) {
    final isActive = activeTab == tab;
    return InkWell(
      onTap: () => setState(() => activeTab = tab),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (activeTab) {
      case 'dashboard':
        return _buildDashboard();
      case 'users':
        return _buildUsers();
      case 'levels':
        return _buildLevels();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDashboard() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Total Users',
          users.length.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Levels',
          levels.length.toString(),
          Icons.book,
          Colors.green,
        ),
        _buildStatCard('Sub-levels', '9', Icons.library_books, Colors.purple),
        _buildStatCard(
          'Questions',
          totalQuestions.toString(),
          Icons.quiz,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, size: 40, color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => openUserModal(),
          icon: const Icon(Icons.add),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF9FAFB),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'NAME',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'EMAIL',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'ROLE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'ACTIONS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              rows: users.map((user) {
                return DataRow(
                  cells: [
                    DataCell(Text(user.name)),
                    DataCell(Text(user.email)),
                    DataCell(_buildRoleBadge(user.role)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.blue,
                            ),
                            onPressed: () => openUserModal(user: user),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () => deleteUser(user.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bgColor;
    Color textColor;

    switch (role) {
      case 'admin':
        bgColor = const Color(0xFFEDE9FE);
        textColor = const Color(0xFF7C3AED);
        break;
      case 'teacher':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        break;
      default:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLevels() {
    return Column(
      children: levels.map((level) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: level.subLevels.length,
                itemBuilder: (context, index) {
                  final subLevel = level.subLevels[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subLevel.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${subLevel.questions.length} questions',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: subLevel.questions.length,
                            itemBuilder: (context, qIndex) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  subLevel.questions[qIndex],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class UserModal extends StatefulWidget {
  final User? user;
  final Function(String name, String email, String role) onSave;

  const UserModal({super.key, this.user, required this.onSave});

  @override
  State<UserModal> createState() => _UserModalState();
}

class _UserModalState extends State<UserModal> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?.name ?? '');
    emailController = TextEditingController(text: widget.user?.email ?? '');
    selectedRole = widget.user?.role ?? 'student';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
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
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                emailController.text.isNotEmpty) {
              widget.onSave(
                nameController.text,
                emailController.text,
                selectedRole,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
