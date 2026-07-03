import 'dart:async';

import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService extends GetxService {
  final RxBool isConnected = true.obs;
  final RxString lastCheckedAt = ''.obs;

  late final StreamSubscription<InternetStatus> _subscription;
  Timer? _debounceTimer;
  InternetStatus? _pendingStatus;

  Future<ConnectivityService> init() async {
    final initialStatus = await InternetConnection().hasInternetAccess;
    isConnected.value = initialStatus;
    _updateLastCheckedAt();

    _subscription =
        InternetConnection().onStatusChange.listen((status) {
      _pendingStatus = status;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 2), () {
        if (_pendingStatus == null) return;
        isConnected.value = _pendingStatus == InternetStatus.connected;
        _updateLastCheckedAt();
      });
    });

    return this;
  }

  void _updateLastCheckedAt() {
    final now = DateTime.now();
    lastCheckedAt.value =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _subscription.cancel();
    super.onClose();
  }
}
