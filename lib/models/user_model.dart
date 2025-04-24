class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String preferredLanguage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.preferredLanguage,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Handle both Timestamp and String formats for dates
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      if (value.runtimeType.toString() == 'Timestamp') {
        return DateTime.fromMillisecondsSinceEpoch(
          (value.seconds * 1000 + value.milliseconds).toInt()
        );
      }
      return null;
    }

    return UserModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      preferredLanguage: map['preferredLanguage']?.toString() ?? 'en',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? preferredLanguage,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: this.email,
      phone: phone ?? this.phone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 