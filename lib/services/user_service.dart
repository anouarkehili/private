import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على جميع المستخدمين
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // الحصول على المستخدمين حسب الحالة
  Stream<List<UserModel>> getUsersByStatus(bool isActivated) {
    return _firestore
        .collection('users')
        .where('isActivated', isEqualTo: isActivated)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // البحث عن المستخدمين
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('firstName')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث: ${e.toString()}');
    }
  }

  // تفعيل/إلغاء تفعيل المستخدم
  Future<void> toggleUserActivation(String uid, bool isActivated) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActivated': isActivated,
      });
    } catch (e) {
      throw Exception('خطأ في تحديث حالة التفعيل: ${e.toString()}');
    }
  }

  // تحديث اشتراك المستخدم
  Future<void> updateUserSubscription(String uid, DateTime startDate, DateTime endDate) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'subscriptionStart': Timestamp.fromDate(startDate),
        'subscriptionEnd': Timestamp.fromDate(endDate),
        'isActivated': true,
      });
    } catch (e) {
      throw Exception('خطأ في تحديث الاشتراك: ${e.toString()}');
    }
  }

  // تحديث رتبة المستخدم
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('خطأ في تحديث الرتبة: ${e.toString()}');
    }
  }

  // حذف المستخدم
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('خطأ في حذف المستخدم: ${e.toString()}');
    }
  }

  // الحصول على إحصائيات المستخدمين
  Future<Map<String, int>> getUserStats() async {
    try {
      QuerySnapshot allUsers = await _firestore.collection('users').get();
      QuerySnapshot activeUsers = await _firestore
          .collection('users')
          .where('isActivated', isEqualTo: true)
          .get();
      QuerySnapshot admins = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return {
        'total': allUsers.docs.length,
        'active': activeUsers.docs.length,
        'inactive': allUsers.docs.length - activeUsers.docs.length,
        'admins': admins.docs.length,
      };
    } catch (e) {
      throw Exception('خطأ في جلب الإحصائيات: ${e.toString()}');
    }
  }
  // الحصول على مستخدم بواسطة المعرف
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('خطأ في جلب المستخدم: ${e.toString()}');
    }
  }
  // الحصول على بيانات المستخدم بواسطة البريد الإلكتروني
  Future<UserModel?> getUserData(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('خطأ في جلب بيانات المستخدم: ${e.toString()}');
    }
  }
}