import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // تدفق حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // تسجيل الدخول
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // تحديث آخر تسجيل دخول
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        return await getUserData(result.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'البريد الإلكتروني غير مسجل.';
          break;
        case 'wrong-password':
          message = 'كلمة المرور غير صحيحة.';
          break;
        case 'invalid-email':
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
          break;
        case 'user-disabled':
          message = 'تم تعطيل هذا الحساب.';
          break;
        default:
          message = 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('حدث خطأ ما، يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  // تسجيل مستخدم جديد
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // إنشاء بيانات المستخدم في Firestore
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          role: UserRole.user,
          isActivated: false,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(result.user!.uid).set(newUser.toFirestore());

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'هذا البريد الإلكتروني مسجل بالفعل.';
          break;
        case 'weak-password':
          message = 'كلمة المرور ضعيفة جدًا.';
          break;
        case 'invalid-email':
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
          break;
        default:
          message = 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('حدث خطأ ما، يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  // الحصول على بيانات المستخدم
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب بيانات المستخدم: ${e.toString()}');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('خطأ في تسجيل الخروج: ${e.toString()}');
    }
  }

  // تحديث بيانات المستخدم
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('خطأ في تحديث البيانات: ${e.toString()}');
    }
  }

  // تغيير كلمة المرور
  Future<void> changePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw Exception('خطأ في تغيير كلمة المرور: ${e.toString()}');
    }
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('خطأ في إرسال رابط إعادة التعيين: ${e.toString()}');
    }
  }

  // تسجيل الدخول عبر فيسبوك
  Future<UserModel?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken == null) throw Exception('لم يتم الحصول على accessToken من فيسبوك');
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);
        UserCredential userCredential = await _auth.signInWithCredential(facebookAuthCredential);
        final user = userCredential.user;
        if (user != null) {
          // تحقق إذا كان المستخدم موجودًا بالفعل في Firestore
          DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
          if (!doc.exists) {
            // إنشاء مستخدم جديد في Firestore
            UserModel newUser = UserModel(
              uid: user.uid,
              firstName: user.displayName?.split(' ').first ?? '',
              lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
              email: user.email ?? '',
              phone: user.phoneNumber,
              role: UserRole.user,
              isActivated: false,
              createdAt: DateTime.now(),
            );
            await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
            return newUser;
          } else {
            // تحديث آخر تسجيل دخول
            await _firestore.collection('users').doc(user.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
            return UserModel.fromFirestore(doc);
          }
        }
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('تم إلغاء تسجيل الدخول عبر فيسبوك.');
      } else {
        throw Exception(result.message ?? 'فشل تسجيل الدخول عبر فيسبوك.');
      }
      return null;
    } catch (e) {
      throw Exception('حدث خطأ أثناء تسجيل الدخول عبر فيسبوك: ${e.toString()}');
    }
  }
  // جلب بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await getUserData(user.uid);
    }
    return null;
  }
}