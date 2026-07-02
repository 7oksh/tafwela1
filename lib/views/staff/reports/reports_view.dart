import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:new_version/controllers/staff/reports_controller.dart';

class ReportsView extends StatelessWidget {
  ReportsView({super.key});

  final ReportsController controller = Get.put(ReportsController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('تقارير المحطة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: const Color(0xFF1E3A5F),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: const Color(0xFF0EA5A8),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: 'يومي'),
              Tab(text: 'أسبوعي'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F)));
          }
          return TabBarView(
            children: [
              _buildTodayReport(),
              _buildWeeklyReport(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTodayReport() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'أطول فترة انتظار',
                  value: _formatDuration(controller.longestResponseToday.value),
                  icon: Icons.access_time_filled,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'أوقات الذروة',
                  value: controller.busyHoursToday.isNotEmpty ? controller.busyHoursToday.first : 'لا يوجد',
                  icon: Icons.trending_up,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildChartSection(
            title: 'مستويات الازدحام اليوم',
            child: _buildTodayChart(),
          ),
          const SizedBox(height: 20),
          _buildListSection(
            title: 'ساعات الذروة المرصودة',
            items: controller.busyHoursToday.map((e) => _buildListItem(e, 'ازدحام مرتفع')).toList(),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'إجمالي التحديثات',
                  value: controller.totalWeeklyUpdates.value.toString(),
                  icon: Icons.assignment_turned_in,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'سرعة الاستجابة',
                  value: _formatDuration(controller.avgResponseWeekly.value.toInt()),
                  icon: Icons.speed,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildChartSection(
            title: 'مؤشر الازدحام الأسبوعي (%)',
            child: _buildWeeklyChart(),
          ),
          const SizedBox(height: 20),
          _buildListSection(
            title: 'الأيام الأكثر ازدحاماً (نسبة الذروة)',
            items: controller.mostBusyDays.map((e) {
              final percent = controller.weeklyBusyPercentage[e]?.toStringAsFixed(0) ?? '0';
              return _buildListItem(e, '$percent% زحام');
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildChartSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A5F))),
          const SizedBox(height: 30),
          SizedBox(height: 260, child: child), 
        ],
      ),
    );
  }

  Widget _buildTodayChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (controller.highCountToday.value + controller.mediumCountToday.value + controller.lowCountToday.value).toDouble() + 5,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String text = '';
                switch (value.toInt()) {
                  case 0: text = 'مرتفع'; break;
                  case 1: text = 'متوسط'; break;
                  case 2: text = 'منخفض'; break;
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(text, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: controller.highCountToday.value.toDouble(), color: Colors.redAccent, width: 25, borderRadius: BorderRadius.circular(6))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: controller.mediumCountToday.value.toDouble(), color: Colors.orangeAccent, width: 25, borderRadius: BorderRadius.circular(6))]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: controller.lowCountToday.value.toDouble(), color: Colors.teal, width: 25, borderRadius: BorderRadius.circular(6))]),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = controller.weeklyBusyPercentage.keys.toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 120, 
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF1E3A5F),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}%',
                GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60, 
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  String day = days[value.toInt()];
                  return SideTitleWidget(
                    meta: meta,
                    space: 12,
                    child: Transform.rotate(
                      angle: -0.4, 
                      child: Text(day, 
                        style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text('${value.toInt()}%', style: GoogleFonts.cairo(fontSize: 9, color: Colors.grey)),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: days.asMap().entries.map((e) {
          final val = controller.weeklyBusyPercentage[e.value] ?? 0.0;
          Color barColor = const Color(0xFF0EA5A8);
          if (val > 70) barColor = Colors.redAccent;
          else if (val > 40) barColor = Colors.orangeAccent;

          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: val == 0 ? 3 : val,
                color: barColor,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: Colors.grey.withOpacity(0.05)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListSection({required String title, required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A5F))),
          const SizedBox(height: 20),
          if (items.isEmpty)
            Center(child: Text('لا توجد بيانات كافية حالياً', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13)))
          else
            ...items,
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF0EA5A8), shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: subtitle.contains('زحام') || subtitle.contains('مرتفع') ? Colors.red.withOpacity(0.08) : const Color(0xFF0EA5A8).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(subtitle, style: GoogleFonts.cairo(
              fontSize: 12, 
              color: subtitle.contains('زحام') || subtitle.contains('مرتفع') ? Colors.redAccent : const Color(0xFF0EA5A8),
              fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '${m}د ${s}ث';
    return '${s}ث';
  }
}
