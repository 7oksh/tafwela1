import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/station_status_service.dart';

/// بطاقة عرض محطة البنزين
class StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback? onTap;

  const StationCard({
    super.key,
    required this.station,
    this.onTap,
  });

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المحطة
              Text(
                station.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // الحالات: العملاء والموظف
              Row(
                children: [
                  Expanded(child: _buildStatusBadge(context, 'تقييم العملاء', station.customerStatus, 'customer')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatusBadge(context, 'موظف المحطة', station.employeeStatus, 'employee')),
                ],
              ),
              const SizedBox(height: 8),
              // العنوان
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      station.address,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // المسافة من المستخدم
              if (station.distanceKm != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'يبعد تقريباً ${station.distanceKm!.toStringAsFixed(1)} كم',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              // الخدمات المتاحة
              if (station.services.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: station.services.map((service) {
                    return Chip(
                      label: Text(
                        service,
                        style: theme.textTheme.bodySmall,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String label, CrowdStatus? status, String role) {
    final theme = Theme.of(context);
    final color = Color(station.colorForStatus(status));
    final icon = station.iconForStatus(status);
    final lastUpdate = role == 'customer' ? station.customerLastUpdate : station.employeeLastUpdate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  status?.label ?? 'غير محدّث',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (lastUpdate != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 2),
            child: Text(
              _formatTime(lastUpdate),
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}
