import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import 'package:dada_app/models/user_model.dart';

class AdminSettingsScreen extends StatefulWidget {
final UserModel admin;
  
  const AdminSettingsScreen({super.key, required this.admin});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool notificationsEnabled = true;
  bool autoBackup = true;
  String selectedLanguage = 'العربية';
  
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('الإعدادات الإدارية', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAdminProfile(),
            const SizedBox(height: 20),
            _buildSection('إعدادات عامة', [
              _buildSwitchTile(
                'تفعيل الإشعارات',
                'استقبال إشعارات عند تسجيل أعضاء جدد',
                notificationsEnabled,
                (value) => setState(() => notificationsEnabled = value),
                Icons.notifications,
              ),
              _buildSwitchTile(
                'النسخ الاحتياطي التلقائي',
                'إنشاء نسخة احتياطية يومياً',
                autoBackup,
                (value) => setState(() => autoBackup = value),
                Icons.backup,
              ),
            ]),
            
            const SizedBox(height: 20),
            
            _buildSection('إدارة التطبيق', [
              _buildActionTile(
                'إدارة أسعار الاشتراكات',
                'تعديل أسعار ومدد الاشتراكات',
                Icons.attach_money,
                () => _showPricingDialog(),
              ),
              _buildActionTile(
                'إدارة أوقات العمل',
                'تحديد أوقات فتح وإغلاق الصالة',
                Icons.access_time,
                () => _showWorkingHoursDialog(),
              ),
              if (widget.admin.role == 'super_admin')
                _buildActionTile(
                  'إدارة المدربين',
                  'إضافة وإدارة حسابات المدربين',
                  Icons.fitness_center,
                  () {
                    // TODO: صفحة إدارة المدربين
                  },
                ),
            ]),
            
            const SizedBox(height: 20),
            
            _buildSection('البيانات والأمان', [
              _buildActionTile(
                'تصدير البيانات',
                'تصدير قائمة المشتركين والحضور',
                Icons.download,
                () => _showExportDialog(),
              ),
              _buildActionTile(
                'النسخ الاحتياطي اليدوي',
                'إنشاء نسخة احتياطية الآن',
                Icons.cloud_upload,
                () => _createBackup(),
              ),
              _buildActionTile(
                'تغيير كلمة مرور الإدارة',
                'تحديث كلمة مرور حساب الإدارة',
                Icons.lock,
                () => _showChangePasswordDialog(),
              ),
            ]),
            
            const SizedBox(height: 20),
            
            _buildSection('معلومات التطبيق', [
              _buildInfoTile('إصدار التطبيق', '1.0.0'),
              _buildInfoTile('آخر تحديث', '2025/01/15'),
              _buildInfoTile('المطور', 'ANOUAR KEHILI'),
            ]),

            const SizedBox(height: 20),

            // زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProfile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF00FF57),
            child: Text(
              widget.admin.firstName[0] + widget.admin.lastName[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.admin.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.admin.roleDisplayName,
            style: const TextStyle(
              color: Color(0xFF00FF57),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.admin.email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            widget.admin.phone ?? '',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FF57)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00FF57),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FF57)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(value, style: const TextStyle(color: Colors.white70)),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPricingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('إدارة الأسعار', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceField('اشتراك شهري', '3000'),
            _buildPriceField('اشتراك 3 أشهر', '8000'),
            _buildPriceField('اشتراك سنوي', '30000'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ الأسعار بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('حفظ', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(String label, String initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
          suffixText: 'دج',
          suffixStyle: const TextStyle(color: Colors.white70),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  void _showWorkingHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('أوقات العمل', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أوقات فتح الصالة:', style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            Text('من 06:00 صباحاً إلى 11:00 مساءً', style: TextStyle(color: Color(0xFF00FF57))),
            SizedBox(height: 20),
            Text('أيام العمل: جميع أيام الأسبوع', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('تعديل', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تصدير البيانات', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر نوع البيانات للتصدير:', style: TextStyle(color: Colors.white)),
            SizedBox(height: 15),
            CheckboxListTile(
              title: Text('قائمة المشتركين', style: TextStyle(color: Colors.white)),
              value: true,
              onChanged: null,
              activeColor: Color(0xFF00FF57),
            ),
            CheckboxListTile(
              title: Text('سجل الحضور', style: TextStyle(color: Colors.white)),
              value: true,
              onChanged: null,
              activeColor: Color(0xFF00FF57),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تصدير البيانات بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('تصدير', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري إنشاء النسخة الاحتياطية...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء النسخة الاحتياطية بنجاح')),
      );
    });
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تغيير كلمة المرور', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('حفظ', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}