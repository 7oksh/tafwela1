class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String status;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'customer',
      status: map['status'] ?? 'approved',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
    };
  }

  String get fullName => '$firstName $lastName';
}
