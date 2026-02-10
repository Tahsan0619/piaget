import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/services/supabase_service.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final _supabase = SupabaseService();
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final teacherId = authProvider.currentUser?.id ?? '';

      final classes = await _supabase.getTeacherClasses(teacherId);

      // Load member count for each class
      for (var classData in classes) {
        final members = await _supabase.getClassMembers(classData['id']);
        classData['member_count'] = members.length;
      }

      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading classes: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _viewClassDetails(Map<String, dynamic> classData) async {
    final members = await _supabase.getClassMembers(classData['id']);
    
    // Fetch all student details once from v_student_details (avoids RLS nested join issues)
    final allStudents = await _supabase.getAllStudents(limit: 1000);
    final studentMap = <String, Map<String, dynamic>>{};
    for (final s in allStudents) {
      studentMap[s['id'] as String] = s;
    }
    
    // Enrich members with full details
    for (final member in members) {
      final studentId = member['student_id'] as String?;
      if (studentId != null && studentMap.containsKey(studentId)) {
        member['student_details'] = studentMap[studentId];
      }
    }
    
    debugPrint('📋 Enriched ${members.length} class members with details');

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classData['name'] ?? 'Unnamed Class',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (classData['description'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        classData['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        if (classData['grade_level'] != null)
                          Chip(
                            avatar: const Icon(Icons.school, size: 16),
                            label: Text('Grade ${classData['grade_level']}'),
                          ),
                        if (classData['academic_year'] != null)
                          Chip(
                            avatar: const Icon(Icons.calendar_today, size: 16),
                            label: Text(classData['academic_year']),
                          ),
                        Chip(
                          avatar: const Icon(Icons.people, size: 16),
                          label: Text('${members.length} students'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Members list
              Expanded(
                child: members.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No students in this class',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          
                          // Use enriched data from v_student_details view
                          final details = member['student_details'] as Map<String, dynamic>?;
                          final studentData = member['students'] as Map<String, dynamic>?;
                          
                          // Prefer v_student_details data, fall back to nested join
                          final name = details?['full_name'] ?? 'Unknown';
                          final email = details?['email'] ?? 'No email';
                          final age = details?['age']?.toString() ?? 
                                     studentData?['age']?.toString() ?? 'N/A';
                          final stage = details?['current_stage']?.toString();
                          final avgScore = details?['average_score']?.toDouble();
                          
                          debugPrint('👤 Student: $name, Email: $email, Age: $age');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade100,
                                child: Text(
                                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple.shade700,
                                  ),
                                ),
                              ),
                              title: Text(name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(email),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Age: $age',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (stage != null) ...[
                                        const SizedBox(width: 12),
                                        Text(
                                          stage.replaceAll('_', ' '),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.purple.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: avgScore != null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${avgScore.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      '$age yrs',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          );
                        },
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
        title: const Text('My Classes'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.class_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first class from the Student Browser',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadClasses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _classes.length,
                    itemBuilder: (context, index) {
                      final classData = _classes[index];
                      return _buildClassCard(classData);
                    },
                  ),
                ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    final name = classData['name'] ?? 'Unnamed Class';
    final description = classData['description'];
    final gradeLevel = classData['grade_level'];
    final academicYear = classData['academic_year'];
    final memberCount = classData['member_count'] ?? 0;
    final createdAt = classData['created_at'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _viewClassDetails(classData),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.class_,
                      color: Colors.deepPurple.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (description != null && description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.people,
                    label: '$memberCount students',
                    color: Colors.blue,
                  ),
                  if (gradeLevel != null)
                    _buildInfoChip(
                      icon: Icons.school,
                      label: 'Grade $gradeLevel',
                      color: Colors.green,
                    ),
                  if (academicYear != null)
                    _buildInfoChip(
                      icon: Icons.calendar_today,
                      label: academicYear,
                      color: Colors.orange,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
