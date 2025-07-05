import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/qr_service.dart';
import '../../services/theme_service.dart';

class QRManagementScreen extends StatefulWidget {
  const QRManagementScreen({super.key});

  @override
  State<QRManagementScreen> createState() => _QRManagementScreenState();
}

class _QRManagementScreenState extends State<QRManagementScreen> {
  final QRService _qrService = QRService();
  String? currentQRCode;
  bool isGenerating = false;
  Map<String, int> qrStats = {};

  @override
  void initState() {
    super.initState();
    _loadQRStats();
  }

  Future<void> _loadQRStats() async {
    try {
      final stats = await _qrService.getQRStats();
      setState(() {
        qrStats = stats;
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
            'إدارة QR للحضور', 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                _loadQRStats();
                setState(() {});
              },
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadQRStats,
          color: Theme.of(context).colorScheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsCards(),
              const SizedBox(height: 20),
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

  Widget _buildStatsCards() {
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
            'إحصائيات QR Codes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'QR نشطة للحضور',
                  qrStats['activeAttendance']?.toString() ?? '0',
                  Icons.qr_code,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'QR شخصية نشطة',
                  qrStats['activeUserQRs']?.toString() ?? '0',
                  Icons.person,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'استخدامات اليوم',
                  qrStats['todayUsage']?.toString() ?? '0',
                  Icons.today,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'QR منتهية',
                  qrStats['expiredAttendance']?.toString() ?? '0',
                  Icons.expired,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQRGenerationCard() {
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
            Icons.qr_code_2,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'إنشاء QR Code للحضور',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكن للمشتركين مسح هذا الكود لتسجيل حضورهم',
            style: Theme.of(context).textTheme.bodyMedium,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRDisplayCard() {
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
          Text(
            'QR Code الحالي',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: QrImageView(
                  data: _qrService.encodeAttendanceQRData(currentQRCode!),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'الكود: $currentQRCode',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyQRCode(currentQRCode!),
                  icon: Icon(
                    Icons.copy, 
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'نسخ الكود',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareQRCode(currentQRCode!),
                  icon: const Icon(Icons.share, color: Colors.black),
                  label: const Text(
                    'مشاركة',
                    style: TextStyle(color: Colors.black),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'QR Codes النشطة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _qrService.getActiveAttendanceQRCodes(),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_off,
                          size: 64,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد QR Codes نشطة',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
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
    );
  }

  Widget _buildQRListItem(Map<String, dynamic> qrData) {
    final createdAt = qrData['createdAt']?.toDate() ?? DateTime.now();
    final expiresAt = qrData['expiresAt']?.toDate() ?? DateTime.now();
    final usageCount = qrData['usageCount'] ?? 0;
    final maxUsage = qrData['maxUsage'] ?? 1000;
    final isExpiringSoon = expiresAt.difference(DateTime.now()).inHours < 2;

    return Card(
      color: Theme.of(context).colorScheme.background,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.qr_code, 
          color: isExpiringSoon ? Colors.orange : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          qrData['code'],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم الإنشاء: ${_formatDateTime(createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'ينتهي: ${_formatDateTime(expiresAt)}',
              style: TextStyle(
                color: isExpiringSoon ? Colors.orange : Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
            Text(
              'الاستخدامات: $usageCount / $maxUsage',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'copy':
                _copyQRCode(qrData['code']);
                break;
              case 'deactivate':
                _deactivateQRCode(qrData['code']);
                break;
              case 'renew':
                _renewQRCode(qrData['code']);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('نسخ'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'renew',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('تجديد'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'deactivate',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('إلغاء تفعيل', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
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
      
      await _loadQRStats();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إنشاء QR Code بنجاح'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
      SnackBar(
        content: const Text('تم نسخ الكود'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _shareQRCode(String qrCode) {
    // يمكن إضافة مكتبة المشاركة هنا
    _copyQRCode(qrCode);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الكود للمشاركة'),
      ),
    );
  }

  Future<void> _deactivateQRCode(String qrCode) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'تأكيد إلغاء التفعيل',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'هل أنت متأكد من إلغاء تفعيل هذا QR Code؟',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إلغاء التفعيل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _qrService.deactivateAttendanceQR(qrCode);
        await _loadQRStats();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إلغاء تفعيل QR Code'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إلغاء التفعيل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _renewQRCode(String oldQrCode) async {
    try {
      String newQrCode = await _qrService.renewAttendanceQR(oldQrCode);
      setState(() {
        currentQRCode = newQrCode;
      });
      
      await _loadQRStats();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تجديد QR Code بنجاح'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تجديد QR Code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}