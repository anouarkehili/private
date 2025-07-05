import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/qr_service.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_status_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class MemberQrScannerScreen extends StatefulWidget {
  const MemberQrScannerScreen({super.key});

  @override
  State<MemberQrScannerScreen> createState() => _MemberQrScannerScreenState();
}

class _MemberQrScannerScreenState extends State<MemberQrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final QRService _qrService = QRService();
  final AttendanceService _attendanceService = AttendanceService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final String? qrCode = capture.barcodes.first.rawValue;
    if (qrCode == null) {
      _showResultDialog('خطأ', 'لم يتمكن من قراءة الكود. حاول مرة أخرى.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final isValid = await _qrService.verifyQRCode(qrCode);
      if (!isValid) {
        _showResultDialog('خطأ', 'هذا الـ QR Code غير صالح أو منتهي الصلاحية.');
        return;
      }

      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        _showResultDialog('خطأ', 'يجب تسجيل الدخول أولاً.');
        return;
      }

      final UserModel? user = await _userService.getUserData(currentUser.uid);
      if (user == null) {
        _showResultDialog('خطأ', 'لم يتم العثور على بيانات المستخدم.');
        return;
      }
      if (!user.isActivated) {
        _showResultDialog('خطأ', 'حسابك غير مفعل بعد. يرجى التواصل مع الإدارة.');
        return;
      }
      if (UserStatusService.isSubscriptionExpired(user)) {
        _showResultDialog('خطأ', 'انتهت صلاحية اشتراكك. يرجى تجديد الاشتراك.');
        return;
      }

      final hasAttended = await _attendanceService.hasAttendedToday(user.uid);
      if (hasAttended) {
        _showResultDialog('تنبيه', 'لقد قمت بتسجيل حضورك بالفعل اليوم.');
        return;
      }

      await _attendanceService.recordAttendance(user);
      _showResultDialog('تم بنجاح!', 'تم تسجيل حضورك بنجاح.');

    } catch (e) {
      _showResultDialog('حدث خطأ', e.toString());
    } finally {
      // Delay to prevent immediate re-scanning
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  void _showResultDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسح QR Code الحضور'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00FF57), width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'وجّه الكاميرا نحو QR Code الخاص بالحصور',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
