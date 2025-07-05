import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل الحضور
  Future<void> recordAttendance(UserModel user) async {
    try {
      // التحقق من عدم تسجيل الحضور مسبقاً اليوم
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot existingAttendance = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (existingAttendance.docs.isNotEmpty) {
        throw Exception('تم تسجيل الحضور مسبقاً اليوم');
      }

      // تسجيل الحضور الجديد
      AttendanceModel attendance = AttendanceModel(
        id: '',
        userId: user.uid,
        userName: user.fullName,
        checkInTime: DateTime.now(),
        date: startOfDay,
      );

      await _firestore.collection('attendance').add(attendance.toFirestore());
    } catch (e) {
      throw Exception('خطأ في تسجيل الحضور: ${e.toString()}');
    }
  }

  // الحصول على حضور اليوم
  Stream<List<AttendanceModel>> getTodayAttendance() {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('checkInTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  // الحصول على حضور تاريخ معين
  Stream<List<AttendanceModel>> getAttendanceByDate(DateTime date) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('checkInTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  // الحصول على حضور مستخدم معين
  Stream<List<AttendanceModel>> getUserAttendance(String userId) {
    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(30) // آخر 30 يوم
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  // التحقق من حضور المستخدم اليوم
  Future<bool> hasAttendedToday(String userId) async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // الحصول على إحصائيات الحضور
  Future<Map<String, int>> getAttendanceStats() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));
      DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      DateTime startOfMonth = DateTime(today.year, today.month, 1);

      // حضور اليوم
      QuerySnapshot todayAttendance = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // حضور هذا الأسبوع
      QuerySnapshot weekAttendance = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .get();

      // حضور هذا الشهر
      QuerySnapshot monthAttendance = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      return {
        'today': todayAttendance.docs.length,
        'week': weekAttendance.docs.length,
        'month': monthAttendance.docs.length,
      };
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات الحضور: ${e.toString()}');
    }
  }

  // حذف سجل حضور
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _firestore.collection('attendance').doc(attendanceId).delete();
    } catch (e) {
      throw Exception('خطأ في حذف سجل الحضور: ${e.toString()}');
    }
  }
}