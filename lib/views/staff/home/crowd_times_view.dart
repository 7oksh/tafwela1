import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/utils/constants.dart';

class CrowdTimesView extends StatefulWidget {
  const CrowdTimesView({super.key, this.stationName = 'المحطة'});

  final String stationName;

  @override
  State<CrowdTimesView> createState() => _CrowdTimesViewState();
}

class _CrowdTimesViewState extends State<CrowdTimesView> {
  int _selectedDay = DateTime.now().weekday - 1;

  static const _days = [
    'الاثنين', 'الثلاثاء', 'الأربعاء',
    'الخميس', 'الجمعة', 'السبت', 'الأحد',
  ];

  // Mock hourly crowd data per day (0-100 %)
  static const _hourlyData = [
    [10, 15, 5, 5, 20, 45, 80, 75, 60, 50, 55, 65, 70, 55, 40, 35, 60, 80, 90, 75, 55, 40, 25, 15],
    [10, 10, 5, 5, 15, 40, 75, 70, 55, 45, 50, 60, 65, 50, 35, 30, 55, 75, 85, 70, 50, 35, 20, 10],
    [10, 10, 5, 5, 20, 50, 85, 80, 65, 55, 60, 70, 75, 60, 45, 40, 65, 85, 95, 80, 60, 45, 30, 15],
    [10, 10, 5, 5, 20, 50, 80, 75, 65, 55, 60, 70, 75, 60, 45, 40, 65, 90, 100, 85, 65, 50, 35, 20],
    [15, 10, 5, 5, 10, 25, 50, 45, 40, 35, 40, 50, 55, 45, 35, 30, 45, 55, 65, 60, 50, 40, 30, 20],
    [5, 5, 5, 5, 10, 20, 35, 40, 45, 50, 55, 60, 65, 60, 50, 45, 50, 55, 60, 55, 45, 35, 25, 15],
    [5, 5, 5, 5, 15, 30, 50, 55, 55, 50, 55, 65, 70, 60, 50, 45, 55, 65, 75, 70, 55, 40, 30, 15],
  ];

  String _levelLabel(int value) {
    if (value >= 80) return 'ازدحام شديد';
    if (value >= 50) return 'ازدحام متوسط';
    if (value >= 20) return 'ازدحام خفيف';
    return 'هادئ';
  }

  Color _levelColor(int value) {
    if (value >= 80) return AppColors.danger;
    if (value >= 50) return AppColors.warning;
    if (value >= 20) return AppColors.success;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final data = _hourlyData[_selectedDay];
    final currentHour = DateTime.now().hour;

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
          'أوقات الازدحام',
          style: GoogleFonts.cairo(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildStationHeader(),
          const SizedBox(height: 16),
          _buildDaySelector(),
          const SizedBox(height: 16),
          _buildCurrentStatus(data[currentHour]),
          const SizedBox(height: 16),
          _buildHourlyChart(data, currentHour),
          const SizedBox(height: 16),
          _buildPeakHours(data),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStationHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyHeader],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.local_gas_station,
                color: AppColors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.stationName,
                style: GoogleFonts.cairo(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'تحليل أوقات الذروة',
                style: GoogleFonts.cairo(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = i == _selectedDay;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.textMuted.withValues(alpha: 0.3),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  _days[i],
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.navyDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatus(int value) {
    final color = _levelColor(value);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.people_alt_outlined, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الحالة الحالية (${DateTime.now().hour}:00)',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _levelLabel(value),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          _Gauge(value: value, color: color),
        ],
      ),
    );
  }

  Widget _buildHourlyChart(List<int> data, int currentHour) {
    return Container(
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
          Text(
            'توزيع الازدحام على مدار اليوم',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (hour) {
                final value = data[hour];
                final isNow = hour == currentHour;
                final color = _levelColor(value);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isNow)
                        Container(
                          width: 2,
                          height: 8,
                          color: AppColors.primaryBlue,
                        ),
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: value / 100,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isNow
                                  ? AppColors.primaryBlue
                                  : color.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(3),
                              ),
                            ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['12ص', '6ص', '12م', '6م', '11م']
                .map((t) => Text(
                      t,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakHours(List<int> data) {
    final sorted = List.generate(24, (i) => MapEntry(i, data[i]))
      ..sort((a, b) => b.value.compareTo(a.value));
    final peak = sorted.take(3).toList();

    return Container(
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
          Text(
            'أوقات الذروة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 12),
          ...peak.map((e) {
            final color = _levelColor(e.value);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${e.key}:00',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: e.value / 100,
                        backgroundColor:
                            color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${e.value}%',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _LegendItem(color: AppColors.danger, label: 'شديد'),
        _LegendItem(color: AppColors.warning, label: 'متوسط'),
        _LegendItem(color: AppColors.success, label: 'خفيف'),
        _LegendItem(color: AppColors.textMuted, label: 'هادئ'),
      ],
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 5,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            '$value%',
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
              fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
