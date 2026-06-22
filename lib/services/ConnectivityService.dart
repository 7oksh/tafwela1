import 'dart:async';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService extends GetxService {
  final RxBool isConnected = true.obs;

  StreamSubscription? _subscription;

  Future<ConnectivityService> init() async {
    isConnected.value =
    await InternetConnection().hasInternetAccess;

    _subscription =
        InternetConnection().onStatusChange.listen((status) {
          isConnected.value =
              status == InternetStatus.connected;
        });

    return this;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}