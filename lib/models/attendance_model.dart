import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime checkInTime;
  final DateTime date;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.checkInTime,
    required this.date,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      checkInTime: data['checkInTime']?.toDate() ?? DateTime.now(),
      date: data['date']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'date': Timestamp.fromDate(date),
    };
  }
}