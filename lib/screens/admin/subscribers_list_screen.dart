import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/user_status_service.dart';

class SubscribersListScreen extends StatefulWidget {
  const SubscribersListScreen({super.key});

  @override
  State<SubscribersListScreen> createState() => _SubscribersListScreenState();
}

class _SubscribersListScreenState extends State<SubscribersListScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool showActiveOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
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
          title: const Text('إدارة المشتركين', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(
                showActiveOnly ? Icons.people : Icons.people_outline,
                color: const Color(0xFF00FF57),
              ),
              onPressed: () {
                setState(() {
                  showActiveOnly = !showActiveOnly;
                });
              },
              tooltip: showActiveOnly ? 'عرض الجميع' : 'عرض النشطين فقط',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildUsersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'ابحث باسم أو بريد إلكتروني...',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: Color(0xFF00FF57)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text('الجميع'),
            selected: !showActiveOnly,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  showActiveOnly = false;
                });
              }
            },
            selectedColor: const Color(0xFF00FF57),
            labelStyle: TextStyle(
              color: !showActiveOnly ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('النشطين'),
            selected: showActiveOnly,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  showActiveOnly = true;
                });
              }
            },
            selectedColor: const Color(0xFF00FF57),
            labelStyle: TextStyle(
              color: showActiveOnly ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<List<UserModel>>(
      stream: showActiveOnly 
          ? _userService.getUsersByStatus(true)
          : _userService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FF57)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطأ في تحميل البيانات: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        List<UserModel> users = snapshot.data ?? [];
        
        // تطبيق البحث
        if (searchQuery.isNotEmpty) {
          users = users.where((user) {
            return user.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                   user.email.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
        }

        // فلترة المستخدمين العاديين فقط (استبعاد الإداريين)
        users = users.where((user) => user.role == UserRole.user).toList();

        if (users.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد نتائج',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildUserCard(users[index]);
          },
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final isExpired = UserStatusService.isSubscriptionExpired(user);
    
    return Card(
      color: const Color(0xFF2C2C2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00FF57),
                  child: Text(
                    user.firstName[0],
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      if (user.phone != null)
                        Text(
                          user.phone!,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                    ],
                  ),
                ),
                _buildStatusChip(user),
              ],
            ),
            
            if (user.subscriptionStart != null && user.subscriptionEnd != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات الاشتراك:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'من: ${_formatDate(user.subscriptionStart!)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'إلى: ${_formatDate(user.subscriptionEnd!)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    if (!isExpired && user.isActivated)
                      Text(
                        'باقي: ${user.daysRemaining} يوم',
                        style: const TextStyle(color: Color(0xFF00FF57), fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Row(
              children: [
                if (!user.isActivated)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _activateUser(user),
                      icon: const Icon(Icons.check_circle, color: Colors.black),
                      label: const Text('تفعيل', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF57),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                
                if (user.isActivated && (isExpired || user.subscriptionEnd == null))
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _renewSubscription(user),
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      label: const Text('تجديد', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF57),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                
                if (user.isActivated && !isExpired) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _renewSubscription(user),
                      icon: const Icon(Icons.add_circle, color: Colors.black),
                      label: const Text('تمديد', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF57),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                IconButton(
                  onPressed: () => _showUserOptions(user),
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(UserModel user) {
    String status;
    Color color;
    final isExpired = UserStatusService.isSubscriptionExpired(user);
    if (!user.isActivated) {
      status = 'غير مفعل';
      color = Colors.orange;
    } else if (isExpired) {
      status = 'منتهي';
      color = Colors.red;
    } else {
      status = 'نشط';
      color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _activateUser(UserModel user) {
    _showSubscriptionDialog(user, isActivation: true);
  }

  void _renewSubscription(UserModel user) {
    _showSubscriptionDialog(user, isActivation: false);
  }

  void _showSubscriptionDialog(UserModel user, {required bool isActivation}) {
    int selectedDays = 30;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: Text(
            isActivation ? 'تفعيل المشترك' : 'تجديد الاشتراك',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر مدة الاشتراك لـ ${user.fullName}:',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: selectedDays,
                dropdownColor: const Color(0xFF1C1C1E),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'مدة الاشتراك',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 30, child: Text('شهر واحد (30 يوم)')),
                  DropdownMenuItem(value: 90, child: Text('3 أشهر (90 يوم)')),
                  DropdownMenuItem(value: 180, child: Text('6 أشهر (180 يوم)')),
                  DropdownMenuItem(value: 365, child: Text('سنة كاملة (365 يوم)')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDays = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  DateTime startDate = DateTime.now();
                  DateTime endDate = startDate.add(Duration(days: selectedDays));
                  
                  await _userService.updateUserSubscription(user.uid, startDate, endDate);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isActivation 
                            ? 'تم تفعيل المشترك بنجاح'
                            : 'تم تجديد الاشتراك بنجاح'
                      ),
                      backgroundColor: const Color(0xFF00FF57),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF57)),
              child: Text(
                isActivation ? 'تفعيل' : 'تجديد',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserOptions(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF00FF57)),
              title: const Text('تغيير إلى إداري', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _changeUserRole(user, UserRole.admin);
              },
            ),
            ListTile(
              leading: Icon(
                user.isActivated ? Icons.block : Icons.check_circle,
                color: user.isActivated ? Colors.red : Colors.green,
              ),
              title: Text(
                user.isActivated ? 'إلغاء التفعيل' : 'تفعيل الحساب',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleUserActivation(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف المستخدم', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteUser(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeUserRole(UserModel user, UserRole newRole) async {
    try {
      await _userService.updateUserRole(user.uid, newRole);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير الرتبة بنجاح'),
          backgroundColor: Color(0xFF00FF57),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تغيير الرتبة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleUserActivation(UserModel user) async {
    try {
      await _userService.toggleUserActivation(user.uid, !user.isActivated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.isActivated ? 'تم إلغاء تفعيل المستخدم' : 'تم تفعيل المستخدم'
          ),
          backgroundColor: const Color(0xFF00FF57),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
        content: Text(
          'هل أنت متأكد من حذف ${user.fullName}؟\nهذا الإجراء لا يمكن التراجع عنه.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _userService.deleteUser(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المستخدم بنجاح'),
            backgroundColor: Color(0xFF00FF57),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحذف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}