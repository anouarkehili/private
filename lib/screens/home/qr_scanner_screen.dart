import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../services/qr_service.dart';
import '../../services/attendance_service.dart';
import '../../services/theme_service.dart';
import '../../models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  final MobileScannerController _scannerController = MobileScannerController();
  
  bool isProcessing = false;
  bool isScanning = false;
  String? userQRCode;

  @override
  void initState() {
    super.initState();
    _loadUserQRCode();
  }

  @override
  void dispose() {
    _qrController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _loadUserQRCode() async {
    try {
      String qrCode = await _qrService.ensureUserQRCode(
        widget.user.uid, 
        widget.user.fullName,
      );
      setState(() {
        userQRCode = qrCode;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'تسجيل الحضور', 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.qr_code,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _showMyQrDialog,
              tooltip: 'QR الخاص بي',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildUserCard(),
                const SizedBox(height: 20),
                if (isScanning) 
                  _buildQRScannerView()
                else
                  _buildQRScannerCard(),
                const SizedBox(height: 20),
                if (!isScanning) _buildManualInputCard(),
                const SizedBox(height: 20),
                if (!isScanning) _buildShowMyQrButton(),
                const SizedBox(height: 20),
                if (!isScanning) _buildViewHistoryButton(),
                const SizedBox(height: 40),
                if (!isScanning) _buildAttendanceStatus(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: Theme.of(context).textTheme.bodySmall,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'مسح QR Code',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'امسح QR Code المعروض من الإدارة لتسجيل حضورك',
            style: Theme.of(context).textTheme.bodyMedium,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScannerView() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _onQRDetected,
            ),
            // إطار المسح
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary, 
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // زر الإغلاق
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isScanning = false;
                    });
                  },
                ),
              ),
            ),
            // نص توضيحي
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
                    'وجّه الكاميرا نحو QR Code الخاص بالحضور',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // مؤشر المعالجة
            if (isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00FF57),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدخال الكود يدوياً',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك إدخال كود QR يدوياً إذا لم تتمكن من مسحه',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qrController,
            decoration: InputDecoration(
              hintText: 'أدخل كود QR هنا...',
              prefixIcon: Icon(
                Icons.qr_code, 
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: Icon(
                    Icons.paste, 
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'لصق',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
    final isExpired = !widget.user.isSubscriptionActive;
    
    return Visibility(
      visible: isActivated && !isExpired,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showMyQrDialog,
          icon: const Icon(Icons.qr_code, color: Colors.black),
          label: const Text(
            'عرض QR الخاص بي', 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              builder: (_) => AttendanceHistoryScreen(user: widget.user),
            ),
          );
        },
        icon: Icon(
          Icons.history, 
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text(
          'عرض سجل الحضور',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceStatus() {
    return FutureBuilder<bool>(
      future: _attendanceService.hasAttendedToday(widget.user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          );
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
    setState(() {
      isScanning = true;
    });
  }

  void _onQRDetected(BarcodeCapture capture) {
    if (isProcessing) return;

    final String? qrCode = capture.barcodes.first.rawValue;
    if (qrCode == null) return;

    _processQRCode(qrCode);
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
      // التحقق من QR Code
      Map<String, dynamic>? qrData = await _qrService.verifyQRCode(qrCode);
      
      if (qrData == null) {
        _showErrorDialog('QR Code غير صحيح أو منتهي الصلاحية');
        return;
      }

      // التحقق من الحضور المسبق
      bool hasAttended = await _attendanceService.hasAttendedToday(widget.user.uid);
      
      if (hasAttended) {
        _showErrorDialog('تم تسجيل حضورك مسبقاً اليوم');
        return;
      }

      // تسجيل الحضور
      await _attendanceService.recordAttendance(widget.user);
      
      // تسجيل استخدام QR Code
      String type = qrData['type'] ?? '';
      if (type == 'gym_attendance') {
        await _qrService.recordAttendanceQRUsage(qrData['code']);
      } else if (type == 'gym_user') {
        await _qrService.recordUserQRUsage(widget.user.uid);
      }

      _showSuccessDialog();
      _qrController.clear();

    } catch (e) {
      _showErrorDialog('خطأ في تسجيل الحضور: $e');
    } finally {
      setState(() {
        isProcessing = false;
        isScanning = false;
      });
    }
  }

  void _showMyQrDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'QR الخاص بك', 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userQRCode != null)
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
                      data: _qrService.encodeUserQRData(userQRCode!, widget.user.uid),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'اعرض هذا الرمز للموظف عند الدخول',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'خطأ', 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          message, 
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'تم بنجاح', 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle, 
              size: 60, 
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'تم تسجيل حضورك بنجاح!',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}

// صفحة سجل الحضور
class AttendanceHistoryScreen extends StatelessWidget {
  final UserModel user;
  
  const AttendanceHistoryScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل الحضور', 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTodayStatus(context),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'سجل الحضور:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                  child: const Text('تسجيل الحضور'),
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
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'لا يوجد سجل حضور',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final attendance = snapshot.data![index];
            return Card(
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(
                  Icons.check_circle, 
                  color: Theme.of(context).colorScheme.primary, 
                  size: 28,
                ),
                title: Text(
                  _formatDate(attendance.date),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      Icons.access_time, 
                      color: Theme.of(context).textTheme.bodySmall?.color, 
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(attendance.checkInTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: Text(
                  'حضر',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
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
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}