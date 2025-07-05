import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/attendance_service.dart';
import '../../services/user_service.dart';
import '../../services/user_status_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleQrCode(String qrCode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final attendanceService = Provider.of<AttendanceService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    
    try {
      // Assuming qrCode is the user's UID
      final UserModel? user = await userService.getUserById(qrCode); // تأكد من أن اسم الدالة مطابق لما هو موجود في UserService

      if (user == null) {
        _showResultDialog('خطأ', 'العضو غير موجود.');
        return;
      }
      if (!user.isActivated) {
        _showResultDialog('خطأ', 'حساب هذا العضو غير مفعل بعد.');
        return;
      }
      if (UserStatusService.isSubscriptionExpired(user)) {
        _showResultDialog('خطأ', 'انتهت صلاحية اشتراك هذا العضو.');
        return;
      }
      await attendanceService.recordAttendance(user);
      _showResultDialog('تم بنجاح', 'تم تسجيل حضور ${user.fullName}.');

    } catch (e) {
      _showResultDialog('خطأ', e.toString().replaceAll('Exception: ', ''));
    } finally {
      // Wait a bit before allowing another scan
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
        title: const Text('مسح QR Code'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _handleQrCode(barcodes.first.rawValue!);
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withAlpha((0.5 * 255).toInt()), // استبدال withOpacity بـ withAlpha لتفادي التحذير
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
