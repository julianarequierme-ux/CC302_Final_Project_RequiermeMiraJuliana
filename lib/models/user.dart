class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String nationality;
  final String passwordHash;
  final String? photoPath;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.nationality,
    required this.passwordHash,
    required this.photoPath,
    required this.createdAt,
  });

  User copyWith({
    String? fullName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? nationality,
    String? passwordHash,
    String? photoPath,
    bool clearPhoto = false,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      passwordHash: passwordHash ?? this.passwordHash,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'nationality': nationality,
        'passwordHash': passwordHash,
        'photoPath': photoPath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        dateOfBirth: json['dateOfBirth'] == null
            ? null
            : DateTime.parse(json['dateOfBirth'] as String),
        nationality: json['nationality'] as String? ?? 'Filipino',
        passwordHash: json['passwordHash'] as String,
        photoPath: json['photoPath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

String userInitials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
