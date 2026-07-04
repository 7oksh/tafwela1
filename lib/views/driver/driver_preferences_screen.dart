import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/services/search_preferences_service.dart';
import 'package:new_version/controllers/driver/driver_preferences_controller.dart';

class DriverPreferencesScreen extends StatelessWidget {
  const DriverPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverPreferencesController>();

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
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const _SectionHeader(title: 'ترتيب النتائج'),
              const SizedBox(height: 12),
              _buildSortOptionsList(controller),
              const SizedBox(height: AppSpacing.lg),
              const _SectionHeader(title: 'أقصى مسافة'),
              const SizedBox(height: 8),
              _buildDistanceSlider(controller, context),
              const SizedBox(height: AppSpacing.lg),
              const _SectionHeader(title: 'الإعدادات'),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.access_time_rounded,
                title: 'المحطات المفتوحة فقط',
                subtitle: 'إخفاء المحطات المغلقة',
                value: controller.notifyOpenOnly.value,
                onChanged: (v) => controller.notifyOpenOnly.value = v,
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'إشعارات تغيرات الازدحام',
                subtitle: 'تلقي إشعار عند تغير الحالة',
                value: controller.notifyCrowdChanges.value,
                onChanged: (v) => controller.notifyCrowdChanges.value = v,
              ),
              const SizedBox(height: 32),
              _buildSaveButton(controller),
              const SizedBox(height: 24),
            ],
          )),
    );
  }

  Widget _buildSortOptionsList(DriverPreferencesController controller) {
    final sortOptions = [
      {'id': SortType.distance, 'label': 'الأقرب أولاً'},
      {'id': SortType.crowd, 'label': 'الأقل ازدحاماً'},
      {'id': SortType.rating, 'label': 'الأعلى تقييماً'},
    ];

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
        children: sortOptions.map((s) {
          final id = s['id'] as SortType;
          final isSelected = controller.sortBy.value == id;
          return InkWell(
            onTap: () => controller.sortBy.value = id,
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

  Widget _buildDistanceSlider(
      DriverPreferencesController controller, BuildContext context) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Text(
                  '${controller.maxDistance.value.round()} كم',
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
              value: controller.maxDistance.value,
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: (v) => controller.maxDistance.value = v,
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

  Widget _buildSaveButton(DriverPreferencesController controller) {
    return GestureDetector(
      onTap: controller.savePreferences,
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
