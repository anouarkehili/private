import 'package:cloud_firestore/cloud_firestore.dart';

class SupportService {
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('support_messages');

  // إرسال رسالة دعم جديدة
  Future<void> sendMessage(String userId, String message) async {
    await _messagesCollection.add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isFromAdmin': false,
    });
  }

  // إرسال رد من الادمن
  Future<void> sendAdminReply(String userId, String message) async {
    await _messagesCollection.add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isFromAdmin': true,
    });
  }

  // جلب المحادثات مع مستخدم معين
  Stream<List<Map<String, dynamic>>> getMessagesForUser(String userId) {
    return _messagesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  // جلب كل المحادثات (للادمن)
  Stream<List<Map<String, dynamic>>> getAllConversations() {
    return _messagesCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }
}
