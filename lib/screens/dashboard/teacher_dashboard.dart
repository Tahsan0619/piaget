import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/services/supabase_service.dart';
import 'package:piaget/widgets/animations.dart';
import 'package:piaget/utils/responsive.dart';
import 'package:piaget/screens/teacher/student_browser_screen.dart';
import 'package:piaget/screens/teacher/classes_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _supabase = SupabaseService();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _recentAssessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;

      if (userId != null) {
        debugPrint('📥 Loading dashboard data for teacher: $userId');
        
        final stats = await _supabase.getTeacherDashboardStats(userId);
        debugPrint('📊 Stats loaded: $stats');
        
        final students = await _supabase.getTeacherStudents(userId);
        debugPrint('👥 Students loaded: ${students.length} students');
        
        // Get recent assessments for teacher's students
        final assessments = <Map<String, dynamic>>[];
        for (final student in students.take(5)) {
          final studentAssessments = await _supabase.getStudentAssessments(
            student['id'] as String,
            limit: 2,
          );
          assessments.addAll(studentAssessments);
        }

        setState(() {
          _stats = stats;
          _students = students;
          _recentAssessments = assessments;
          _isLoading = false;
        });
        
        debugPrint('✅ Dashboard state updated');
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addNewStudent() async {
    // Show dialog to select from existing students
    try {
      // Get all students without teacher assignment
      final allStudents = await _supabase.getAllStudents(limit: 1000);
      
      debugPrint('📋 Loaded ${allStudents.length} students for selection');
      if (allStudents.isNotEmpty) {
        debugPrint('📋 First student sample: ${allStudents[0]}');
      }
      
      // Filter to show unassigned or show all (teacher can decide)
      final availableStudents = allStudents;

      if (!mounted) return;

      if (availableStudents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No students available to assign'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final selectedStudent = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _buildSelectStudentDialog(availableStudents),
      );

      if (selectedStudent != null && mounted) {
        debugPrint('✅ Student selected: $selectedStudent');
        debugPrint('🔑 User/Student ID (UUID): ${selectedStudent['id']}');
        debugPrint('🔑 School ID (TEXT): ${selectedStudent['student_id']}');
        
        // Assign the selected student to this teacher
        final authProvider = context.read<AuthProvider>();
        final teacherId = authProvider.currentUser?.id ?? '';
        
        // Use id (UUID) from v_student_details view, which is students.id
        final studentUuid = selectedStudent['id'] as String;
        
        debugPrint('🎯 Assigning student $studentUuid to teacher $teacherId');
        
        await _supabase.assignTeacherToStudent(
          studentUuid,
          teacherId,
        );
        
        debugPrint('✅ Student assigned, waiting for database consistency...');
        
        // Increased delay to ensure database consistency and replication
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          debugPrint('🔄 Reloading dashboard data...');
          
          // Reload dashboard data to update stats and student list
          await _loadDashboardData();
          
          debugPrint('📊 Dashboard reloaded. Stats: $_stats, Students: ${_students.length}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${selectedStudent['full_name']} added to your students!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSelectStudentDialog(List<Map<String, dynamic>> students) {
    final searchController = TextEditingController();
    final filteredStudents = <Map<String, dynamic>>[]..addAll(students);

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Select Student to Add'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search students',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    setState(() {
                      filteredStudents.clear();
                      if (query.isEmpty) {
                        filteredStudents.addAll(students);
                      } else {
                        filteredStudents.addAll(
                          students.where((s) =>
                            (s['full_name']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false) ||
                            (s['email']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false)
                          ),
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredStudents.isEmpty
                      ? const Center(child: Text('No students found'))
                      : ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final hasTeacher = student['assigned_teacher_id'] != null;
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade100,
                                child: Text(
                                  (student['full_name'] ?? 'U').substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.deepPurple.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(student['full_name'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student['email'] ?? 'No email'),
                                  if (hasTeacher)
                                    Text(
                                      'Already has a teacher',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Text('Age: ${student['age'] ?? 'N/A'}'),
                              onTap: () => Navigator.pop(context, student),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateClassDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final gradeController = TextEditingController();
    final yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Grade 3-A',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(
                  labelText: 'Grade Level',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 3',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Class name is required')),
                    );
                  }
                  return;
                }

                final authProvider = context.read<AuthProvider>();
                final teacherId = authProvider.currentUser?.id ?? '';

                await _supabase.createClass(
                  name: name,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  teacherId: teacherId,
                  gradeLevel:
                      gradeController.text.isEmpty ? null : gradeController.text,
                  academicYear:
                      yearController.text.isEmpty ? null : yearController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Class created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadDashboardData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAllStudents() async {
    final students = await _supabase.getTeacherStudents(
      context.read<AuthProvider>().currentUser?.id ?? '',
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('All Students'),
          content: SizedBox(
            width: double.maxFinite,
            child: students.isEmpty
                ? const Center(
                    child: Text('No students assigned yet'),
                  )
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return ListTile(
                        title: Text(student['full_name'] ?? 'Unknown'),
                        subtitle: Text(
                          'Age: ${student['age'] ?? "N/A"} | Grade: ${student['grade_level'] ?? "N/A"}',
                        ),
                        leading: CircleAvatar(
                          child: Text(
                            (student['full_name'] as String?)?.isNotEmpty == true
                                ? (student['full_name'] as String)
                                    .characters
                                    .first
                                : '?',
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(student['full_name'] ?? 'Student'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Email: ${student['email'] ?? "N/A"}'),
                                    const SizedBox(height: 8),
                                    Text('Age: ${student['age'] ?? "N/A"}'),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Grade: ${student['grade_level'] ?? "N/A"}'),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Status: ${student['is_active'] == true ? "Active" : "Inactive"}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            FadeInAnimation(
              child: Text(
                'Teacher Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),

            // Stats Cards
            _buildStatsCards(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // My Students Section
            _buildStudentsSection(),
            const SizedBox(height: 24),

            // Recent Assessments
            if (_recentAssessments.isNotEmpty) _buildRecentAssessments(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 44) / 2; // 2 cards per row
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: cardWidth,
          child: _buildStatCard(
            'Students',
            '${_stats?['my_students'] ?? 0}',
            Icons.people,
            Colors.blue,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildStatCard(
            'Classes',
            '${_stats?['my_classes'] ?? 0}',
            Icons.class_,
            Colors.purple,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildStatCard(
            'Assessments',
            '${_stats?['assessments_conducted'] ?? 0}',
            Icons.assignment,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return FadeInAnimation(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Add Student',
                  Icons.person_add,
                  Colors.green,
                  _addNewStudent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'View Students',
                  Icons.people,
                  Colors.blue,
                  () => _navigateToStudentBrowser(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'My Classes',
                  Icons.class_,
                  Colors.purple,
                  () => _navigateToClasses(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Create Class',
                  Icons.add_circle,
                  Colors.orange,
                  _showCreateClassDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToStudentBrowser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentBrowserScreen(),
      ),
    );
    
    // Reload dashboard if a class was created
    if (result == true) {
      _loadDashboardData();
    }
  }

  Future<void> _navigateToClasses() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ClassesScreen(),
      ),
    );
    
    // Reload dashboard data when returning
    _loadDashboardData();
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsSection() {
    if (_students.isEmpty) {
      return FadeInAnimation(
        delay: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No students assigned yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Add your first student to get started!',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'My Students',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: _showAllStudents,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('View All', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _students.take(5).length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildStudentCard(_students[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final name = student['full_name'] ?? 'Unknown';
    final age = student['age'];
    final gradeLevel = student['grade_level'] ?? 'N/A';
    final assessmentsCount = student['total_assessments_taken'] ?? 0;
    final averageScore = student['average_score']?.toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Age: $age | Grade: $gradeLevel',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$assessmentsCount assessments',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (averageScore != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${averageScore.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Avg',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentAssessments() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Student Assessments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _recentAssessments.take(5).length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAssessmentCard(_recentAssessments[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    final studentName = assessment['student_name'] ?? 'Unknown';
    final stage = assessment['stage'] ?? 'N/A';
    final status = assessment['status'] ?? 'unknown';
    final score = assessment['overall_score']?.toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: status == 'completed' ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              status == 'completed' ? Icons.check_circle : Icons.pending,
              color: status == 'completed' ? Colors.green.shade700 : Colors.orange.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.toString().replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (score != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${score.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
