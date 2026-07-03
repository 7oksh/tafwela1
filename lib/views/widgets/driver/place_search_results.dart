import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_version/controllers/driver/location_controller.dart';
import 'package:new_version/controllers/driver/station_controller.dart';
import 'package:new_version/models/place_result.dart';
import 'package:new_version/utils/constants.dart';

class PlaceSearchResults extends StatelessWidget {
  const PlaceSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final stationCtrl = Get.find<StationController>();
    final locationCtrl = Get.find<LocationController>();

    return Obx(() {
      final places = stationCtrl.placeResults;
      final isSearching = stationCtrl.isSearchingPlaces.value;

      if (isSearching) {
        return _buildLoadingCard();
      }

      if (places.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.public,
                    color: AppColors.primaryBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'نتائج البحث الخارجية',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Results list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: places.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final place = places[index];
                return _PlaceResultTile(
                  place: place,
                  onTap: () {
                    // Move map to this location
                    locationCtrl.mapController.move(
                      LatLng(place.latitude, place.longitude),
                      15,
                    );
                    // Clear the results
                    stationCtrl.placeResults.clear();
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'جاري البحث...',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceResultTile extends StatelessWidget {
  const _PlaceResultTile({
    required this.place,
    required this.onTap,
  });

  final PlaceResult place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.place,
                color: AppColors.primaryBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                place.displayName,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.navyDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
