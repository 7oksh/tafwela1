import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/favorites_controller.dart';
import 'package:new_version/models/fuel_type_model.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/utils/helpers.dart';
import 'package:new_version/views/screens/trip_tracking_screen.dart';

class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({super.key, required this.station});

  final StationModel station;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.navyHeader,
            leading: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_forward_ios, color: AppColors.white),
            ),
            actions: [
              Obx(
                () => IconButton(
                  onPressed: () => favorites.toggle(station.id),
                  icon: Icon(
                    favorites.isFavorite(station.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    station.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.navyDark,
                      child: const Icon(
                        Icons.local_gas_station,
                        size: 64,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          station.address,
                          style: GoogleFonts.cairo(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade600, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        station.rating.toStringAsFixed(1),
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Helpers.crowdStatusColor(station.crowdStatus)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          Helpers.crowdStatusLabel(station.crowdStatus),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Helpers.crowdStatusColor(station.crowdStatus),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        Helpers.formatDistance(station.distanceKm),
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'أنواع الوقود',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: station.fuelTypes.map((f) => _FuelChip(fuel: f)).toList(),
                  ),
                  if (station.services.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'الخدمات',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: station.services
                          .map(
                            (s) => Chip(
                              label: Text(
                                s,
                                style: GoogleFonts.cairo(fontSize: 12),
                              ),
                              backgroundColor: AppColors.white,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _TripButton(station: station),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripButton extends StatelessWidget {
  const _TripButton({required this.station});
  final StationModel station;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TripTrackingScreen(station: station)),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.navigation, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.startTrip,
              style: GoogleFonts.cairo(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FuelChip extends StatelessWidget {
  const _FuelChip({required this.fuel});

  final FuelTypeModel fuel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fuel.name,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fuel.isAvailable ? '${fuel.price} ج.م' : 'غير متوفر',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: fuel.isAvailable ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
