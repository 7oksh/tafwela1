import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/favorites_controller.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/utils/helpers.dart';
import 'package:new_version/views/screens/station_details_screen.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    this.showFavorite = true,
    this.compact = false,
    this.onTap,
  });

  final StationModel station;
  final bool showFavorite;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoritesController>();

    return GestureDetector(
      onTap: onTap ?? () => Get.to(() => StationDetailsScreen(station: station)),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StationImage(url: station.imageUrl, compact: compact),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showFavorite)
                        Obx(
                          () => GestureDetector(
                            onTap: () => favorites.toggle(station.id),
                            child: Icon(
                              favorites.isFavorite(station.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.danger,
                              size: 20,
                            ),
                          ),
                        ),
                      const Spacer(),
                      _StatusBadge(
                        status: station.crowdStatus,
                        isOpen: station.isOpen,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    station.name,
                    style: GoogleFonts.cairo(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${station.address} • ${Helpers.formatDistance(station.distanceKm)}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (!compact) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _NavigateChip(
                          onTap: () =>
                              Get.to(() => StationDetailsScreen(station: station)),
                        ),
                        const Spacer(),
                        Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          station.rating.toStringAsFixed(1),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationImage extends StatelessWidget {
  const _StationImage({required this.url, required this.compact});

  final String url;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Image.network(
        url,
        width: compact ? 64 : 80,
        height: compact ? 64 : 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: compact ? 64 : 80,
          height: compact ? 64 : 80,
          color: AppColors.background,
          child: const Icon(Icons.local_gas_station, color: AppColors.navyDark),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isOpen});

  final CrowdStatus status;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = Helpers.crowdStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'متاح حالياً' : Helpers.crowdStatusLabel(status),
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigateChip extends StatelessWidget {
  const _NavigateChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.navigate,
              style: GoogleFonts.cairo(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.navigation, color: AppColors.white, size: 14),
          ],
        ),
      ),
    );
  }
}
