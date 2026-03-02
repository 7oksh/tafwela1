import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/station.dart';
import '../services/station_status_service.dart';
import '../widgets/dark_mode_button.dart';

class StationDetailsScreen extends StatefulWidget {
  final Station station;

  const StationDetailsScreen({super.key, required this.station});

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  final StationStatusService _statusService = StationStatusService();
  late Station _currentStation;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStation = widget.station;
  }

  Future<void> _updateStatus(CrowdStatus status) async {
    setState(() => _isUpdating = true);

    // Toggle logic: if already selected, remove it.
    if (_currentStation.customerStatus == status) {
      await _statusService.clearStatus(_currentStation.id, 'customer');
    } else {
      await _statusService.setStatus(_currentStation.id, status, 'customer');
    }

    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _isUpdating = true);
    final cStatus = await _statusService.getStatus(_currentStation.id, 'customer');
    final cUpdate = await _statusService.getLastUpdate(_currentStation.id, 'customer');
    final eStatus = await _statusService.getStatus(_currentStation.id, 'employee');
    final eUpdate = await _statusService.getLastUpdate(_currentStation.id, 'employee');

    if (mounted) {
      setState(() {
        _currentStation = _currentStation.copyWith(
          customerStatus: cStatus,
          customerLastUpdate: cUpdate,
          employeeStatus: eStatus,
          employeeLastUpdate: eUpdate,
        );
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الحالة بنجاح')),
      );
    }
  }

  Future<void> _launchNavigation() async {
    Uri uri;
    if (defaultTargetPlatform == TargetPlatform.android) {
      uri = Uri.parse('google.navigation:q=${_currentStation.latitude},${_currentStation.longitude}');
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      uri = Uri.parse('comgooglemaps://?daddr=${_currentStation.latitude},${_currentStation.longitude}&directionsmode=driving');
    } else {
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${_currentStation.latitude},${_currentStation.longitude}');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      // Fallback to https if native app call fails
      final httpsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${_currentStation.latitude},${_currentStation.longitude}');
      if (await canLaunchUrl(httpsUri)) {
        await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق الخرائط')),
        );
      }
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'غير متوفر';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentStation.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isUpdating ? null : _refresh,
              tooltip: 'تحديث',
            ),
            const DarkModeButton(),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                child: Column(
                  children: [
                    Icon(Icons.local_gas_station, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      _currentStation.name,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _currentStation.address,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('الحالة الحالية', style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentStation.customerStatus?.label ?? 'غير معروفة',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Color(_currentStation.colorForStatus(_currentStation.customerStatus)),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'آخر تحديث: ${_formatTime(_currentStation.customerLastUpdate)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _currentStation.iconForStatus(_currentStation.customerStatus),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Employee Status Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('موظف المحطة', style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentStation.employeeStatus?.label ?? 'غير متوفرة',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Color(_currentStation.colorForStatus(_currentStation.employeeStatus)),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'آخر تحديث: ${_formatTime(_currentStation.employeeLastUpdate)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _currentStation.iconForStatus(_currentStation.employeeStatus),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('الخدمات المتاحة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _currentStation.services.isEmpty
                        ? const Text('لم يتم تحديد الخدمات بعد')
                        : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currentStation.services.map((s) => Chip(
                        label: Text(s),
                        backgroundColor: theme.colorScheme.surfaceVariant,
                      )).toList(),
                    ),

                    const SizedBox(height: 32),
                    Text('تقييم حالة المحطة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('ساعد الآخرين وأخبرنا بحالة المحطة الآن:', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    _buildStatusGrid(),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _launchNavigation,
                        icon: const Icon(Icons.near_me),
                        label: const Text('تحرك إلى هناك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _statusButton(CrowdStatus.quiet, Colors.green),
        _statusButton(CrowdStatus.medium, Colors.orange),
        _statusButton(CrowdStatus.crowded, Colors.red),
        _statusButton(CrowdStatus.noFuel, Colors.grey.shade700),
      ],
    );
  }

  Widget _statusButton(CrowdStatus status, Color color) {
    final isSelected = _currentStation.customerStatus == status;
    return InkWell(
      onTap: _isUpdating ? null : () => _updateStatus(status),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : null,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          status.label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
