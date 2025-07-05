import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/qr_service.dart';
import '../../services/attendance_service.dart';
import '../../models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

// شاشة مسح QR
class QRScannerScreen extends StatefulWidget {
  final UserModel user;
  
  const QRScannerScreen({super.key, required this.user});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final QRService _qrService = QRService();
  final AttendanceService _attendanceService = AttendanceService();
  final TextEditingController _qrController = TextEditingController();
  bool isProcessing = false;

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('تسجيل الحضور', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildUserCard(),
                const SizedBox(height: 20),
                _buildQRScannerCard(),
                const SizedBox(height: 20),
                _buildManualInputCard(),
                const SizedBox(height: 20),
                _buildShowMyQrButton(),
                const SizedBox(height: 20),
                _buildViewHistoryButton(),
                const SizedBox(height: 40),
                _buildAttendanceStatus(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildViewHistoryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttendanceScreen(user: widget.user),
            ),
          );
        },
        icon: const Icon(Icons.history, color: Color(0xFF00FF57)),
        label: const Text(
          'عرض سجل الحضور',
          style: TextStyle(color: Color(0xFF00FF57), fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00FF57)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF00FF57),
            radius: 30,
            child: Text(
              widget.user.firstName[0],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.user.isSubscriptionActive 
                        ? Colors.green.withAlpha((0.2 * 255).toInt())
                        : Colors.red.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.user.isSubscriptionActive ? 'اشتراك نشط' : 'اشتراك منتهي',
                    style: TextStyle(
                      color: widget.user.isSubscriptionActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScannerCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: Color(0xFF00FF57),
          ),
          const SizedBox(height: 16),
          const Text(
            'مسح QR Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'امسح QR Code المعروض من الإدارة لتسجيل حضورك',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openQRScanner,
              icon: const Icon(Icons.camera_alt, color: Colors.black),
              label: const Text(
                'فتح الكاميرا',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF57),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدخال الكود يدوياً',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'يمكنك إدخال كود QR يدوياً إذا لم تتمكن من مسحه',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qrController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'أدخل كود QR هنا...',
              hintStyle: TextStyle(color: Colors.white54),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code, color: Color(0xFF00FF57)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste, color: Color(0xFF00FF57)),
                  label: const Text(
                    'لصق',
                    style: TextStyle(color: Color(0xFF00FF57)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00FF57)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : _processManualQR,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.check, color: Colors.black),
                  label: Text(
                    isProcessing ? 'جاري المعالجة...' : 'تسجيل الحضور',
                    style: const TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF57),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowMyQrButton() {
    final isActivated = widget.user.isActivated;
    final isExpired = !(widget.user.subscriptionEnd != null && widget.user.subscriptionEnd!.isAfter(DateTime.now()));
    return Visibility(
      visible: isActivated && !isExpired,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            _showMyQrDialog();
          },
          icon: const Icon(Icons.qr_code, color: Colors.black),
          label: const Text('عرض QR الخاص بي', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF57),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  void _showMyQrDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('QR الخاص بك', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((widget.user.qrCodeData ?? '').isNotEmpty)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: QrImageView(
                      data: widget.user.qrCodeData!,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              )
            else
              const Text(
                'لا يوجد QR Code متاح حالياً.',
                style: TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 16),
            const Text(
              'اعرض هذا الرمز للموظف عند الدخول',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('إغلاق', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatus() {
    return FutureBuilder<bool>(
      future: _attendanceService.hasAttendedToday(widget.user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Color(0xFF00FF57));
        }

        bool hasAttended = snapshot.data ?? false;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasAttended 
                ? Colors.green.withAlpha((0.2 * 255).toInt())
                : Colors.orange.withAlpha((0.2 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasAttended ? Colors.green : Colors.orange,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasAttended ? Icons.check_circle : Icons.pending,
                color: hasAttended ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasAttended 
                      ? 'تم تسجيل حضورك اليوم بنجاح'
                      : 'لم يتم تسجيل حضورك اليوم بعد',
                  style: TextStyle(
                    color: hasAttended ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openQRScanner() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('مسح QR Code', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, size: 60, color: Color(0xFF00FF57)),
            SizedBox(height: 16),
            Text(
              'وجه الكاميرا نحو QR Code',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processQRCode('GYM_TEST123_2025');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('محاكاة مسح ناجح', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData('text/plain');
      if (data != null && data.text != null) {
        _qrController.text = data.text!;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في لصق النص'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processManualQR() async {
    if (_qrController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال كود QR'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _processQRCode(_qrController.text.trim());
  }

  Future<void> _processQRCode(String qrCode) async {
    if (!widget.user.isActivated) {
      _showErrorDialog('حسابك غير مفعل. يرجى التواصل مع الإدارة.');
      return;
    }

    if (!widget.user.isSubscriptionActive) {
      _showErrorDialog('اشتراكك منتهي. يرجى تجديد الاشتراك.');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      bool isValid = await _qrService.validateQRCode(qrCode);
      
      if (!isValid) {
        _showErrorDialog('QR Code غير صحيح أو منتهي الصلاحية');
        return;
      }

      bool hasAttended = await _attendanceService.hasAttendedToday(widget.user.uid);
      
      if (hasAttended) {
        _showErrorDialog('تم تسجيل حضورك مسبقاً اليوم');
        return;
      }

      await _attendanceService.recordAttendance(widget.user);
      await _qrService.recordQRUsage(qrCode);

      _showSuccessDialog();
      _qrController.clear();

    } catch (e) {
      _showErrorDialog('خطأ في تسجيل الحضور: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('خطأ', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('موافق', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تم بنجاح', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 60, color: Color(0xFF00FF57)),
            SizedBox(height: 16),
            Text(
              'تم تسجيل حضورك بنجاح!',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // العودة للشاشة الرئيسية
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('موافق', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

// صفحة سجل الحضور
class AttendanceScreen extends StatelessWidget {
  final UserModel user;
  
  const AttendanceScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الحضور', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTodayStatus(context),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'سجل الحضور:',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildAttendanceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatus(BuildContext context) {
    return FutureBuilder<bool>(
      future: AttendanceService().hasAttendedToday(user.uid),
      builder: (context, snapshot) {
        bool hasAttended = snapshot.data ?? false;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasAttended 
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasAttended ? Colors.green : Colors.orange,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasAttended ? Icons.check_circle : Icons.pending,
                color: hasAttended ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasAttended 
                      ? 'تم تسجيل حضورك اليوم'
                      : 'لم يتم تسجيل حضورك اليوم بعد',
                  style: TextStyle(
                    color: hasAttended ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!hasAttended)
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QRScannerScreen(user: user),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF57),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الحضور',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    return StreamBuilder(
      stream: AttendanceService().getUserAttendance(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FF57)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'لا يوجد سجل حضور',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final attendance = snapshot.data![index];
            return Card(
              color: const Color(0xFF2C2C2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Color(0xFF00FF57), size: 28),
                title: Text(
                  _formatDate(attendance.date),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white54, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(attendance.checkInTime),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                trailing: const Text(
                  'حضر',
                  style: TextStyle(
                    color: Color(0xFF00FF57),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // يمكنك تعديل التنسيق حسب الحاجة
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}