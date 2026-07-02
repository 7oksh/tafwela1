import 'package:get/get.dart';
import 'package:new_version/database/entities/staff_history_entity.dart';
import 'package:new_version/services/local_database_service.dart';

class HistoryController extends GetxController {
  final _dbService = Get.find<LocalDatabaseService>();

  final todayHistory = <StaffHistoryEntity>[].obs;
  final yesterdayHistory = <StaffHistoryEntity>[].obs;
  final weekHistory = <StaffHistoryEntity>[].obs;

  final isLoading = false.obs;
  final selectedTab = 0.obs; // 0: Today, 1: Yesterday, 2: Week

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  @override
  void onReady() {
    super.onReady();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final todayStr = _formatDate(now);
      final yesterdayStr = _formatDate(now.subtract(const Duration(days: 1)));
      final weekStartStr = _formatDate(now.subtract(const Duration(days: 7)));

      final todayData = await _dbService.db.staffHistoryDao.findHistoryByDate(todayStr);
      final yesterdayData = await _dbService.db.staffHistoryDao.findHistoryByDate(yesterdayStr);
      final weekData = await _dbService.db.staffHistoryDao.findHistoryBetweenDates(weekStartStr, todayStr);

      todayHistory.assignAll(todayData);
      yesterdayHistory.assignAll(yesterdayData);
      weekHistory.assignAll(weekData);
    } catch (e) {
      print("Error loading history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void setTab(int index) {
    selectedTab.value = index;
  }
}
