import 'package:flutter/material.dart';
import 'package:new_version/models/station_model.dart';

abstract final class Helpers {
  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} م';
    return '${km.toStringAsFixed(1)} كم';
  }

  static String crowdStatusLabel(CrowdStatus status) {
    return switch (status) {
      CrowdStatus.low => 'منخفض',
      CrowdStatus.medium => 'متوسط',
      CrowdStatus.high => 'مزدحم',
      CrowdStatus.none => 'لا يوجد وقود',
    };
  }

  static Color crowdStatusColor(CrowdStatus status) {
    return switch (status) {
      CrowdStatus.low => const Color(0xFF22C55E),
      CrowdStatus.medium => const Color(0xFFF59E0B),
      CrowdStatus.high => const Color(0xFFE53935),
      CrowdStatus.none => const Color(0xFF9CA3AF),
    };
  }
}
