class AdminModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool isActive;
  final String role;
  final DateTime createdAt;

  AdminModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.role,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  String get roleDisplayName => 'اداري';
}
