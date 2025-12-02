import '../constants/app_constants.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;
  final String? avatarUrl;
  final bool isApproved;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.avatarUrl,
    required this.isApproved,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.value == json['role'],
        orElse: () => UserRole.employee,
      ),
      avatarUrl: json['avatar_url'] as String?,
      isApproved: json['is_approved'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.value,
      'avatar_url': avatarUrl,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isEmployee => role == UserRole.employee;

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
