import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, admin }

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final UserRole role;
  final bool isActivated;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? qrCodeData;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.role = UserRole.user,
    this.isActivated = false,
    this.subscriptionStart,
    this.subscriptionEnd,
    required this.createdAt,
    this.lastLogin,
    this.qrCodeData,
  });

  String get fullName => '$firstName $lastName';

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'إداري';
      case UserRole.user:
        return 'مشترك';
    }
  }

  bool get isSubscriptionActive {
    if (!isActivated || subscriptionEnd == null) return false;
    return subscriptionEnd!.isAfter(DateTime.now());
  }

  int get daysRemaining {
    if (subscriptionEnd == null) return 0;
    return subscriptionEnd!.difference(DateTime.now()).inDays;
  }

  // تحويل من Firebase Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.user,
      ),
      isActivated: data['isActivated'] ?? false,
      subscriptionStart: data['subscriptionStart']?.toDate(),
      subscriptionEnd: data['subscriptionEnd']?.toDate(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastLogin: data['lastLogin']?.toDate(),
      qrCodeData: data['qrCodeData'],
    );
  }

  // تحويل إلى Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'isActivated': isActivated,
      'subscriptionStart': subscriptionStart != null 
          ? Timestamp.fromDate(subscriptionStart!) 
          : null,
      'subscriptionEnd': subscriptionEnd != null 
          ? Timestamp.fromDate(subscriptionEnd!) 
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null 
          ? Timestamp.fromDate(lastLogin!) 
          : null,
      'qrCodeData': qrCodeData,
    };
  }

  // نسخ مع تعديل
  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    UserRole? role,
    bool? isActivated,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? qrCodeData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActivated: isActivated ?? this.isActivated,
      subscriptionStart: subscriptionStart ?? this.subscriptionStart,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }
}