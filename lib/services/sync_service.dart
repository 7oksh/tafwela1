import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'package:new_version/services/local_database_service.dart';

class SyncService extends GetxService {
  SyncService({
    FirebaseFirestore? firestore,
    LocalDatabaseService? localDb,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _localDb = localDb;

  final FirebaseFirestore _firestore;
  final LocalDatabaseService? _localDb;

  bool _wasOffline = false;
  bool _isSyncing = false;

  LocalDatabaseService get _localDbResolved =>
      _localDb ?? Get.find<LocalDatabaseService>();

  @override
  void onInit() {
    super.onInit();
    final connectivity = Get.find<ConnectivityService>();
    _wasOffline = !connectivity.isConnected.value;

    ever(connectivity.isConnected, (connected) {
      if (connected == true && _wasOffline) {
        _processPendingWrites();
      }
      _wasOffline = connected != true;
    });
  }

  Future<void> writeOrQueue({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    String operation = 'update',
  }) async {
    try {
      final docRef = _firestore.collection(collection).doc(docId);
      if (operation == 'set') {
        await docRef.set(data, SetOptions(merge: true));
      } else {
        await docRef.update(data);
      }
    } catch (e) {
      await _localDbResolved.addPendingWrite(
        collection: collection,
        docId: docId,
        operation: operation,
        dataJson: jsonEncode(data),
      );
    }
  }

  Future<void> _processPendingWrites() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final pending = await _localDbResolved.getPendingWrites();
      for (final write in pending) {
        if (write.id == null) continue;
        try {
          final data =
              jsonDecode(write.dataJson) as Map<String, dynamic>;
          final docRef =
              _firestore.collection(write.collection).doc(write.docId);
          if (write.operation == 'set') {
            await docRef.set(data, SetOptions(merge: true));
          } else {
            await docRef.update(data);
          }
          await _localDbResolved.deletePendingWrite(write.id!);
        } catch (e) {
          // Skip failed items; they remain queued for the next reconnect.
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
