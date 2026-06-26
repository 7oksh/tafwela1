import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/home_controller.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/controllers/station_controller.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/views/screens/driver_preferences_screen.dart';
import 'package:new_version/views/screens/station_details_screen.dart';
import 'package:new_version/views/widgets/driver_map_view.dart';
import 'package:new_version/views/widgets/search_bar.dart';
import 'package:new_version/views/widgets/station_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  late final HomeController _homeController;
  late final LocationController _locationController;
  late final StationController _stationController;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _locationController = Get.find<LocationController>();
    _stationController = Get.find<StationController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showList = _homeController.currentTab.value == 1 ||
          _homeController.showListView.value;

      if (showList) return _buildListView();

      return Stack(
        children: [
          const DriverMapView(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: _stationController.search,
                    onFilterTap: () => _homeController.changeTab(1),
                  ),
                ],
              ),
            ),
          ),
          _buildSelectedStationSheet(),
          Positioned(
            bottom: 100,
            left: 16,
            child: Column(
              children: [
                _MapActionButton(
                  icon: Icons.my_location,
                  onTap: _locationController.goToCurrentLocation,
                ),
                const SizedBox(height: 10),
                _MapActionButton(
                  icon: Icons.tune,
                  onTap: () => Get.to(() => const DriverPreferencesScreen()),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSelectedStationSheet() {
    return Obx(() {
      final station = _stationController.selectedStation.value;
      if (station == null) return const SizedBox.shrink();

      return Positioned(
        left: 16,
        right: 16,
        bottom: 16,
        child: StationCard(
          station: station,
          compact: true,
          onTap: () => Get.to(() => StationDetailsScreen(station: station)),
        ),
      );
    });
  }

  Widget _buildListView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.navyHeader,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ابحث عن محطة',
                    style: GoogleFonts.cairo(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Get.to(() => const DriverPreferencesScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.tune,
                          color: AppColors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SearchBarWidget(
                controller: _searchController,
                onChanged: _stationController.search,
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_stationController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final stations = _stationController.filteredStations;
            if (stations.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد محطات',
                  style: GoogleFonts.cairo(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: stations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => StationCard(station: stations[index]),
            );
          }),
        ),
      ],
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.navyDark, size: 22),
      ),
    );
  }
}
