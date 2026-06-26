import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/utils/constants.dart';

class StaffReportsView extends StatefulWidget {
  const StaffReportsView({super.key});

  @override
  State<StaffReportsView> createState() => _StaffReportsViewState();
}

class _StaffReportsViewState extends State<StaffReportsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios,
              color: AppColors.white, size: 18),
          onPressed: Get.back,
        ),
        centerTitle: true,
        title: Text(
          'التقارير',
          style: GoogleFonts.cairo(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: AppColors.navyHeader,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.white,
              indicatorWeight: 3,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withValues(alpha: 0.5),
              labelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14),
              tabs: const [
                Tab(text: 'يومي'),
                Tab(text: 'أسبوعي'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DailyReportTab(),
          _WeeklyReportTab(),
        ],
      ),
    );
  }
}

class _DailyReportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _DateHeader(
          label: 'تقرير اليوم',
          sub: _formatDate(DateTime.now()),
        ),
        const SizedBox(height: 12),
        _buildStatsRow(
          stats: [
            _Stat(label: 'إجمالي التحديثات', value: '24', icon: Icons.update, color: AppColors.primaryBlue),
            _Stat(label: 'تحديثاتك', value: '8', icon: Icons.person, color: AppColors.success),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatsRow(
          stats: [
            _Stat(label: 'ازدحام شديد', value: '6', icon: Icons.warning_amber_rounded, color: AppColors.danger),
            _Stat(label: 'ازدحام معتدل', value: '10', icon: Icons.remove_circle_outline, color: AppColors.warning),
          ],
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: 'تفصيل حسب المحطة'),
        const SizedBox(height: 10),
        ..._dailyStationData.map((s) => _StationReportRow(data: s)),
        const SizedBox(height: 16),
        _SectionHeader(title: 'نشاط ساعة بساعة'),
        const SizedBox(height: 10),
        _HourlyActivityChart(data: _dailyHourlyActivity),
      ],
    );
  }

  Widget _buildStatsRow({required List<_Stat> stats}) {
    return Row(
      children: stats
          .map(
            (s) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(s.icon, color: s.color, size: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.value,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                    Text(
                      s.label,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  static final _dailyStationData = [
    {'name': 'محطة النور', 'updates': 6, 'color': AppColors.danger},
    {'name': 'محطة الأمل', 'updates': 4, 'color': AppColors.warning},
    {'name': 'محطة الفجر', 'updates': 8, 'color': AppColors.success},
    {'name': 'محطة الربوة', 'updates': 6, 'color': AppColors.primaryBlue},
  ];

  static const _dailyHourlyActivity = [
    0, 0, 0, 0, 1, 2, 4, 5, 3, 2, 3, 4, 5, 3, 2, 2, 3, 4, 5, 4, 3, 2, 1, 0
  ];
}

class _WeeklyReportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _DateHeader(
          label: 'تقرير الأسبوع',
          sub: 'الأسبوع الحالي',
        ),
        const SizedBox(height: 12),
        _buildWeeklyStats(),
        const SizedBox(height: 16),
        _SectionHeader(title: 'التحديثات اليومية'),
        const SizedBox(height: 10),
        _WeeklyBarChart(data: _weeklyData),
        const SizedBox(height: 16),
        _SectionHeader(title: 'أكثر المحطات تحديثاً'),
        const SizedBox(height: 10),
        ..._topStations.map((s) => _TopStationCard(data: s)),
      ],
    );
  }

  Widget _buildWeeklyStats() {
    return Row(
      children: [
        Expanded(
          child: _WeekStatCard(
            label: 'إجمالي التحديثات',
            value: '142',
            sub: '+18% عن الأسبوع الماضي',
            color: AppColors.primaryBlue,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WeekStatCard(
            label: 'معدل الازدحام',
            value: '62%',
            sub: 'ازدحام متوسط',
            color: AppColors.warning,
            icon: Icons.people_alt_outlined,
          ),
        ),
      ],
    );
  }

  static const _weeklyData = [18, 22, 25, 28, 16, 15, 18];

  static const _topStations = [
    {'name': 'محطة الفجر', 'count': 32, 'pct': 0.8},
    {'name': 'محطة النور', 'count': 28, 'pct': 0.7},
    {'name': 'محطة الأمل', 'count': 22, 'pct': 0.55},
    {'name': 'محطة الربوة', 'count': 18, 'pct': 0.45},
  ];
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label, required this.sub});

  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyDark)),
            Text(sub,
                style: GoogleFonts.cairo(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Row(
            children: [
              const Icon(Icons.download_outlined,
                  size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 4),
              Text('تصدير',
                  style: GoogleFonts.cairo(
                      fontSize: 12, color: AppColors.primaryBlue)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.navyDark,
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _StationReportRow extends StatelessWidget {
  const _StationReportRow({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final color = data['color'] as Color;
    final updates = data['updates'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            data['name'] as String,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: updates / 10,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$updates',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyActivityChart extends StatelessWidget {
  const _HourlyActivityChart({required this.data});
  final List<int> data;

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (i) {
                final h = maxVal > 0 ? (data[i] / maxVal) : 0.0;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                    height: 80 * h,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['12ص', '6ص', '12م', '6م', '11م']
                .map((t) => Text(t,
                    style: GoogleFonts.cairo(
                        fontSize: 9, color: AppColors.textSecondary)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.data});
  final List<int> data;

  static const _days = ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final h = maxVal > 0 ? (data[i] / maxVal) : 0.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${data[i]}',
                        style: GoogleFonts.cairo(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 100 * h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.accentBlue
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              7,
              (i) => Expanded(
                child: Text(
                  _days[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStatCard extends StatelessWidget {
  const _WeekStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark)),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(sub,
              style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TopStationCard extends StatelessWidget {
  const _TopStationCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final pct = data['pct'] as double;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station,
              color: AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] as String,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyDark)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor:
                        AppColors.primaryBlue.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${data['count']}',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) =>
    '${dt.day}/${dt.month}/${dt.year}';
