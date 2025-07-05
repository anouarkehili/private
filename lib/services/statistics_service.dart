import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // عدد المشتركين الإجمالي
  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.length;
  }

  // عدد المشتركين النشطين
  Future<int> getActiveUsers() async {
    final snapshot = await _firestore.collection('users').where('isActivated', isEqualTo: true).get();
    return snapshot.docs.length;
  }

  // عدد الاشتراكات المنتهية
  Future<int> getExpiredSubscriptions() async {
    final now = DateTime.now();
    final snapshot = await _firestore.collection('users')
      .where('subscriptionEnd', isLessThan: Timestamp.fromDate(now)).get();
    return snapshot.docs.length;
  }

  // عدد الاشتراكات التي ستنتهي قريباً (خلال 7 أيام)
  Future<int> getExpiringSoonSubscriptions() async {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));
    final snapshot = await _firestore.collection('users')
      .where('subscriptionEnd', isGreaterThan: Timestamp.fromDate(now))
      .where('subscriptionEnd', isLessThan: Timestamp.fromDate(soon)).get();
    return snapshot.docs.length;
  }

  // معدل الحضور الأسبوعي (عدد الحضور لكل يوم)
  Future<Map<String, int>> getWeeklyAttendance() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final snapshot = await _firestore.collection('attendance')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
      .get();
    Map<String, int> attendance = {
      'السبت': 0,
      'الأحد': 0,
      'الاثنين': 0,
      'الثلاثاء': 0,
      'الأربعاء': 0,
      'الخميس': 0,
      'الجمعة': 0,
    };
    for (var doc in snapshot.docs) {
      final date = (doc['date'] as Timestamp).toDate();
      final day = DateFormat('EEEE','ar_DZ').format(date);
      if (attendance.containsKey(day)) {
        attendance[day] = attendance[day]! + 1;
      }
    }
    return attendance;
  }

  // الإيرادات الشهرية (مجموع المدفوعات خلال الشهر الحالي)
  Future<int> getMonthlyRevenue() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final snapshot = await _firestore.collection('payments')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
      .get();
    int total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['amount'] ?? 0) as int;
    }
    return total;
  }
}
