import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _qrCollection = 'qr_codes';

  // إنشاء QR Code جديد للحضور
  Future<String> generateAttendanceQR() async {
    try {
      // إنشاء كود فريد
      String qrCode = _generateUniqueCode();
      DateTime now = DateTime.now();
      DateTime expiryTime = now.add(const Duration(hours: 24)); // صالح لمدة 24 ساعة

      // حفظ الكود في Firebase
      await _firestore.collection(_qrCollection).doc(qrCode).set({
        'code': qrCode,
        'type': 'attendance',
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiryTime),
        'isActive': true,
        'usageCount': 0,
      });

      return qrCode;
    } catch (e) {
      throw Exception('خطأ في إنشاء QR Code: ${e.toString()}');
    }
  }

  // التحقق من صحة QR Code
  Future<bool> validateQRCode(String qrCode) async {
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
      return data['isActive'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // تسجيل استخدام QR Code
  Future<void> recordQRUsage(String qrCode) async {
    try {
      await _firestore.collection(_qrCollection).doc(qrCode).update({
        'usageCount': FieldValue.increment(1),
        'lastUsed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في تسجيل استخدام QR Code: ${e.toString()}');
    }
  }

  // إلغاء تفعيل QR Code
  Future<void> deactivateQRCode(String qrCode) async {
    try {
      await _firestore.collection(_qrCollection).doc(qrCode).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('خطأ في إلغاء تفعيل QR Code: ${e.toString()}');
    }
  }

  // الحصول على QR Codes النشطة
  Stream<List<Map<String, dynamic>>> getActiveQRCodes() {
    return _firestore
        .collection(_qrCollection)
        .where('isActive', isEqualTo: true)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
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
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('خطأ في تنظيف QR Codes: ${e.toString()}');
    }
  }

  // إنشاء كود فريد
  String _generateUniqueCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String code = '';
    
    for (int i = 0; i < 8; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    
    // إضافة timestamp لضمان الفرادة
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'GYM_${code}_${timestamp.substring(timestamp.length - 4)}';
  }

  // تحويل البيانات إلى JSON للـ QR Code
  String encodeQRData(String qrCode) {
    Map<String, dynamic> qrData = {
      'type': 'gym_attendance',
      'code': qrCode,
      'gym': 'DADA_GYM',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(qrData);
  }

  // فك تشفير بيانات QR Code
  Map<String, dynamic>? decodeQRData(String qrData) {
    try {
      Map<String, dynamic> data = jsonDecode(qrData);
      
      // التحقق من أن هذا QR Code خاص بالصالة
      if (data['type'] != 'gym_attendance' || data['gym'] != 'DADA_GYM') {
        return null;
      }
      
      return data;
    } catch (e) {
      return null;
    }
  }

Future<bool> verifyQRCode(String qrCode) async {
  // مثال بسيط: نفترض أن الكود هو uid لمستخدم
  final doc = await FirebaseFirestore.instance.collection('users').doc(qrCode).get();
  return doc.exists;
}


}