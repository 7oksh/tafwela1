class StaffModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String stationName;
  final String staffId;
  final String role;
  final String status;

  StaffModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.stationName,
    required this.staffId,
    required this.role,
    required this.status,
  });

  factory StaffModel.fromMap(String id, Map<String, dynamic> map) {
    return StaffModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      stationName: map['stationName'] ?? '',
      staffId: map['staffId'] ?? id,
      role: map['role'] ?? 'staff',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'stationName': stationName,
      'staffId': staffId,
      'role': role,
      'status': status,
    };
  }

  String get fullName => '$firstName $lastName';
}
