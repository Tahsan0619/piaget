enum UserRole { student, teacher, admin }

class UserProfile {
  final String id;
  final String? authId;
  final String name;
  final UserRole role;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    this.authId,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.isActive = true,
    this.lastLogin,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      name: json['full_name'] as String? ?? json['name'] as String,
      role: UserRole.values.byName(json['role'] as String),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'auth_id': authId,
        'full_name': name,
        'name': name,
        'role': role.name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'is_active': isActive,
        'last_login': lastLogin?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  UserProfile copyWith({
    String? id,
    String? authId,
    String? name,
    UserRole? role,
    String? email,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StudentProfile extends UserProfile {
  final String studentId;
  final int? age;
  final String? gradeLevel;
  final String? className;
  final String? assignedTeacherId;
  final String? teacherName;
  final String? parentEmail;
  final String? parentPhone;
  final String? specialNeeds;
  final String? notes;

  StudentProfile({
    required super.id,
    super.authId,
    required super.name,
    super.email,
    super.phone,
    super.avatarUrl,
    super.dateOfBirth,
    super.isActive,
    super.lastLogin,
    super.createdAt,
    required this.studentId,
    this.age,
    this.gradeLevel,
    this.className,
    this.assignedTeacherId,
    this.teacherName,
    this.parentEmail,
    this.parentPhone,
    this.specialNeeds,
    this.notes,
  }) : super(role: UserRole.student);

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      name: json['full_name'] as String? ?? json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      studentId: json['student_id'] as String,
      age: json['age'] as int?,
      gradeLevel: json['grade_level'] as String?,
      className: json['class_name'] as String?,
      assignedTeacherId: json['assigned_teacher_id'] as String?,
      teacherName: json['teacher_name'] as String?,
      parentEmail: json['parent_email'] as String?,
      parentPhone: json['parent_phone'] as String?,
      specialNeeds: json['special_needs'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'student_id': studentId,
      'age': age,
      'grade_level': gradeLevel,
      'class_name': className,
      'assigned_teacher_id': assignedTeacherId,
      'teacher_name': teacherName,
      'parent_email': parentEmail,
      'parent_phone': parentPhone,
      'special_needs': specialNeeds,
      'notes': notes,
    });
    return json;
  }
}

class TeacherProfile extends UserProfile {
  final String teacherId;
  final String? department;
  final String? specialization;
  final String? qualification;
  final int? experienceYears;
  final bool isVerified;
  final String? bio;

  TeacherProfile({
    required super.id,
    super.authId,
    required super.name,
    super.email,
    super.phone,
    super.avatarUrl,
    super.dateOfBirth,
    super.isActive,
    super.lastLogin,
    super.createdAt,
    required this.teacherId,
    this.department,
    this.specialization,
    this.qualification,
    this.experienceYears,
    this.isVerified = false,
    this.bio,
  }) : super(role: UserRole.teacher);

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      name: json['full_name'] as String? ?? json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      teacherId: json['teacher_id'] as String,
      department: json['department'] as String?,
      specialization: json['specialization'] as String?,
      qualification: json['qualification'] as String?,
      experienceYears: json['experience_years'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      bio: json['bio'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'teacher_id': teacherId,
      'department': department,
      'specialization': specialization,
      'qualification': qualification,
      'experience_years': experienceYears,
      'is_verified': isVerified,
      'bio': bio,
    });
    return json;
  }
}

class AdminProfile extends UserProfile {
  final String adminId;
  final int permissionLevel;
  final String? department;
  final bool canManageUsers;
  final bool canManageAssessments;
  final bool canViewReports;
  final bool canModifySystem;

  AdminProfile({
    required super.id,
    super.authId,
    required super.name,
    super.email,
    super.phone,
    super.avatarUrl,
    super.dateOfBirth,
    super.isActive,
    super.lastLogin,
    super.createdAt,
    required this.adminId,
    this.permissionLevel = 1,
    this.department,
    this.canManageUsers = true,
    this.canManageAssessments = true,
    this.canViewReports = true,
    this.canModifySystem = false,
  }) : super(role: UserRole.admin);

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      name: json['full_name'] as String? ?? json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      adminId: json['admin_id'] as String,
      permissionLevel: json['permission_level'] as int? ?? 1,
      department: json['department'] as String?,
      canManageUsers: json['can_manage_users'] as bool? ?? true,
      canManageAssessments: json['can_manage_assessments'] as bool? ?? true,
      canViewReports: json['can_view_reports'] as bool? ?? true,
      canModifySystem: json['can_modify_system'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'admin_id': adminId,
      'permission_level': permissionLevel,
      'department': department,
      'can_manage_users': canManageUsers,
      'can_manage_assessments': canManageAssessments,
      'can_view_reports': canViewReports,
      'can_modify_system': canModifySystem,
    });
    return json;
  }
}

class LearnerProfile {
  final String id;
  final String name;
  final int age;
  final String? className;
  final String? teacherId;

  LearnerProfile({
    required this.id,
    required this.name,
    required this.age,
    this.className,
    this.teacherId,
  });

  factory LearnerProfile.fromJson(Map<String, dynamic> json) {
    return LearnerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      className: json['className'] as String?,
      teacherId: json['teacherId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'className': className,
        'teacherId': teacherId,
      };
}
