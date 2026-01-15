enum UserRole { parent, teacher, student }

class UserProfile {
  final String id;
  final String name;
  final UserRole role;
  final String? email;

  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      role: UserRole.values.byName(json['role'] as String),
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.name,
    'email': email,
  };
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
