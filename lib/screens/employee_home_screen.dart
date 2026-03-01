import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/station_status_service.dart';
import '../widgets/dark_mode_button.dart';

const _updateIntervalMinutes = 5;

/// الصفحة الرئيسية للموظف - تحديث حالة الازدحام في المحطة فقط
class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final AuthService _auth = AuthService();
  final StationStatusService _statusService = StationStatusService();

  String? _stationId;
  CrowdStatus? _currentStatus;
  DateTime? _lastUpdate;
  Timer? _countdownTimer;
  Timer? _reminderTimer;
  int _remainingSeconds = 0;
  bool _alertShown = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _reminderTimer?.cancel();
    super.dispose();
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();
    if (_lastUpdate == null) return;
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final elapsed = DateTime.now().difference(_lastUpdate!).inMinutes;
      if (elapsed >= _updateIntervalMinutes) _showUpdateAlert();
    });
  }

  void _cancelReminderTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _cancelReminderTimer();
    if (_lastUpdate == null) return;

    void tick() {
      if (!mounted) return;
      final now = DateTime.now();
      final elapsed = now.difference(_lastUpdate!).inSeconds;
      final total = _updateIntervalMinutes * 60;
      final remaining = total - elapsed;

      if (remaining <= 0) {
        _countdownTimer?.cancel();
        if (mounted) setState(() => _remainingSeconds = 0);
        if (!_alertShown) _showUpdateAlert();
        return;
      }

      setState(() => _remainingSeconds = remaining);
    }

    tick();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _showUpdateAlert() {
    if (!mounted) return;
    _alertShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('تنبيه'),
            ],
          ),
          content: const Text(
            'حان وقت تحديث حالة المحطة!\nيرجى تحديث الازدحام الآن.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      _alertShown = false;
      final elapsed = _lastUpdate != null
          ? DateTime.now().difference(_lastUpdate!).inMinutes
          : 0;
      if (elapsed >= _updateIntervalMinutes) {
        _startReminderTimer();
      } else {
        _startCountdown();
      }
    });
  }

  Future<void> _load() async {
    final user = await _auth.getStoredUser();
    if (user == null || user.role != UserRole.employee || user.stationId == null) {
      if (mounted) setState(() {});
      return;
    }
    final sid = user.stationId!;
    final status = await _statusService.getStatus(sid);
    final lastUpdate = await _statusService.getLastUpdate(sid);
    if (mounted) {
      setState(() {
        _stationId = sid;
        _currentStatus = status;
        _lastUpdate = lastUpdate;
        _alertShown = false;
      });
      _startCountdown();
    }
  }

  Future<void> _updateStatus(CrowdStatus status) async {
    if (_stationId == null) return;
    await _statusService.setStatus(_stationId!, status);
    await _load();
  }

  String _formatLastUpdate(DateTime? dt) {
    if (dt == null) return 'لم يتم التحديث بعد';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'منذ لحظات';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatRemaining() {
    if (_lastUpdate == null) return '';
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    if (_remainingSeconds <= 0) return 'انتهى الوقت - حدّث الحالة';
    return 'متبقي ${m}:${s.toString().padLeft(2, '0')}';
  }

  String _stationDisplayName(String id) {
    if (id == 'station_1') return 'المحطة ١';
    if (id == 'station_2') return 'المحطة ٢';
    return 'المحطة $id';
  }

  @override
  Widget build(BuildContext context) {
    if (_stationId == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تفويلة'),
            centerTitle: true,
            actions: const [DarkModeButton()],
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'رجوع',
          ),
          title: const Text('تفويلة - موظف'),
          centerTitle: true,
          actions: const [DarkModeButton()],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_gas_station, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              _stationDisplayName(_stationId!),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'آخر تحديث: ${_formatLastUpdate(_lastUpdate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_lastUpdate != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _formatRemaining(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _remainingSeconds <= 0
                                  ? Colors.orange
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                        if (_currentStatus != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _colorForStatus(_currentStatus!).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الحالة الحالية: ${_currentStatus!.label}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _colorForStatus(_currentStatus!),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'حدّث حالة الازدحام',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر الحالة الحالية للمحطة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _StatusButton(
                  label: 'هادئ',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  isSelected: _currentStatus == CrowdStatus.quiet,
                  onTap: () => _updateStatus(CrowdStatus.quiet),
                ),
                const SizedBox(height: 12),
                _StatusButton(
                  label: 'متوسط',
                  icon: Icons.remove_circle_outline,
                  color: Colors.orange,
                  isSelected: _currentStatus == CrowdStatus.medium,
                  onTap: () => _updateStatus(CrowdStatus.medium),
                ),
                const SizedBox(height: 12),
                _StatusButton(
                  label: 'مزدحم',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                  isSelected: _currentStatus == CrowdStatus.crowded,
                  onTap: () => _updateStatus(CrowdStatus.crowded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForStatus(CrowdStatus s) {
    switch (s) {
      case CrowdStatus.quiet: return Colors.green;
      case CrowdStatus.medium: return Colors.orange;
      case CrowdStatus.crowded: return Colors.red;
      case CrowdStatus.noFuel: return Colors.grey.shade700;
    }
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : null,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Icon(Icons.check, color: color, size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
