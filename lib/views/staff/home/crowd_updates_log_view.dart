import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/staff_controller.dart';
import 'package:new_version/models/crowd_update_model.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/utils/helpers.dart';

class CrowdUpdatesLogView extends StatelessWidget {
  const CrowdUpdatesLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final staffController = Get.find<StaffController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios,
              color: AppColors.white, size: 18),
          onPressed: Get.back,
        ),
        centerTitle: true,
        title: Text(
          'سجل تحديثات الازدحام',
          style: GoogleFonts.cairo(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              final updates = staffController.updates;
              if (updates.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد تحديثات',
                    style: GoogleFonts.cairo(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                itemCount: updates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _LogCard(update: updates[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      child: Row(
        children: [
          _FilterChip(label: 'الكل', isSelected: true),
          const SizedBox(width: 8),
          _FilterChip(
              label: 'مرتفع',
              color: AppColors.danger),
          const SizedBox(width: 8),
          _FilterChip(label: 'متوسط', color: AppColors.warning),
          const SizedBox(width: 8),
          _FilterChip(label: 'منخفض', color: AppColors.success),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.isSelected = false,
    this.color,
  });

  final String label;
  final bool isSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor
            : activeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isSelected
              ? activeColor
              : activeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? AppColors.white : activeColor,
        ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.update});

  final CrowdUpdateModel update;

  @override
  Widget build(BuildContext context) {
    final newColor = Helpers.crowdStatusColor(update.newStatus);
    final oldColor = Helpers.crowdStatusColor(update.oldStatus);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(
              color: newColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.local_gas_station,
                      color: AppColors.textMuted, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        update.stationName,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.navyDark,
                        ),
                      ),
                      Text(
                        update.stationAddress,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDateTime(update.updatedAt),
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _StatusBox(
                    label: 'الحالة السابقة',
                    status: update.oldStatus,
                    color: oldColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 14, color: AppColors.textSecondary),
                ),
                Expanded(
                  child: _StatusBox(
                    label: 'الحالة الجديدة',
                    status: update.newStatus,
                    color: newColor,
                    isNew: true,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, 10),
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  update.updatedByName,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.label,
    required this.status,
    required this.color,
    this.isNew = false,
  });

  final String label;
  final CrowdStatus status;
  final Color color;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: isNew ? 0.5 : 0.2),
          width: isNew ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Helpers.crowdStatusLabel(status),
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
