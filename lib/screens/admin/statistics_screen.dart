import 'package:flutter/material.dart';
import '../../services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedPeriod = 'هذا الشهر';
  final StatisticsService _statisticsService = StatisticsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الإحصائيات والتقارير', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Color(0xFF00FF57)),
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'اليوم', child: Text('اليوم')),
              const PopupMenuItem(value: 'هذا الأسبوع', child: Text('هذا الأسبوع')),
              const PopupMenuItem(value: 'هذا الشهر', child: Text('هذا الشهر')),
              const PopupMenuItem(value: 'هذا العام', child: Text('هذا العام')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 20),
          _buildOverviewCards(),
          const SizedBox(height: 20),
          _buildAttendanceChart(),
          const SizedBox(height: 20),
          _buildSubscriptionStats(),
          const SizedBox(height: 20),
          _buildRevenueCard(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات الفترة المحددة',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            selectedPeriod,
            style: const TextStyle(color: Color(0xFF00FF57), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return FutureBuilder<List<int>>(
      future: Future.wait([
        _statisticsService.getTotalUsers(),
        _statisticsService.getActiveUsers(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Row(
            children: [
              Expanded(child: Center(child: CircularProgressIndicator())),
              SizedBox(width: 12),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }
        final total = snapshot.data![0];
        final active = snapshot.data![1];
        return Row(
          children: [
            Expanded(child: _buildStatCard('إجمالي المشتركين', total.toString(), '', Colors.blue, Icons.people)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('المشتركين النشطين', active.toString(), '', Colors.green, Icons.check_circle)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, String change, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                change,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معدل الحضور الأسبوعي',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildSimpleChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    final days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    return FutureBuilder<Map<String, int>>(
      future: _statisticsService.getWeeklyAttendance(),
      builder: (context, snapshot) {
        final values = days.map((d) => snapshot.data != null ? snapshot.data![d] ?? 0 : 0).toList();
        final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(days.length, (index) {
            final height = (values[index] / (maxVal == 0 ? 1 : maxVal)) * 150;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  values[index].toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 30,
                  height: height,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF57),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  days[index],
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildSubscriptionStats() {
    return FutureBuilder<List<int>>(
      future: Future.wait([
        _statisticsService.getActiveUsers(),
        _statisticsService.getExpiredSubscriptions(),
        _statisticsService.getExpiringSoonSubscriptions(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final active = snapshot.data![0];
        final expired = snapshot.data![1];
        final soon = snapshot.data![2];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'حالة الاشتراكات',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSubscriptionItem('اشتراكات نشطة', active.toString(), Colors.green),
              _buildSubscriptionItem('اشتراكات منتهية', expired.toString(), Colors.red),
              _buildSubscriptionItem('اشتراكات تنتهي قريباً', soon.toString(), Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionItem(String title, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return FutureBuilder<int>(
      future: _statisticsService.getMonthlyRevenue(),
      builder: (context, snapshot) {
        final revenue = snapshot.data ?? 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00FF57), Color(0xFF00CC45)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الإيرادات الشهرية',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${revenue.toString()} دج',
                style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}