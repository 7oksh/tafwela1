import 'package:get/get.dart';
import 'package:new_version/database/entities/staff_history_entity.dart';
import 'package:new_version/services/local_database_service.dart';

class ReportsController extends GetxController {
  final _dbService = Get.find<LocalDatabaseService>();

  final isLoading = false.obs;
  
  // Today's metrics
  final longestResponseToday = 0.obs; // in seconds
  final highCountToday = 0.obs;
  final mediumCountToday = 0.obs;
  final lowCountToday = 0.obs;
  final busyHoursToday = <String>[].obs;

  // Weekly metrics
  final totalWeeklyUpdates = 0.obs;
  final avgResponseWeekly = 0.0.obs;
  final weeklyBusyPercentage = <String, double>{}.obs; 
  final mostBusyDays = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  // يضمن تحديث البيانات عند فتح الصفحة
  @override
  void onReady() {
    super.onReady();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final todayStr = _formatDate(now);
      final weekStartStr = _formatDate(now.subtract(const Duration(days: 7)));

      final maxResp = await _dbService.db.staffHistoryDao.findMaxResponseDurationByDate(todayStr);
      longestResponseToday.value = maxResp ?? 0;

      final todayData = await _dbService.db.staffHistoryDao.findHistoryByDate(todayStr);
      _calculateTodayTraffic(todayData);

      final totalUpdates = await _dbService.db.staffHistoryDao.countHistoryBetweenDates(weekStartStr, todayStr);
      totalWeeklyUpdates.value = totalUpdates ?? 0;

      final avgResp = await _dbService.db.staffHistoryDao.findAverageResponseDurationBetweenDates(weekStartStr, todayStr);
      avgResponseWeekly.value = avgResp ?? 0.0;

      final weekData = await _dbService.db.staffHistoryDao.findHistoryBetweenDates(weekStartStr, todayStr);
      _calculateWeeklyTraffic(weekData);

    } catch (e) {
      print("Error loading reports: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateTodayTraffic(List<StaffHistoryEntity> data) {
    int high = 0, medium = 0, low = 0;
    Map<String, int> hourCounts = {};

    for (var item in data) {
      if (item.newStatus == 'high') high++;
      else if (item.newStatus == 'medium') medium++;
      else if (item.newStatus == 'low') low++;

      if (item.updateTime.contains(':')) {
        final hourStr = item.updateTime.split(':').first;
        hourCounts[hourStr] = (hourCounts[hourStr] ?? 0) + 1;
      }
    }

    highCountToday.value = high;
    mediumCountToday.value = medium;
    lowCountToday.value = low;

    final sortedHours = hourCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    busyHoursToday.assignAll(sortedHours.take(3).map((e) => "${e.key}:00").toList());
  }

  String _getArabicDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday: return 'الاثنين';
      case DateTime.tuesday: return 'الثلاثاء';
      case DateTime.wednesday: return 'الأربعاء';
      case DateTime.thursday: return 'الخميس';
      case DateTime.friday: return 'الجمعة';
      case DateTime.saturday: return 'السبت';
      case DateTime.sunday: return 'الأحد';
      default: return '';
    }
  }

  void _calculateWeeklyTraffic(List<StaffHistoryEntity> data) {
    Map<String, int> dayUpdatesCount = {};
    Map<String, double> dayCongestionPoints = {};

    final now = DateTime.now();
    final List<String> last7Days = [];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayName = _getArabicDayName(day);
      dayUpdatesCount[dayName] = 0;
      dayCongestionPoints[dayName] = 0.0;
      last7Days.add(dayName);
    }

    for (var item in data) {
      try {
        // Parse the date carefully
        final parts = item.updateDate.split('-');
        if (parts.length == 3) {
          final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          final dayName = _getArabicDayName(date);
          
          if (dayUpdatesCount.containsKey(dayName)) {
            dayUpdatesCount[dayName] = dayUpdatesCount[dayName]! + 1;
            
            if (item.newStatus == 'high') {
              dayCongestionPoints[dayName] = dayCongestionPoints[dayName]! + 1.0;
            } else if (item.newStatus == 'medium') {
              dayCongestionPoints[dayName] = dayCongestionPoints[dayName]! + 0.5;
            }
          }
        }
      } catch (e) {
        continue;
      }
    }

    Map<String, double> percentages = {};
    for (var day in last7Days) {
      final total = dayUpdatesCount[day] ?? 0;
      if (total == 0) {
        percentages[day] = 0.0;
      } else {
        final points = dayCongestionPoints[day] ?? 0.0;
        percentages[day] = (points / total) * 100;
      }
    }

    weeklyBusyPercentage.assignAll(percentages);

    final sortedDays = percentages.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    mostBusyDays.assignAll(sortedDays.where((e) => e.value > 0).take(3).map((e) => e.key).toList());
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
