import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/user_model.dart';
import '../member/member_profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _showActivationNeededDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('الحساب غير مفعل', style: TextStyle(color: Colors.white)),
        content: const Text(
          'حسابك قيد المراجعة. يرجى التواصل مع الإدارة لتفعيله والوصول إلى جميع الميزات.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق', style: TextStyle(color: Color(0xFF00FF57))),
          ),
        ],
      ),
    );
  }

  late final PageController _pageController = PageController(initialPage: _currentIndex);

  @override
  Widget build(BuildContext context) {
    final isActivated = widget.user.isActivated;
    final allowedIndices = {2}; // Profile page index

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            if (!isActivated && !allowedIndices.contains(index)) {
              _showActivationNeededDialog();
              _pageController.jumpToPage(_currentIndex);
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            _buildHomeTab(),
            QRScannerScreen(user: widget.user),
            MemberProfileScreen(user: widget.user),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232325),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavBarItem(
                    icon: Icons.home,
                    label: 'الرئيسية',
                    index: 0,
                    isSelected: _currentIndex == 0,
                  ),
                  _buildNavBarItem(
                    icon: Icons.qr_code_scanner,
                    label: 'تسجيل الحضور',
                    index: 1,
                    isSelected: _currentIndex == 1,
                  ),
                  _buildNavBarItem(
                    icon: Icons.person,
                    label: 'حسابي',
                    index: 2,
                    isSelected: _currentIndex == 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final isActivated = widget.user.isActivated;
    final allowedIndices = {2}; // Profile page is always allowed
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActivated && !allowedIndices.contains(index)) {
            _showActivationNeededDialog();
            return;
          }
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00FF57).withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF00FF57).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF00FF57) : Colors.white60,
                size: isSelected ? 30 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00FF57) : Colors.white60,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 40),
        _buildSubscriptionCard(widget.user),
        const SizedBox(height: 20),
        const Text(
          'القائمة الرئيسية',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildFeatureGrid(context),
      ],
    );
  }

  Widget _buildSubscriptionCard(UserModel user) {
    final daysRemaining = user.daysRemaining;
    final isExpired = !user.isSubscriptionActive;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [Colors.red.shade400, Colors.red.shade700]
              : [Colors.tealAccent.shade400, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Text(
                  user.firstName[0],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبًا، ${user.firstName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isExpired ? 'الاشتراك منتهي' : 'عضو نشط',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'حالة الاشتراك',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isExpired ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isExpired
                      ? 'الاشتراك غير مفعل'
                      : 'الاشتراك مفعل • $daysRemaining يوم متبقٍ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (user.subscriptionStart != null && user.subscriptionEnd != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'من ${_formatDate(user.subscriptionStart!)} إلى ${_formatDate(user.subscriptionEnd!)}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final isActivated = widget.user.isActivated;

    final features = [
      {
        'title': 'تسجيل الحضور',
        'icon': Icons.qr_code_scanner,
        'color': Colors.blue,
        'onTap': () {
          if (!isActivated) {
            _showActivationNeededDialog();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QRScannerScreen(user: widget.user),
              ),
            );
          }
        },
      },
      {
        'title': 'مكتبة التمارين',
        'icon': Icons.fitness_center,
        'color': Colors.orange,
        'onTap': () {
          if (!isActivated) {
            _showActivationNeededDialog();
          } else {
            _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
          }
        },
      },
      {
        'title': 'ملفي الشخصي',
        'icon': Icons.person,
        'color': Colors.purple,
        'onTap': () => _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.ease),
      },
      {
        'title': 'الدعم الفني',
        'icon': Icons.support_agent,
        'color': Colors.teal,
        'onTap': () => _showSupportDialog(),
      },
      {
        'title': 'حول التطبيق',
        'icon': Icons.info_outline,
        'color': Colors.pink,
        'onTap': () => _showAboutDialog(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];
        return GestureDetector(
          onTap: feature['onTap'] as VoidCallback,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: (feature['color'] as Color).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (feature['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: feature['color'] as Color,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  feature['title'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSupportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تابعنا على مواقع التواصل الاجتماعي',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.facebook, color: Color(0xFF00FF57), size: 32),
                  onPressed: () {
                    launchUrl(Uri.parse('https://facebook.com/yourpage'));
                  },
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.tiktok, color: Color(0xFF00FF57), size: 32),
                  onPressed: () {
                    launchUrl(Uri.parse('https://tiktok.com/@yourusername'));
                  },
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.instagram, color: Color(0xFF00FF57), size: 32),
                  onPressed: () {
                    launchUrl(Uri.parse('https://instagram.com/yourusername'));
                  },
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.whatsapp, color: Color(0xFF00FF57), size: 32),
                  onPressed: () {
                    launchUrl(Uri.parse('https://wa.me/213699446868'));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('إغلاق'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF57),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.tealAccent, size: 42),
                    const SizedBox(height: 10),
                    const Text(
                      'تطبيق DADA GYM',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الإصدار 1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'عن التطبيق:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.qr_code_scanner, 'تسجيل الحضور عبر QR Code'),
              _buildInfoRow(Icons.fitness_center, 'الوصول إلى مكتبة التمارين'),
              _buildInfoRow(Icons.verified_user, 'متابعة حالة الاشتراك'),
              _buildInfoRow(Icons.support_agent, 'دعم فني مباشر'),

              const SizedBox(height: 28),
              const Text(
                'مطور التطبيق:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 16,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Anouar Kehili',
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse("https://wa.me/213699446868"));
                  },
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                  label: const Text('التواصل عبر واتساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('إغلاق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.tealAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}