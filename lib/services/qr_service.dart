import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _qrCollection = 'qr_codes';
  static const String _userQrCollection = 'user_qr_codes';

  // إنشاء QR Code جديد للحضور (للإدارة)
  Future<String> generateAttendanceQR() async {
    try {
      // إنشاء كود فريد
      String qrCode = _generateUniqueCode();
      DateTime now = DateTime.now();
      DateTime expiryTime = now.add(const Duration(hours: 12)); // صالح لمدة 12 ساعة

      // حفظ الكود في Firebase
      await _firestore.collection(_qrCollection).doc(qrCode).set({
        'code': qrCode,
        'type': 'attendance',
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiryTime),
        'isActive': true,
        'usageCount': 0,
        'maxUsage': 1000, // حد أقصى للاستخدام
        'createdBy': 'admin',
      });

      return qrCode;
    } catch (e) {
      throw Exception('خطأ في إنشاء QR Code: ${e.toString()}');
    }
  }

  // إنشاء QR Code شخصي للمستخدم
  Future<String> generateUserQR(String userId, String userName) async {
    try {
      // إنشاء كود فريد للمستخدم
      String qrCode = _generateUserQRCode(userId);
      DateTime now = DateTime.now();
      
      // حفظ QR الشخصي للمستخدم
      await _firestore.collection(_userQrCollection).doc(userId).set({
        'userId': userId,
        'userName': userName,
        'qrCode': qrCode,
        'createdAt': Timestamp.fromDate(now),
        'isActive': true,
        'lastUsed': null,
        'usageCount': 0,
      });

      // تحديث بيانات المستخدم
      await _firestore.collection('users').doc(userId).update({
        'qrCodeData': qrCode,
      });

      return qrCode;
    } catch (e) {
      throw Exception('خطأ في إنشاء QR Code الشخصي: ${e.toString()}');
    }
  }

  // التحقق من صحة QR Code للحضور
  Future<bool> validateAttendanceQR(String qrCode) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_qrCollection).doc(qrCode).get();
      
      if (!doc.exists) {
        return false;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // التحقق من انتهاء الصلاحية
      DateTime expiryTime = data['expiresAt'].toDate();
      if (DateTime.now().isAfter(expiryTime)) {
        return false;
      }

      // التحقق من أن الكود نشط
      bool isActive = data['isActive'] ?? false;
      if (!isActive) {
        return false;
      }

      // التحقق من عدد الاستخدامات
      int usageCount = data['usageCount'] ?? 0;
      int maxUsage = data['maxUsage'] ?? 1000;
      
      return usageCount < maxUsage;
    } catch (e) {
      return false;
    }
  }

  // التحقق من QR Code الشخصي للمستخدم
  Future<Map<String, dynamic>?> validateUserQR(String qrCode) async {
    try {
      // البحث عن المستخدم بواسطة QR Code
      QuerySnapshot userQuery = await _firestore
          .collection(_userQrCollection)
          .where('qrCode', isEqualTo: qrCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return null;
      }

      Map<String, dynamic> userData = userQuery.docs.first.data() as Map<String, dynamic>;
      
      // الحصول على بيانات المستخدم الكاملة
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userData['userId'])
          .get();

      if (!userDoc.exists) {
        return null;
      }

      Map<String, dynamic> fullUserData = userDoc.data() as Map<String, dynamic>;
      fullUserData['qrData'] = userData;
      
      return fullUserData;
    } catch (e) {
      return null;
    }
  }

  // تسجيل استخدام QR Code للحضور
  Future<void> recordAttendanceQRUsage(String qrCode) async {
    try {
      await _firestore.collection(_qrCollection).doc(qrCode).update({
        'usageCount': FieldValue.increment(1),
        'lastUsed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في تسجيل استخدام QR Code: ${e.toString()}');
    }
  }

  // تسجيل استخدام QR Code الشخصي
  Future<void> recordUserQRUsage(String userId) async {
    try {
      await _firestore.collection(_userQrCollection).doc(userId).update({
        'usageCount': FieldValue.increment(1),
        'lastUsed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في تسجيل استخدام QR Code الشخصي: ${e.toString()}');
    }
  }

  // إلغاء تفعيل QR Code للحضور
  Future<void> deactivateAttendanceQR(String qrCode) async {
    try {
      await _firestore.collection(_qrCollection).doc(qrCode).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في إلغاء تفعيل QR Code: ${e.toString()}');
    }
  }

  // إلغاء تفعيل QR Code الشخصي
  Future<void> deactivateUserQR(String userId) async {
    try {
      await _firestore.collection(_userQrCollection).doc(userId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });

      // إزالة QR Code من بيانات المستخدم
      await _firestore.collection('users').doc(userId).update({
        'qrCodeData': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('خطأ في إلغاء تفعيل QR Code الشخصي: ${e.toString()}');
    }
  }

  // الحصول على QR Codes النشطة للحضور
  Stream<List<Map<String, dynamic>>> getActiveAttendanceQRCodes() {
    return _firestore
        .collection(_qrCollection)
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: 'attendance')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // الحصول على إحصائيات QR Codes
  Future<Map<String, int>> getQRStats() async {
    try {
      // QR Codes النشطة للحضور
      QuerySnapshot activeAttendance = await _firestore
          .collection(_qrCollection)
          .where('isActive', isEqualTo: true)
          .where('type', isEqualTo: 'attendance')
          .get();

      // QR Codes المنتهية الصلاحية
      QuerySnapshot expiredAttendance = await _firestore
          .collection(_qrCollection)
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();

      // QR Codes الشخصية النشطة
      QuerySnapshot activeUserQRs = await _firestore
          .collection(_userQrCollection)
          .where('isActive', isEqualTo: true)
          .get();

      // إجمالي الاستخدامات اليوم
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      QuerySnapshot todayUsage = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      return {
        'activeAttendance': activeAttendance.docs.length,
        'expiredAttendance': expiredAttendance.docs.length,
        'activeUserQRs': activeUserQRs.docs.length,
        'todayUsage': todayUsage.docs.length,
      };
    } catch (e) {
      return {
        'activeAttendance': 0,
        'expiredAttendance': 0,
        'activeUserQRs': 0,
        'todayUsage': 0,
      };
    }
  }

  // تنظيف QR Codes المنتهية الصلاحية
  Future<void> cleanupExpiredQRCodes() async {
    try {
      QuerySnapshot expiredCodes = await _firestore
          .collection(_qrCollection)
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in expiredCodes.docs) {
        batch.update(doc.reference, {'isActive': false});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('خطأ في تنظيف QR Codes: ${e.toString()}');
    }
  }

  // إنشاء كود فريد للحضور
  String _generateUniqueCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String code = '';
    
    for (int i = 0; i < 8; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    
    // إضافة timestamp لضمان الفرادة
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'ATT_${code}_${timestamp.substring(timestamp.length - 4)}';
  }

  // إنشاء QR Code شخصي للمستخدم
  String _generateUserQRCode(String userId) {
    // استخدام hash للمستخدم مع timestamp
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String combined = '$userId$timestamp';
    var bytes = utf8.encode(combined);
    var digest = sha256.convert(bytes);
    
    return 'USER_${digest.toString().substring(0, 12).toUpperCase()}';
  }

  // تحويل البيانات إلى JSON للـ QR Code
  String encodeAttendanceQRData(String qrCode) {
    Map<String, dynamic> qrData = {
      'type': 'gym_attendance',
      'code': qrCode,
      'gym': 'DADA_GYM',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'version': '1.0',
    };
    return jsonEncode(qrData);
  }

  // تحويل البيانات الشخصية إلى JSON للـ QR Code
  String encodeUserQRData(String qrCode, String userId) {
    Map<String, dynamic> qrData = {
      'type': 'gym_user',
      'code': qrCode,
      'userId': userId,
      'gym': 'DADA_GYM',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'version': '1.0',
    };
    return jsonEncode(qrData);
  }

  // فك تشفير بيانات QR Code
  Map<String, dynamic>? decodeQRData(String qrData) {
    try {
      Map<String, dynamic> data = jsonDecode(qrData);
      
      // التحقق من أن هذا QR Code خاص بالصالة
      if (data['gym'] != 'DADA_GYM') {
        return null;
      }
      
      // التحقق من النوع
      String type = data['type'] ?? '';
      if (type != 'gym_attendance' && type != 'gym_user') {
        return null;
      }
      
      return data;
    } catch (e) {
      return null;
    }
  }

  // التحقق من QR Code بشكل عام
  Future<Map<String, dynamic>?> verifyQRCode(String qrCode) async {
    try {
      // محاولة فك تشفير البيانات أولاً
      Map<String, dynamic>? decodedData = decodeQRData(qrCode);
      
      if (decodedData != null) {
        String type = decodedData['type'];
        String code = decodedData['code'];
        
        if (type == 'gym_attendance') {
          bool isValid = await validateAttendanceQR(code);
          return isValid ? decodedData : null;
        } else if (type == 'gym_user') {
          Map<String, dynamic>? userData = await validateUserQR(code);
          return userData;
        }
      }
      
      // إذا فشل فك التشفير، جرب التحقق المباشر
      // للتوافق مع الأكواد القديمة
      bool isAttendanceValid = await validateAttendanceQR(qrCode);
      if (isAttendanceValid) {
        return {
          'type': 'gym_attendance',
          'code': qrCode,
          'gym': 'DADA_GYM',
        };
      }
      
      Map<String, dynamic>? userData = await validateUserQR(qrCode);
      if (userData != null) {
        return userData;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // تجديد QR Code للحضور
  Future<String> renewAttendanceQR(String oldQrCode) async {
    try {
      // إلغاء تفعيل الكود القديم
      await deactivateAttendanceQR(oldQrCode);
      
      // إنشاء كود جديد
      return await generateAttendanceQR();
    } catch (e) {
      throw Exception('خطأ في تجديد QR Code: ${e.toString()}');
    }
  }

  // تجديد QR Code الشخصي
  Future<String> renewUserQR(String userId, String userName) async {
    try {
      // إلغاء تفعيل الكود القديم
      await deactivateUserQR(userId);
      
      // إنشاء كود جديد
      return await generateUserQR(userId, userName);
    } catch (e) {
      throw Exception('خطأ في تجديد QR Code الشخصي: ${e.toString()}');
    }
  }

  // الحصول على QR Code الشخصي للمستخدم
  Future<String?> getUserQRCode(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_userQrCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['isActive'] == true) {
          return data['qrCode'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // إنشاء QR Code للمستخدم إذا لم يكن موجوداً
  Future<String> ensureUserQRCode(String userId, String userName) async {
    String? existingQR = await getUserQRCode(userId);
    if (existingQR != null) {
      return existingQR;
    }
    return await generateUserQR(userId, userName);
  }
}