import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/utils/helpers.dart';

abstract final class StationMarkerIcon {
  static final _cache = <String, BitmapDescriptor>{};

  static Future<BitmapDescriptor> build(
    StationModel station, {
    bool selected = false,
  }) async {
    final key = '${station.id}_${station.crowdStatus.name}_$selected';
    if (_cache.containsKey(key)) return _cache[key]!;

    final icon = await _draw(station, selected: selected);
    _cache[key] = icon;
    return icon;
  }

  static void clearCache() => _cache.clear();

  static Future<BitmapDescriptor> _draw(
    StationModel station, {
    required bool selected,
  }) async {
    const width = 150.0;
    const height = 108.0;
    const pinRadius = 18.0;

    final statusColor = Helpers.crowdStatusColor(station.crowdStatus);
    final statusLabel = Helpers.crowdStatusLabel(station.crowdStatus);
    final name = _truncate(station.name, 22);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final glowPaint = Paint()
      ..color = statusColor.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 0, 94, 24),
        const Radius.circular(12),
      ),
      glowPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 2, 86, 20),
        const Radius.circular(10),
      ),
      Paint()..color = statusColor,
    );
    _drawCenteredText(
      canvas,
      statusLabel,
      const Rect.fromLTWH(32, 2, 86, 20),
      fontSize: 10,
      color: AppColors.white,
      bold: true,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 28, 122, 36),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 26, 126, 38),
        const Radius.circular(10),
      ),
      Paint()..color = selected ? const Color(0xFFEEF2FF) : AppColors.white,
    );
    if (selected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(12, 26, 126, 38),
          const Radius.circular(10),
        ),
        Paint()
          ..color = AppColors.primaryBlue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    _drawCenteredText(
      canvas,
      name,
      const Rect.fromLTWH(12, 28, 126, 34),
      fontSize: 11,
      color: AppColors.navyDark,
      bold: true,
      maxLines: 2,
    );

    const pinCenter = Offset(width / 2, 82);
    canvas.drawCircle(
      pinCenter,
      pinRadius + 3,
      Paint()..color = AppColors.primaryBlue.withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      pinCenter,
      pinRadius,
      Paint()..color = AppColors.navyDark,
    );

    final iconPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pinCenter, width: 12, height: 14),
        const Radius.circular(2),
      ),
      iconPaint,
    );
    canvas.drawLine(
      Offset(pinCenter.dx, pinCenter.dy - 5),
      Offset(pinCenter.dx, pinCenter.dy + 5),
      iconPaint,
    );

    final pointer = Path()
      ..moveTo(pinCenter.dx, pinCenter.dy + pinRadius)
      ..lineTo(pinCenter.dx - 8, pinCenter.dy + pinRadius + 10)
      ..lineTo(pinCenter.dx + 8, pinCenter.dy + pinRadius + 10)
      ..close();
    canvas.drawPath(pointer, Paint()..color = AppColors.navyDark);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  static String _truncate(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max - 1)}…';
  }

  static void _drawCenteredText(
    Canvas canvas,
    String text,
    Rect rect, {
    required double fontSize,
    required Color color,
    bool bold = false,
    int maxLines = 1,
  }) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        fontSize: fontSize,
        maxLines: maxLines,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    )
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(text);

    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: rect.width - 8));

    canvas.drawParagraph(
      paragraph,
      Offset(rect.left + 4, rect.top + (rect.height - paragraph.height) / 2),
    );
  }
}
