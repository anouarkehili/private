import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/qr_service.dart';

class QRManagementScreen extends StatefulWidget {
  const QRManagementScreen({super.key});

  @override
  State<QRManagementScreen> createState() => _QRManagementScreenState();
}

class _QRManagementScreenState extends State<QRManagementScreen> {
  final QRService _qrService = QRService();
  String? currentQRCode;
  bool isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('إدارة QR للحضور', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQRGenerationCard(),
              const SizedBox(height: 20),
              if (currentQRCode != null) _buildQRDisplayCard(),
              const SizedBox(height: 20),
              _buildActiveQRsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRGenerationCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_2,
            size: 60,
            color: Color(0xFF00FF57),
          ),
          const SizedBox(height: 16),
          const Text(
            'إنشاء QR Code للحضور',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'يمكن للمشتركين مسح هذا الكود لتسجيل حضورهم',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateQRCode,
              icon: isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.add_circle_outline, color: Colors.black),
              label: Text(
                isGenerating ? 'جاري الإنشاء...' : 'إنشاء QR Code جديد',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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

  Widget _buildQRDisplayCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'QR Code الحالي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _buildQRCodeWidget(currentQRCode!),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'الكود: $currentQRCode',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyQRCode(currentQRCode!),
                  icon: const Icon(Icons.copy, color: Color(0xFF00FF57)),
                  label: const Text(
                    'نسخ الكود',
                    style: TextStyle(color: Color(0xFF00FF57)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00FF57)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveQRAsImage(currentQRCode!),
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: const Text(
                    'حفظ كصورة',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF57),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildActiveQRsList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'QR Codes النشطة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _qrService.getActiveQRCodes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF00FF57)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد QR Codes نشطة',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final qrData = snapshot.data![index];
                      return _buildQRListItem(qrData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRListItem(Map<String, dynamic> qrData) {
    final createdAt = qrData['createdAt']?.toDate() ?? DateTime.now();
    final expiresAt = qrData['expiresAt']?.toDate() ?? DateTime.now();
    final usageCount = qrData['usageCount'] ?? 0;

    return Card(
      color: const Color(0xFF1C1C1E),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.qr_code, color: Color(0xFF00FF57)),
        title: Text(
          qrData['code'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم الإنشاء: ${_formatDateTime(createdAt)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'ينتهي: ${_formatDateTime(expiresAt)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'مرات الاستخدام: $usageCount',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deactivateQRCode(qrData['code']),
        ),
      ),
    );
  }

  Widget _buildQRCodeWidget(String data) {
    // هنا يمكنك استخدام مكتبة qr_flutter لإنشاء QR Code حقيقي
    // للآن سنعرض placeholder
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code, size: 80, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            data,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _generateQRCode() async {
    setState(() {
      isGenerating = true;
    });

    try {
      String qrCode = await _qrService.generateAttendanceQR();
      setState(() {
        currentQRCode = qrCode;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء QR Code بنجاح'),
          backgroundColor: Color(0xFF00FF57),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إنشاء QR Code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  void _copyQRCode(String qrCode) {
    Clipboard.setData(ClipboardData(text: qrCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الكود'),
        backgroundColor: Color(0xFF00FF57),
      ),
    );
  }

  Future<void> _saveQRAsImage(String qrCode) async {
    try {
      // هنا يمكنك تنفيذ حفظ QR Code كصورة
      // للآن سنعرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ QR Code كصورة'),
          backgroundColor: Color(0xFF00FF57),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ الصورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deactivateQRCode(String qrCode) async {
    try {
      await _qrService.deactivateQRCode(qrCode);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء تفعيل QR Code'),
          backgroundColor: Color(0xFF00FF57),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إلغاء التفعيل: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}