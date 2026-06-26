import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/favorites_controller.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/views/widgets/station_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_forward_ios, color: AppColors.white),
              )
            : null,
        title: Text(
          AppStrings.favorites,
          style: GoogleFonts.cairo(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.favoriteStations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'لا توجد محطات مفضلة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: controller.favoriteStations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            return StationCard(station: controller.favoriteStations[index]);
          },
        );
      }),
    );
  }
}
