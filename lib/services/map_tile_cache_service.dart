import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:get/get.dart';

class MapTileCacheService extends GetxService {
  late final FMTCStore store;
  final RxBool isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initFmtc();
  }

  Future<void> _initFmtc() async {
    // 1. Initialise the backend (must be awaited before using FMTC)
    await FMTCObjectBoxBackend().initialise();

    // 2. Instantiate the store
    store = const FMTCStore('mapStore');

    // 3. Create the underlying DB (استخدام create بدلاً من createAsync)
    await store.manage.create();

    // 4. Mark as ready so the UI can render
    isReady.value = true;
  }
}