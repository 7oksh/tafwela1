import 'package:get/get.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/utils/app_snackbar.dart';
import 'package:new_version/services/search_preferences_service.dart';

class DriverPreferencesController extends GetxController {
  final SearchPreferencesService _preferences =
      Get.find<SearchPreferencesService>();

  late final Rx<SortType> sortBy;
  late final RxBool notifyOpenOnly;
  late final RxBool notifyCrowdChanges;
  late final RxDouble maxDistance;

  @override
  void onInit() {
    super.onInit();
    sortBy = _preferences.sortType.obs;
    notifyOpenOnly = _preferences.openStationsOnly.obs;
    notifyCrowdChanges = _preferences.notifyCrowdChanges.obs;
    maxDistance = _preferences.maxDistance.obs;
  }

  void savePreferences() {
    _preferences.sortType = sortBy.value;
    _preferences.openStationsOnly = notifyOpenOnly.value;
    _preferences.notifyCrowdChanges = notifyCrowdChanges.value;
    _preferences.maxDistance = maxDistance.value;
    
    Get.back();
    
    AppSnackbar.success(
      'تم حفظ تفضيلاتك بنجاح',
      title: 'تم الحفظ',
      position: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      textColor: AppColors.white,
    );
    
    // Trigger update after UI handles the navigation and snackbar
    Future.microtask(() {
      _preferences.triggerUpdate();
    });
    
    // Trigger update after UI handles the navigation and snackbar
    Future.microtask(() {
      _preferences.triggerUpdate();
    });
  }
}
