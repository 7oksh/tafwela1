import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum SortType { distance, crowd, rating }

class SearchPreferencesService {
  final GetStorage storage;

  SearchPreferencesService(this.storage);

  final RxInt updateTrigger = 0.obs;

  void triggerUpdate() {
    updateTrigger.value++;
  }

  static const String _keySort = 'pref_sort';
  static const String _keyMaxDist = 'pref_max_dist';
  static const String _keyOpenOnly = 'pref_open_only';
  static const String _keyCrowdNotify = 'pref_crowd_notify';

  SortType get sortType {
    final sortString = storage.read<String>(_keySort) ?? SortType.distance.name;
    return SortType.values.firstWhere(
      (e) => e.name == sortString,
      orElse: () => SortType.distance,
    );
  }

  set sortType(SortType value) {
    storage.write(_keySort, value.name);
  }

  double get maxDistance {
    return (storage.read<double>(_keyMaxDist) ?? 10.0);
  }

  set maxDistance(double value) {
    final clamped = value.clamp(1.0, 50.0);
    storage.write(_keyMaxDist, clamped);
  }

  bool get openStationsOnly {
    return storage.read<bool>(_keyOpenOnly) ?? false;
  }

  set openStationsOnly(bool value) {
    storage.write(_keyOpenOnly, value);
  }

  bool get notifyCrowdChanges {
    return storage.read<bool>(_keyCrowdNotify) ?? true;
  }

  set notifyCrowdChanges(bool value) {
    storage.write(_keyCrowdNotify, value);
  }
}
