import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/models/assessment_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  bool get isInitialized => _client != null;

  // Initialize Supabase
  Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase credentials not found in .env file');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _client = Supabase.instance.client;
  }

  // ============================================
  // AUTHENTICATION METHODS
  // ============================================

  /// Sign up a new user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.name,
          ...?additionalData,
        },
      );

      if (response.user != null) {
        // Create user profile in users table
        await client.from('users').insert({
          'auth_id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role.name,
        });

        // Create role-specific profile
        await _createRoleSpecificProfile(
          response.user!.id,
          role,
          additionalData ?? {},
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 SupabaseService.signIn - Attempting authentication');
      debugPrint('🔐 Email: $email');
      
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      debugPrint('🔐 Auth response received');
      debugPrint('🔐 User: ${response.user?.email}');
      debugPrint('🔐 Session: ${response.session != null}');
      
      return response;
    } catch (e) {
      debugPrint('❌ signIn error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Get current user
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Create role-specific profile
  Future<void> _createRoleSpecificProfile(
    String userId,
    UserRole role,
    Map<String, dynamic> data,
  ) async {
    // First get the user's id from users table
    final userResponse = await client
        .from('users')
        .select('id')
        .eq('auth_id', userId)
        .single();

    final userIdFromTable = userResponse['id'] as String;

    switch (role) {
      case UserRole.student:
        await client.from('students').insert({
          'id': userIdFromTable,
          'student_id': data['student_id'] ?? 'STD${DateTime.now().millisecondsSinceEpoch}',
          'age': data['age'],
          'grade_level': data['grade_level'],
          'class_name': data['class_name'],
        });
        break;
      case UserRole.teacher:
        await client.from('teachers').insert({
          'id': userIdFromTable,
          'teacher_id': data['teacher_id'] ?? 'TCH${DateTime.now().millisecondsSinceEpoch}',
          'department': data['department'],
          'specialization': data['specialization'],
        });
        break;
      case UserRole.admin:
        await client.from('admins').insert({
          'id': userIdFromTable,
          'admin_id': data['admin_id'] ?? 'ADM${DateTime.now().millisecondsSinceEpoch}',
          'department': data['department'],
          'permission_level': 1,
        });
        break;
      case UserRole.parent:
        // For parents, we can use the base user profile
        break;
    }
  }

  // ============================================
  // USER PROFILE METHODS
  // ============================================

  /// Get user profile by auth ID
  Future<UserProfile?> getUserProfile(String authId) async {
    try {
      debugPrint('🔍 SupabaseService.getUserProfile - Fetching profile');
      debugPrint('🔍 Auth ID: $authId');
      
      final response = await client
          .from('users')
          .select()
          .eq('auth_id', authId)
          .single();

      debugPrint('🔍 Raw response: $response');
      debugPrint('🔍 Role in response: ${response['role']}');
      debugPrint('🔍 Email in response: ${response['email']}');
      debugPrint('🔍 Is active: ${response['is_active']}');

      final profile = UserProfile.fromJson(response);
      debugPrint('🔍 Profile created successfully');
      debugPrint('🔍 Profile type: ${profile.runtimeType}');
      
      return profile;
    } catch (e, stackTrace) {
      debugPrint('❌ getUserProfile error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get user profile by user ID
  Future<Map<String, dynamic>?> getUserProfileById(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    await client
        .from('users')
        .update(updates)
        .eq('id', userId);
  }

  /// Update last login time
  Future<void> updateLastLogin(String userId) async {
    await client
        .from('users')
        .update({'last_login': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }

  // ============================================
  // STUDENT METHODS
  // ============================================

  /// Get student profile with details
  Future<Map<String, dynamic>?> getStudentProfile(String studentId) async {
    try {
      final response = await client
          .from('v_student_details')
          .select()
          .eq('id', studentId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Get all students (for teachers/admins)
  Future<List<Map<String, dynamic>>> getAllStudents({
    String? teacherId,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = client.from('v_student_details').select();

    if (teacherId != null) {
      query = query.eq('assigned_teacher_id', teacherId);
    }

    final response = await query
        .order('full_name')
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Update student profile
  Future<void> updateStudentProfile(
    String studentId,
    Map<String, dynamic> updates,
  ) async {
    await client
        .from('students')
        .update(updates)
        .eq('id', studentId);
  }

  /// Assign teacher to student
  Future<void> assignTeacherToStudent(String studentId, String teacherId) async {
    debugPrint('🔄 Assigning teacher $teacherId to student $studentId');
    
    try {
      // Use RPC function which has SECURITY DEFINER (bypasses RLS)
      await client.rpc('assign_student_to_teacher', params: {
        'p_student_id': studentId,
        'p_teacher_id': teacherId,
      });
      
      debugPrint('✅ Teacher assignment completed via RPC');
    } catch (e) {
      debugPrint('⚠️ RPC failed ($e), trying direct update...');
      
      // Fallback to direct update
      final response = await client
          .from('students')
          .update({'assigned_teacher_id': teacherId})
          .eq('id', studentId)
          .select();
      
      debugPrint('✅ Direct update response: $response');
    }
  }

  // ============================================
  // TEACHER METHODS
  // ============================================

  /// Get teacher profile
  Future<Map<String, dynamic>?> getTeacherProfile(String teacherId) async {
    try {
      final userResponse = await client
          .from('users')
          .select()
          .eq('id', teacherId)
          .single();

      final teacherResponse = await client
          .from('teachers')
          .select()
          .eq('id', teacherId)
          .single();

      return {
        ...userResponse,
        ...teacherResponse,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get all teachers (for admins)
  Future<List<Map<String, dynamic>>> getAllTeachers({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await client
        .from('users')
        .select('*, teachers(*)')
        .eq('role', 'teacher')
        .order('full_name')
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get students assigned to teacher
  Future<List<Map<String, dynamic>>> getTeacherStudents(String teacherId) async {
    final response = await client
        .from('v_student_details')
        .select()
        .eq('assigned_teacher_id', teacherId)
        .order('full_name');

    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================
  // ADMIN METHODS
  // ============================================

  /// Get admin profile
  Future<Map<String, dynamic>?> getAdminProfile(String adminId) async {
    try {
      final userResponse = await client
          .from('users')
          .select()
          .eq('id', adminId)
          .single();

      final adminResponse = await client
          .from('admins')
          .select()
          .eq('id', adminId)
          .single();

      return {
        ...userResponse,
        ...adminResponse,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get all users (for admins)
  Future<List<Map<String, dynamic>>> getAllUsers({
    UserRole? role,
    int limit = 100,
    int offset = 0,
  }) async {
    var query = client.from('users').select();

    if (role != null) {
      query = query.eq('role', role.name);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Delete user (admin only)
  Future<void> deleteUser(String userId) async {
    await client
        .from('users')
        .delete()
        .eq('id', userId);
  }

  /// Toggle user active status
  Future<void> toggleUserActiveStatus(String userId, bool isActive) async {
    await client
        .from('users')
        .update({'is_active': isActive})
        .eq('id', userId);
  }

  // ============================================
  // ASSESSMENT METHODS
  // ============================================

  /// Create assessment session
  Future<String> createAssessmentSession({
    String? sessionId,
    required String studentId,
    String? teacherId,
    String? classId,
    required String stage,
    required String title,
    String? description,
  }) async {
    final data = {
      'student_id': studentId,
      'teacher_id': teacherId,
      'class_id': classId,
      'stage': stage,
      'title': title,
      'description': description,
      'status': 'in_progress',
    };
    
    // Include id if provided, otherwise let database generate it
    if (sessionId != null) {
      data['id'] = sessionId;
    }
    
    final response = await client.from('assessment_sessions').insert(data).select().single();

    return response['id'] as String;
  }

  /// Add questions to assessment session
  Future<void> addQuestionsToSession(
    String sessionId,
    List<Question> questions,
  ) async {
    final questionsData = questions.asMap().entries.map((entry) {
      final index = entry.key;
      final q = entry.value;
      return {
        'session_id': sessionId,
        'question_text': q.text,
        'criterion': q.criterion,
        'stage': q.stage,
        'response_type': q.responseType.name,
        'options': q.options,
        'correct_answer': q.correctAnswer,
        'scoring_rules': q.scoringRules,
        'order_index': index,
      };
    }).toList();

    await client.from('assessment_questions').insert(questionsData);
  }

  /// Submit question response
  Future<void> submitQuestionResponse({
    required String questionId,
    required String sessionId,
    required String answer,
    required int timeSpentSeconds,
    bool? isCorrect,
  }) async {
    await client.from('question_responses').insert({
      'question_id': questionId,
      'session_id': sessionId,
      'answer': answer,
      'time_spent_seconds': timeSpentSeconds,
      'is_correct': isCorrect,
    });
  }

  /// Complete assessment session
  Future<void> completeAssessmentSession(
    String sessionId,
    int durationSeconds,
  ) async {
    await client.from('assessment_sessions').update({
      'completed_at': DateTime.now().toIso8601String(),
      'duration_seconds': durationSeconds,
      'status': 'completed',
    }).eq('id', sessionId);
  }

  /// Save assessment result
  Future<String> saveAssessmentResult({
    required String sessionId,
    required String studentId,
    required String identifiedStage,
    required double overallScore,
    required List<String> strengths,
    required List<String> developmentAreas,
    required List<String> suggestedActivities,
    Map<String, dynamic>? detailedFeedback,
    Map<String, dynamic>? criteriaResults,
  }) async {
    final response = await client.from('assessment_results').insert({
      'session_id': sessionId,
      'student_id': studentId,
      'identified_stage': identifiedStage,
      'overall_score': overallScore,
      'strengths': strengths,
      'development_areas': developmentAreas,
      'suggested_activities': suggestedActivities,
      'detailed_feedback': detailedFeedback,
      'criteria_results': criteriaResults,
    }).select().single();

    return response['id'] as String;
  }

  /// Get assessment sessions for student
  Future<List<Map<String, dynamic>>> getStudentAssessments(
    String studentId, {
    int limit = 20,
  }) async {
    final response = await client
        .from('v_assessment_summary')
        .select()
        .eq('student_id', studentId)
        .order('started_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get assessment session details
  Future<Map<String, dynamic>?> getAssessmentSession(String sessionId) async {
    try {
      final sessionResponse = await client
          .from('assessment_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      final questionsResponse = await client
          .from('assessment_questions')
          .select()
          .eq('session_id', sessionId)
          .order('order_index');

      return {
        ...sessionResponse,
        'questions': questionsResponse,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get assessment result
  Future<Map<String, dynamic>?> getAssessmentResult(String sessionId) async {
    try {
      final response = await client
          .from('assessment_results')
          .select()
          .eq('session_id', sessionId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Get student progress
  Future<Map<String, dynamic>?> getStudentProgress(String studentId) async {
    try {
      final response = await client
          .from('student_progress')
          .select()
          .eq('student_id', studentId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // CLASS MANAGEMENT METHODS
  // ============================================

  /// Create a class
  Future<String> createClass({
    required String name,
    String? description,
    required String teacherId,
    String? gradeLevel,
    String? academicYear,
  }) async {
    final response = await client.from('classes').insert({
      'name': name,
      'description': description,
      'teacher_id': teacherId,
      'grade_level': gradeLevel,
      'academic_year': academicYear,
    }).select().single();

    return response['id'] as String;
  }

  /// Get classes for teacher
  Future<List<Map<String, dynamic>>> getTeacherClasses(String teacherId) async {
    final response = await client
        .from('classes')
        .select()
        .eq('teacher_id', teacherId)
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Add student to class
  Future<void> addStudentToClass(String classId, String studentId) async {
    await client.from('class_members').insert({
      'class_id': classId,
      'student_id': studentId,
    });
  }

  /// Get class members
  Future<List<Map<String, dynamic>>> getClassMembers(String classId) async {
    final response = await client
        .from('class_members')
        .select('*, students!class_members_student_id_fkey(*, users!students_id_fkey(*))')
        .eq('class_id', classId)
        .eq('is_active', true);

    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================
  // NOTIFICATION METHODS
  // ============================================

  /// Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    await client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
    });
  }

  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(
    String userId, {
    bool? isRead,
    int limit = 50,
  }) async {
    var query = client
        .from('notifications')
        .select()
        .eq('user_id', userId);

    if (isRead != null) {
      query = query.eq('is_read', isRead);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await client.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    await client.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId).eq('is_read', false);
  }

  // ============================================
  // ACTIVITY LOG METHODS
  // ============================================

  /// Log activity
  Future<void> logActivity({
    required String userId,
    required String action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? details,
  }) async {
    await client.from('activity_logs').insert({
      'user_id': userId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'details': details,
    });
  }

  /// Get user activity logs
  Future<List<Map<String, dynamic>>> getUserActivityLogs(
    String userId, {
    int limit = 50,
  }) async {
    final response = await client
        .from('activity_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================
  // STATISTICS & ANALYTICS METHODS
  // ============================================

  /// Get dashboard statistics for admin
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      debugPrint('📊 Admin Stats: Starting to fetch dashboard stats...');
      
      // Count students from users table (avoids RLS on students table)
      int studentCount = 0;
      try {
        final sc = await client.from('users').select('id').eq('role', 'student').count();
        studentCount = sc.count;
        debugPrint('📊 Students count: $studentCount');
      } catch (e) {
        debugPrint('❌ Error counting students: $e');
      }

      // Count teachers from users table
      int teacherCount = 0;
      try {
        final tc = await client.from('users').select('id').eq('role', 'teacher').count();
        teacherCount = tc.count;
        debugPrint('📊 Teachers count: $teacherCount');
      } catch (e) {
        debugPrint('❌ Error counting teachers: $e');
      }

      // Count assessments
      int assessmentCount = 0;
      try {
        final ac = await client.from('assessment_sessions').select('id').count();
        assessmentCount = ac.count;
        debugPrint('📊 Assessments count: $assessmentCount');
      } catch (e) {
        debugPrint('❌ Error counting assessments: $e');
      }

      // Count completed assessments
      int completedCount = 0;
      try {
        final cc = await client.from('assessment_sessions').select('id').eq('status', 'completed').count();
        completedCount = cc.count;
        debugPrint('📊 Completed assessments count: $completedCount');
      } catch (e) {
        debugPrint('❌ Error counting completed assessments: $e');
      }

      final stats = {
        'total_students': studentCount,
        'total_teachers': teacherCount,
        'total_assessments': assessmentCount,
        'completed_assessments': completedCount,
      };
      debugPrint('📊 Final admin stats: $stats');
      return stats;
    } catch (e) {
      debugPrint('❌ Error getting admin stats: $e');
      return {
        'total_students': 0,
        'total_teachers': 0,
        'total_assessments': 0,
        'completed_assessments': 0,
      };
    }
  }

  /// Get dashboard statistics for teacher
  Future<Map<String, dynamic>> getTeacherDashboardStats(String teacherId) async {
    try {
      debugPrint('📊 Fetching stats for teacher: $teacherId');
      
      // First, let's see what students exist with this teacher
      final studentsDebug = await client
          .from('students')
          .select('id, assigned_teacher_id')
          .eq('assigned_teacher_id', teacherId);
      
      debugPrint('🔍 Students found with teacher $teacherId: $studentsDebug');
      
      final studentsCount = await client
          .from('students')
          .select('id')
          .eq('assigned_teacher_id', teacherId)
          .count();

      debugPrint('👥 Students count: ${studentsCount.count}');

      final classesCount = await client
          .from('classes')
          .select('id')
          .eq('teacher_id', teacherId)
          .eq('is_active', true)
          .count();

      final assessmentsCount = await client
          .from('assessment_sessions')
          .select('id')
          .eq('teacher_id', teacherId)
          .count();

      final result = {
        'my_students': studentsCount.count,
        'my_classes': classesCount.count,
        'assessments_conducted': assessmentsCount.count,
      };
      
      debugPrint('📈 Stats result: $result');
      
      return result;
    } catch (e) {
      debugPrint('Error getting teacher stats: $e');
      return {
        'my_students': 0,
        'my_classes': 0,
        'assessments_conducted': 0,
      };
    }
  }

  /// Get dashboard statistics for student
  Future<Map<String, dynamic>> getStudentDashboardStats(String studentId) async {
    try {
      final assessmentsCount = await client
          .from('assessment_sessions')
          .select('id')
          .eq('student_id', studentId)
          .count();

      final completedAssessments = await client
          .from('assessment_sessions')
          .select('id')
          .eq('student_id', studentId)
          .eq('status', 'completed')
          .count();

      final progress = await getStudentProgress(studentId);

      return {
        'total_assessments': assessmentsCount.count,
        'completed_assessments': completedAssessments.count,
        'current_stage': progress?['current_stage'],
        'average_score': progress?['average_score'],
      };
    } catch (e) {
      debugPrint('Error getting student stats: $e');
      return {
        'total_assessments': 0,
        'completed_assessments': 0,
        'current_stage': null,
        'average_score': null,
      };
    }
  }

  // ============================================
  // STORAGE METHODS (Profile Images)
  // ============================================

  /// Upload user profile image to storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final storagePath = 'avatars/$userId/$fileName';

      // Upload file to storage
      await client.storage.from('avatars').uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl =
          client.storage.from('avatars').getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      rethrow;
    }
  }

  /// Delete user profile image from storage
  Future<void> deleteProfileImage({
    required String userId,
    required String fileName,
  }) async {
    try {
      await client.storage
          .from('avatars')
          .remove(['avatars/$userId/$fileName']);
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      rethrow;
    }
  }

  /// Clean up old profile images (keep only latest)
  Future<void> cleanupOldProfileImages(String userId) async {
    try {
      final files = await client.storage.from('avatars').list(path: userId);

      // Keep latest image, delete others
      if (files.length > 1) {
        files.sort((a, b) {
          final aTime = a.createdAt ?? '';
          final bTime = b.createdAt ?? '';
          return bTime.compareTo(aTime);
        });

        // Delete all but the latest
        for (int i = 1; i < files.length; i++) {
          await client.storage
              .from('avatars')
              .remove(['avatars/$userId/${files[i].name}']);
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old profile images: $e');
      // Don't rethrow - this is optional cleanup
    }
  }

  // ============================================
  // STUDENT PROGRESS METHODS
  // ============================================

  /// Update or create student progress record
  Future<void> updateStudentProgress({
    required String studentId,
    required String currentStage,
    required double averageScore,
  }) async {
    try {
      debugPrint('\n📊 ========== UPDATING STUDENT PROGRESS ==========');
      debugPrint('👤 Student ID: $studentId');
      debugPrint('🎯 Current Stage: $currentStage');
      debugPrint('📈 Average Score: $averageScore');

      // Check if progress record exists
      final existingProgress = await client
          .from('student_progress')
          .select()
          .eq('student_id', studentId)
          .maybeSingle();

      if (existingProgress != null) {
        debugPrint('✏️ Updating existing progress record...');
        // Update existing record
        await client.from('student_progress').update({
          'current_stage': currentStage,
          'average_score': averageScore,
          'last_assessment_date': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('student_id', studentId);
        debugPrint('✅ Progress record updated successfully');
      } else {
        debugPrint('➕ Creating new progress record...');
        // Create new record
        await client.from('student_progress').insert({
          'student_id': studentId,
          'current_stage': currentStage,
          'average_score': averageScore,
          'last_assessment_date': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Progress record created successfully');
      }

      debugPrint('📊 ================================================\n');
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating student progress: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Save complete assessment to database
  Future<void> saveCompleteAssessment({
    required String sessionId,
    required String studentId,
    required String identifiedStage,
    required double overallScore,
    required List<String> strengths,
    required List<String> developmentAreas,
    required List<String> suggestedActivities,
    required int durationSeconds,
    Map<String, dynamic>? criteriaResults,
  }) async {
    try {
      debugPrint('\n💾 ========== SAVING ASSESSMENT TO DATABASE ==========');
      debugPrint('🆔 Session ID: $sessionId');
      debugPrint('👤 Student ID: $studentId');
      debugPrint('🎯 Stage: $identifiedStage');
      debugPrint('📊 Score: $overallScore');

      // 1. Complete the assessment session
      debugPrint('\n1️⃣ Updating assessment session status...');
      await completeAssessmentSession(sessionId, durationSeconds);
      debugPrint('✅ Session marked as completed');

      // 2. Save assessment results
      debugPrint('\n2️⃣ Saving assessment results...');
      final resultId = await saveAssessmentResult(
        sessionId: sessionId,
        studentId: studentId,
        identifiedStage: identifiedStage,
        overallScore: overallScore,
        strengths: strengths,
        developmentAreas: developmentAreas,
        suggestedActivities: suggestedActivities,
        criteriaResults: criteriaResults,
      );
      debugPrint('✅ Result saved with ID: $resultId');

      // 3. Update student progress
      debugPrint('\n3️⃣ Updating student progress...');
      await updateStudentProgress(
        studentId: studentId,
        currentStage: identifiedStage,
        averageScore: overallScore,
      );
      debugPrint('✅ Student progress updated');

      debugPrint('\n💾 ========== ASSESSMENT SAVED SUCCESSFULLY ==========\n');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving complete assessment: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }
}

