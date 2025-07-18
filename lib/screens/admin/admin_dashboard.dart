import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/attendance_service.dart';
import '../../services/theme_service.dart';
import 'subscribers_list_screen.dart';
import 'attendance_screen.dart';
import 'statistics_screen.dart';
import 'admin_settings_screen.dart';
import 'qr_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel admin;
  
  const AdminDashboard({super.key, required this.admin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final UserService _userService = UserService();
  final AttendanceService _attendanceService = AttendanceService();
  
  Map<String, int> userStats = {};
  Map<String, int> attendanceStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userStatsData = await _userService.getUserStats();
      final attendanceStatsData = await _attendanceService.getAttendanceStats();
      
      setState(() {
        userStats = userStatsData;
        attendanceStats = attendanceStatsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لوحة تحكم الإدارة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'مرحباً ${widget.admin.firstName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.admin.roleDisplayName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.refresh, 
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _loadStats,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadStats,
          color: Theme.of(context).colorScheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              else
                _buildQuickStats(),
              const SizedBox(height: 20),
              Text(
                'الإدارة والتحكم',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildAdminGrid(context),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المشتركين'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'الحضور'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscribersListScreen()));
                break;
              case 2:
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                break;
              case 3:
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QRManagementScreen()));
                break;
              case 4:
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminSettingsScreen(admin: widget.admin)));
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.admin_panel_settings, size: 30, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً ${widget.admin.fullName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      widget.admin.roleDisplayName,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'إدارة شاملة لصالة DADA GYM',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildQuickStatItem('المشتركين النشطين', userStats['active']?.toString() ?? '0'),
              const SizedBox(width: 20),
              _buildQuickStatItem('الحضور اليوم', attendanceStats['today']?.toString() ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('إجمالي المشتركين', userStats['total']?.toString() ?? '0', Icons.people, Colors.blueAccent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('الحضور اليوم', attendanceStats['today']?.toString() ?? '0', Icons.access_time_rounded, Colors.greenAccent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('غير المفعلين', userStats['inactive']?.toString() ?? '0', Icons.pending_actions_rounded, Colors.orangeAccent),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
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

  Widget _buildAdminGrid(BuildContext context) {
    final adminFeatures = [
      {
        'title': 'إدارة المشتركين',
        'icon': Icons.people_alt,
        'color': Colors.blueAccent,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscribersListScreen())),
      },
      {
        'title': 'سجل الحضور',
        'icon': Icons.access_time_rounded,
        'color': Colors.greenAccent,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
      },
      {
        'title': 'إدارة QR',
        'icon': Icons.qr_code_2_rounded,
        'color': Colors.purpleAccent,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRManagementScreen())),
      },
      {
        'title': 'الإحصائيات',
        'icon': Icons.bar_chart_rounded,
        'color': Colors.tealAccent,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen())),
      },
      {
        'title': 'الإعدادات',
        'icon': Icons.settings_rounded,
        'color': Colors.grey,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminSettingsScreen(admin: widget.admin))),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adminFeatures.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final feature = adminFeatures[index];
        return GestureDetector(
          onTap: feature['onTap'] as VoidCallback,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (feature['color'] as Color).withOpacity(0.3), 
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (feature['color'] as Color).withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (feature['color'] as Color).withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: feature['color'] as Color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  feature['title'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}