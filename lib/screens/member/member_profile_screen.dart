import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_status_service.dart';
import '../../services/theme_service.dart';
import '../auth/login.dart';
import 'package:intl/intl.dart';

class MemberProfileScreen extends StatefulWidget {
  final UserModel user;

  const MemberProfileScreen({super.key, required this.user});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  bool notificationsEnabled = true;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final daysRemaining = UserStatusService.daysRemaining(widget.user);
    final isExpired = UserStatusService.isSubscriptionExpired(widget.user);
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ملفي الشخصي',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Theme.of(context).colorScheme.primary,
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
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
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Theme.of(context).colorScheme.background,
                        child: Text(
                          widget.user.firstName[0] + widget.user.lastName[0],
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(
                    color: widget.user.isActivated
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.user.isActivated ? Icons.verified : Icons.warning_amber_rounded,
                        color: widget.user.isActivated 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.user.isActivated ? 'عضو نشط' : 'عضو غير نشط',
                        style: TextStyle(
                          color: widget.user.isActivated 
                              ? Theme.of(context).colorScheme.primary 
                              : Colors.red,
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
            child: _buildSettingsSection(themeService),
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
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: Theme.of(context).colorScheme.primary, 
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
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
              : [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isExpired 
                ? Colors.red.withAlpha((0.18 * 255).toInt()) 
                : Theme.of(context).colorScheme.primary.withAlpha((0.18 * 255).toInt()),
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
        color: Theme.of(context).colorScheme.surface,
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
          Text(
            'إحصائياتي',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
        color: Theme.of(context).colorScheme.background,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeService themeService) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              'الإعدادات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
            themeService.isDarkMode,
            (value) => themeService.toggleTheme(),
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
            () => _showPrivacyDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title, 
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle, 
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title, 
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle, 
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios, 
        color: Theme.of(context).textTheme.bodySmall?.color, 
        size: 16,
      ),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'تعديل الملف الشخصي', 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'الاسم الأول',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'الاسم العائلي',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء', 
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showRenewalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'تجديد الاشتراك', 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر نوع الاشتراك:', 
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'اشتراك شهري - 3000 دج', 
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              leading: Radio(value: 1, groupValue: 1, onChanged: null),
            ),
            ListTile(
              title: Text(
                'اشتراك 3 أشهر - 8000 دج', 
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              leading: Radio(value: 2, groupValue: 1, onChanged: null),
            ),
            ListTile(
              title: Text(
                'اشتراك سنوي - 30000 دج', 
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              leading: Radio(value: 3, groupValue: 1, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء', 
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال طلب التجديد بنجاح')),
              );
            },
            child: const Text('تجديد'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'تغيير كلمة المرور', 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء', 
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'سياسة الخصوصية', 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Text(
            '''
نحن في DADA GYM نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.

البيانات التي نجمعها:
• الاسم والبريد الإلكتروني
• رقم الهاتف (اختياري)
• بيانات الحضور والاشتراك

كيف نستخدم بياناتك:
• إدارة عضويتك في الصالة
• تتبع حضورك وتقدمك
• التواصل معك بخصوص الخدمات

حماية البيانات:
• نستخدم تشفير متقدم لحماية بياناتك
• لا نشارك بياناتك مع أطراف ثالثة
• يمكنك طلب حذف بياناتك في أي وقت

للاستفسارات حول سياسة الخصوصية، يرجى التواصل معنا.
            ''',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'تسجيل الخروج', 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج؟',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء', 
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
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