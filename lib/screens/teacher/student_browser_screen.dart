import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/services/supabase_service.dart';
import 'package:piaget/utils/responsive.dart';

class StudentBrowserScreen extends StatefulWidget {
  const StudentBrowserScreen({super.key});

  @override
  State<StudentBrowserScreen> createState() => _StudentBrowserScreenState();
}

class _StudentBrowserScreenState extends State<StudentBrowserScreen> {
  final _supabase = SupabaseService();
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  final Set<String> _selectedStudentIds = {};
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    try {
      // Get all students (admin can see all, teachers see their assigned students)
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      List<Map<String, dynamic>> students;
      if (currentUser?.role.name == 'admin') {
        students = await _supabase.getAllStudents(limit: 1000);
      } else {
        // For teachers, show all students but highlight their assigned ones
        students = await _supabase.getAllStudents(limit: 1000);
      }

      debugPrint('📋 Loaded ${students.length} students from database');
      if (students.isNotEmpty) {
        debugPrint('📋 Sample: id(UUID)=${students[0]['id']}, student_id(TEXT)=${students[0]['student_id']}');
      }
      
      // Get progress data for each student
      for (var student in students) {
        try {
          // Use id (UUID) which is the students table primary key
          final progress = await _supabase.getStudentProgress(student['id']);
          student['progress'] = progress;
        } catch (e) {
          student['progress'] = null;
        }
      }

      setState(() {
        _allStudents = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading students: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((student) {
          final name = (student['full_name'] ?? '').toString().toLowerCase();
          final email = (student['email'] ?? '').toString().toLowerCase();
          final stage = (student['progress']?['current_stage'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery) ||
              email.contains(_searchQuery) ||
              stage.contains(_searchQuery);
        }).toList();
      }
    });
  }

  void _toggleStudentSelection(String studentId) {
    setState(() {
      if (_selectedStudentIds.contains(studentId)) {
        _selectedStudentIds.remove(studentId);
      } else {
        _selectedStudentIds.add(studentId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      // Use id (UUID) which is the students table primary key
      _selectedStudentIds.addAll(_filteredStudents.map((s) => s['id'] as String));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedStudentIds.clear();
    });
  }

  Future<void> _createClassWithSelectedStudents() async {
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one student'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _buildCreateClassDialog(),
    );

    if (result != null && mounted) {
      try {
        final authProvider = context.read<AuthProvider>();
        final teacherId = authProvider.currentUser?.id ?? '';

        // Create the class
        final classId = await _supabase.createClass(
          name: result['name'] as String,
          description: result['description'] as String?,
          teacherId: teacherId,
          gradeLevel: result['gradeLevel'] as String?,
          academicYear: result['academicYear'] as String?,
        );

        // Add selected students to the class
        for (final studentId in _selectedStudentIds) {
          await _supabase.addStudentToClass(classId, studentId);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Class "${result['name']}" created with ${_selectedStudentIds.length} students!'),
              backgroundColor: Colors.green,
            ),
          );
          _clearSelection();
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating class: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildCreateClassDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final gradeController = TextEditingController();
    final yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );

    return AlertDialog(
      title: const Text('Create New Class'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedStudentIds.length} students selected',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Class Name *',
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
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Class name is required')),
              );
              return;
            }

            Navigator.pop(context, {
              'name': name,
              'description': descriptionController.text.isEmpty
                  ? null
                  : descriptionController.text,
              'gradeLevel':
                  gradeController.text.isEmpty ? null : gradeController.text,
              'academicYear':
                  yearController.text.isEmpty ? null : yearController.text,
            });
          },
          child: const Text('Create Class'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          if (_selectedStudentIds.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear selection',
              onPressed: _clearSelection,
            ),
            IconButton(
              icon: Badge(
                label: Text('${_selectedStudentIds.length}'),
                child: const Icon(Icons.group_add),
              ),
              tooltip: 'Create class with selected students',
              onPressed: _createClassWithSelectedStudents,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _filterStudents,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or stage...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              _filterStudents('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_filteredStudents.length} students found',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_filteredStudents.isNotEmpty) ...[
                      TextButton(
                        onPressed: _selectAll,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Select All'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Students list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No students found'
                                  : 'No students match your search',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return _buildStudentCard(student);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedStudentIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _createClassWithSelectedStudents,
              icon: const Icon(Icons.class_),
              label: Text('Create Class (${_selectedStudentIds.length})'),
              backgroundColor: Colors.deepPurple,
            )
          : null,
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    // Use id (UUID) which is the students table primary key
    final studentId = student['id'] as String;
    final isSelected = _selectedStudentIds.contains(studentId);
    final fullName = student['full_name'] ?? 'Unknown';
    final email = student['email'] ?? 'No email';
    final age = student['age']?.toString() ?? 'N/A';
    final progress = student['progress'] as Map<String, dynamic>?;
    
    final currentStage = progress?['current_stage']?.toString() ?? 'Not assessed';
    final averageScore = progress?['average_score']?.toDouble();
    final totalAssessments = progress?['total_assessments_completed'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: Colors.deepPurple, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _toggleStudentSelection(studentId),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection checkbox
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleStudentSelection(studentId),
                activeColor: Colors.deepPurple,
              ),
              const SizedBox(width: 12),

              // Student avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  fullName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                          icon: Icons.cake,
                          label: '$age yrs',
                          color: Colors.blue,
                        ),
                        _buildInfoChip(
                          icon: Icons.psychology,
                          label: _formatStage(currentStage),
                          color: Colors.purple,
                        ),
                        if (averageScore != null)
                          _buildInfoChip(
                            icon: Icons.star,
                            label: '${averageScore.toStringAsFixed(0)}%',
                            color: Colors.amber,
                          ),
                        _buildInfoChip(
                          icon: Icons.assignment,
                          label: '$totalAssessments tests',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  String _formatStage(String stage) {
    if (stage == 'Not assessed') return stage;
    return stage
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
