class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? photoUrl;
  final int ordersCount;
  final int points;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.ordersCount = 0,
    this.points = 0,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      ordersCount: map['ordersCount'] as int? ?? 0,
      points: map['points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'ordersCount': ordersCount,
        'points': points,
      };

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? photoUrl,
    bool clearPhoto = false,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      ordersCount: ordersCount,
      points: points,
    );
  }
}
