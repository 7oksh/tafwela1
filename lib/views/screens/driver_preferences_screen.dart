import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/utils/constants.dart';

class DriverPreferencesScreen extends StatefulWidget {
  const DriverPreferencesScreen({super.key});

  @override
  State<DriverPreferencesScreen> createState() =>
      _DriverPreferencesScreenState();
}

class _DriverPreferencesScreenState extends State<DriverPreferencesScreen> {
  final _box = GetStorage();

  late List<String> _selectedFuels;
  late String _sortBy;
  late bool _notifyOpenOnly;
  late bool _notifyCrowdChanges;
  late double _maxDistance;

  final _fuelTypes = [
    {'id': 'benzine_80', 'label': 'بنزين 80', 'icon': Icons.local_gas_station},
    {'id': 'benzine_92', 'label': 'بنزين 92', 'icon': Icons.local_gas_station},
    {'id': 'benzine_95', 'label': 'بنزين 95', 'icon': Icons.local_gas_station},
    {'id': 'diesel', 'label': 'سولار', 'icon': Icons.oil_barrel},
    {'id': 'electric', 'label': 'شحن كهربائي', 'icon': Icons.electric_bolt},
  ];

  final _sortOptions = [
    {'id': 'distance', 'label': 'الأقرب أولاً'},
    {'id': 'crowd', 'label': 'الأقل ازدحاماً'},
    {'id': 'rating', 'label': 'الأعلى تقييماً'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFuels =
        List<String>.from(_box.read<List>('pref_fuels') ?? ['benzine_92']);
    _sortBy = _box.read<String>('pref_sort') ?? 'distance';
    _notifyOpenOnly = _box.read<bool>('pref_open_only') ?? false;
    _notifyCrowdChanges = _box.read<bool>('pref_crowd_notify') ?? true;
    _maxDistance = (_box.read<double>('pref_max_dist') ?? 10.0);
  }

  void _save() {
    _box.write('pref_fuels', _selectedFuels);
    _box.write('pref_sort', _sortBy);
    _box.write('pref_open_only', _notifyOpenOnly);
    _box.write('pref_crowd_notify', _notifyCrowdChanges);
    _box.write('pref_max_dist', _maxDistance);
    Get.back();
    Get.snackbar(
      'تم الحفظ',
      'تم حفظ تفضيلاتك بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios,
              color: AppColors.white, size: 20),
          onPressed: Get.back,
        ),
        centerTitle: true,
        title: Text(
          'تفضيلات البحث',
          style: GoogleFonts.cairo(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionHeader(title: 'نوع الوقود المفضل'),
          const SizedBox(height: 12),
          _buildFuelGrid(),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'ترتيب النتائج'),
          const SizedBox(height: 12),
          _buildSortOptions(),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'أقصى مسافة'),
          const SizedBox(height: 8),
          _buildDistanceSlider(),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'الإعدادات'),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.access_time_rounded,
            title: 'المحطات المفتوحة فقط',
            subtitle: 'إخفاء المحطات المغلقة',
            value: _notifyOpenOnly,
            onChanged: (v) => setState(() => _notifyOpenOnly = v),
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.notifications_active_outlined,
            title: 'إشعارات تغيرات الازدحام',
            subtitle: 'تلقي إشعار عند تغير الحالة',
            value: _notifyCrowdChanges,
            onChanged: (v) => setState(() => _notifyCrowdChanges = v),
          ),
          const SizedBox(height: 32),
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFuelGrid() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _fuelTypes.map((f) {
          final isSelected = _selectedFuels.contains(f['id'] as String);
          return GestureDetector(
            onTap: () => setState(() {
              if (isSelected) {
                if (_selectedFuels.length > 1) {
                  _selectedFuels.remove(f['id']);
                }
              } else {
                _selectedFuels.add(f['id'] as String);
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primaryBlue : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.textMuted.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    f['icon'] as IconData,
                    size: 16,
                    color:
                        isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f['label'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.navyDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _sortOptions.map((s) {
          final id = s['id'] as String;
          final isSelected = _sortBy == id;
          return InkWell(
            onTap: () => setState(() => _sortBy = id),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    s['label'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.navyDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDistanceSlider() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المسافة القصوى',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.navyDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Text(
                  '${_maxDistance.round()} كم',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryBlue,
              inactiveTrackColor: AppColors.primaryBlue.withValues(alpha: 0.2),
              thumbColor: AppColors.primaryBlue,
              overlayColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: _maxDistance,
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: (v) => setState(() => _maxDistance = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 كم',
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: AppColors.textSecondary)),
              Text('50 كم',
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.navyDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryBlue,
        activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentBlue],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'حفظ التفضيلات',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.navyDark,
          ),
        ),
      ],
    );
  }
}
