enum UserRole {
  customer,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'System Administrator';
      case UserRole.customer:
        return 'Verified Customer';
    }
  }

  String get badgeLabel {
    switch (this) {
      case UserRole.admin:
        return 'SUPER ADMIN';
      case UserRole.customer:
        return 'CYBER CITIZEN';
    }
  }

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.customer;
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatarUrl;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final DateTime joinedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = UserRole.customer,
    this.avatarUrl,
    this.street = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  bool get isAdmin => role == UserRole.admin;
  String get badgeLabel => role.badgeLabel;
  String get roleDisplayName => role.displayName;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'CP';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get fullAddress {
    final parts = [street, city, state, pincode].where((s) => s.trim().isNotEmpty).toList();
    if (parts.isEmpty) return 'No saved shipping address';
    return parts.join(', ');
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    String? street,
    String? city,
    String? state,
    String? pincode,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Cyber Citizen',
      email: json['email'] as String? ?? 'user@cyberpulse.in',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      role: UserRoleExtension.fromString(json['role'] as String?),
      avatarUrl: json['avatarUrl'] as String?,
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
