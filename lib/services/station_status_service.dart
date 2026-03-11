import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة الازدحام في المحطة
enum CrowdStatus {
  crowded,  // مزدحم
  medium,   // متوسط
  quiet,    // هادئ
  noFuel,   // لا يوجد بنزين
}

extension CrowdStatusX on CrowdStatus {
  String get label {
    switch (this) {
      case CrowdStatus.crowded: return 'مزدحم';
      case CrowdStatus.medium: return 'متوسط';
      case CrowdStatus.quiet: return 'هادئ';
      case CrowdStatus.noFuel: return 'لا يوجد بنزين';
    }
  }

  String get value => name;
}

class StationStatusService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _expireHours = 4;

  Future<void> setStatus(String stationId, CrowdStatus status, String role) async {
    if (role == 'employee') {
      await _db.collection('stations').doc(stationId).set({
        'employeeStatus': status.value,
        'employeeLastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db
          .collection('stations')
          .doc(stationId)
          .collection('reports')
          .doc(user.uid)
          .set({
        'status': status.value,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> clearStatus(String stationId, String role) async {
    if (role == 'employee') {
      await _db.collection('stations').doc(stationId).set({
        'employeeStatus': null,
        'employeeLastUpdate': null,
      }, SetOptions(merge: true));
    } else {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db
          .collection('stations')
          .doc(stationId)
          .collection('reports')
          .doc(user.uid)
          .delete();
    }
  }

  Future<CrowdStatus?> getStatus(String stationId, String role) async {
    if (role == 'employee') {
      final doc = await _db.collection('stations').doc(stationId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final ts = data['employeeLastUpdate'] as Timestamp?;
      if (ts == null) return null;

      if (DateTime.now().difference(ts.toDate()).inHours >= _expireHours) {
        return null;
      }

      return _parseStatus(data['employeeStatus'] as String?);
    } else {
      // Majority Logic
      final now = DateTime.now();
      final threshold = now.subtract(const Duration(hours: _expireHours));

      final snapshot = await _db
          .collection('stations')
          .doc(stationId)
          .collection('reports')
          .where('timestamp', isGreaterThan: threshold)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final s = doc.data()['status'] as String?;
        if (s != null) counts[s] = (counts[s] ?? 0) + 1;
      }

      if (counts.isEmpty) return null;

      final winner = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      return _parseStatus(winner);
    }
  }

  Future<DateTime?> getLastUpdate(String stationId, String role) async {
    if (role == 'employee') {
      final doc = await _db.collection('stations').doc(stationId).get();
      if (!doc.exists) return null;
      final ts = doc.data()?['employeeLastUpdate'] as Timestamp?;
      return ts?.toDate();
    } else {
      final now = DateTime.now();
      final threshold = now.subtract(const Duration(hours: _expireHours));

      final snapshot = await _db
          .collection('stations')
          .doc(stationId)
          .collection('reports')
          .where('timestamp', isGreaterThan: threshold)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      final ts = snapshot.docs.first.data()['timestamp'] as Timestamp?;
      return ts?.toDate();
    }
  }

  CrowdStatus? _parseStatus(String? v) {
    if (v == null) return null;
    switch (v) {
      case 'crowded': return CrowdStatus.crowded;
      case 'medium': return CrowdStatus.medium;
      case 'quiet': return CrowdStatus.quiet;
      case 'noFuel': return CrowdStatus.noFuel;
      default: return null;
    }
  }
}
