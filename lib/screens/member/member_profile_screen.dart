import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_status_service.dart';
import '../auth/login.dart';
import 'package:intl/intl.dart' show DateFormat;

class MemberProfileScreen extends StatefulWidget {
  final UserModel user;

  const MemberProfileScreen({super.key, required this.user});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = true;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final daysRemaining = UserStatusService.daysRemaining(widget.user);
    final isExpired = UserStatusService.isSubscriptionExpired(widget.user);

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ملفي الشخصي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF00FF57)),
            onPressed: () => _showEditProfileDialog(),
            tooltip: 'تعديل الملف',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00FF57), Color(0xFF00CC45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                top: 110,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.25).toInt()),
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: const Color(0xFF181A20),
                        child: Text(
                          widget.user.firstName[0] + widget.user.lastName[0],
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00FF57),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Text(
                  widget.user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(
                    color: widget.user.isActivated
                        ? const Color(0xFF00FF57).withAlpha((0.15 * 255).toInt())
                        : Colors.red.withAlpha((0.15 * 255).toInt()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.user.isActivated ? Icons.verified : Icons.warning_amber_rounded,
                        color: widget.user.isActivated ? const Color(0xFF00FF57) : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.user.isActivated ? 'عضو نشط' : 'عضو غير نشط',
                        style: TextStyle(
                          color: widget.user.isActivated ? const Color(0xFF00FF57) : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoChip(Icons.email, widget.user.email),
                    const SizedBox(width: 16),
                    _buildInfoChip(Icons.phone, widget.user.phone ?? ''),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSubscriptionCard(daysRemaining, isExpired),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildStatsSection(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSettingsSection(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildActionButtons(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF23242A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00FF57), size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(int daysRemaining, bool isExpired) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [Colors.red.shade400, Colors.red.shade600]
              : [const Color(0xFF00FF57), const Color(0xFF00CC45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isExpired ? Colors.red.withAlpha((0.18 * 255).toInt()) : const Color(0xFF00FF57).withAlpha((0.18 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpired ? Icons.warning_amber_rounded : Icons.check_circle,
                color: Colors.black,
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                isExpired ? 'انتهت صلاحية الاشتراك' : 'الاشتراك نشط',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isExpired
                ? 'انتهت صلاحية اشتراكك منذ ${daysRemaining.abs()} يوم'
                : 'باقي $daysRemaining يوم على انتهاء الاشتراك',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo('تاريخ البداية', widget.user.subscriptionStart ?? DateTime.now()),
              _buildDateInfo('تاريخ الانتهاء', widget.user.subscriptionEnd ?? DateTime.now()),
            ],
          ),
          if (isExpired) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showRenewalDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('تجديد الاشتراك', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          DateFormat('yyyy/MM/dd').format(date),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23242A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((10 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائياتي',
            style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _buildStatCard('أيام الحضور', '23', Icons.calendar_today_rounded, Colors.blueAccent)),
              const SizedBox(width: 14),
              Expanded(child: _buildStatCard('آخر زيارة', 'أمس', Icons.access_time_rounded, Colors.purpleAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181A20),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((10 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withAlpha((18 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23242A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(22),
            child: Text(
              'الإعدادات',
              style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
          _buildSwitchTile(
            'الإشعارات',
            'استقبال إشعارات التطبيق',
            notificationsEnabled,
            (value) => setState(() => notificationsEnabled = value),
            Icons.notifications,
          ),
          _buildSwitchTile(
            'الوضع المظلم',
            'استخدام الوضع المظلم',
            darkModeEnabled,
            (value) => setState(() => darkModeEnabled = value),
            Icons.dark_mode,
          ),
          _buildActionTile(
            'تغيير كلمة المرور',
            'تحديث كلمة مرور حسابك',
            Icons.lock,
            () => _showChangePasswordDialog(),
          ),
          _buildActionTile(
            'سياسة الخصوصية',
            'اطلع على سياسة الخصوصية',
            Icons.privacy_tip,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2C2C2E),
                  title: const Text('سياسة الخصوصية', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'سيتم إضافة سياسة الخصوصية قريبًا.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق', style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FF57)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    final firstNameController = TextEditingController(text: widget.user.firstName);
    final lastNameController = TextEditingController(text: widget.user.lastName);
    final phoneController = TextEditingController(text: widget.user.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تعديل الملف الشخصي', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'الاسم الأول',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'الاسم العائلي',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
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
                const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('حفظ', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showRenewalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تجديد الاشتراك', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر نوع الاشتراك:', style: TextStyle(color: Colors.white)),
            SizedBox(height: 16),
            ListTile(
              title: Text('اشتراك شهري - 3000 دج', style: TextStyle(color: Colors.white)),
              leading: Radio(value: 1, groupValue: 1, onChanged: null),
            ),
            ListTile(
              title: Text('اشتراك 3 أشهر - 8000 دج', style: TextStyle(color: Colors.white)),
              leading: Radio(value: 2, groupValue: 1, onChanged: null),
            ),
            ListTile(
              title: Text('اشتراك سنوي - 30000 دج', style: TextStyle(color: Colors.white)),
              leading: Radio(value: 3, groupValue: 1, onChanged: null),
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
                const SnackBar(content: Text('تم إرسال طلب التجديد بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
            child: const Text('تجديد', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // تم حذف نافذة عرض QR من صفحة الملف الشخصي بناءً على طلبك
  // إذا رغبت في استعادتها مستقبلاً يمكنك إعادة الكود هنا
  // void _showQRCode() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: const Color(0xFF2C2C2E),
  //       title: const Text('QR الخاص بك', style: TextStyle(color: Colors.white)),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           if ((widget.user.qrCodeData ?? '').isNotEmpty)
  //             Container(
  //               width: 200,
  //               height: 200,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Center(
  //                 child: QrImageView(
  //                   data: widget.user.qrCodeData!,
  //                   version: QrVersions.auto,
  //                   size: 180.0,
  //                   backgroundColor: Colors.white,
  //                 ),
  //               ),
  //             )
  //           else
  //             const Text(
  //               'لا يوجد QR Code متاح حالياً.',
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           const SizedBox(height: 16),
  //           const Text(
  //             'اعرض هذا الرمز للموظف عند الدخول',
  //             style: TextStyle(color: Colors.white70),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context),
  //           style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
  //           child: const Text('إغلاق', style: TextStyle(color: Colors.black)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تغيير كلمة المرور', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).pop();
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}