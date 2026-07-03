import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/driver/home_controller.dart';
import 'package:new_version/controllers/driver/location_controller.dart';
import 'package:new_version/controllers/driver/station_controller.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/views/driver/driver_preferences_screen.dart';
import 'package:new_version/views/driver/station_details_screen.dart';
import 'package:new_version/views/widgets/driver/driver_map_view.dart';
import 'package:new_version/views/widgets/driver/place_search_results.dart';
import 'package:new_version/views/widgets/common/search_bar.dart';
import 'package:new_version/views/widgets/driver/station_card.dart';
import 'package:showcaseview/showcaseview.dart';

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

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _locationController = Get.find<LocationController>();
    _stationController = Get.find<StationController>();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Local filter runs immediately (fast, in-memory)
    _stationController.search(query);

    // External geocoding search is debounced (network call)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _stationController.searchExternalPlaces(query);
    });
  }

  // ── Showcase style مشترك ──
  TextStyle get _showcaseTitle => GoogleFonts.cairo(
    color: AppColors.navyDark,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  TextStyle get _showcaseDesc => GoogleFonts.cairo(
    color: AppColors.navyDark,
    fontSize: 13,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showList = _homeController.currentTab.value == 1 ||
          _homeController.showListView.value;

      if (showList) return _buildListView();

      return Stack(
        children: [
          // ── Showcase 1: الخريطة ──
          Showcase(
            key: _homeController.mapKey,
            title: 'خريطة المحطات',
            description: 'شوف كل محطات الوقود القريبة منك على الخريطة',
            titleTextStyle: _showcaseTitle,
            descTextStyle: _showcaseDesc,
            tooltipBackgroundColor: AppColors.white,
            targetShapeBorder: const RoundedRectangleBorder(),
            child: const DriverMapView(),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // ── Showcase 2: البحث ──
                  Showcase(
                    key: _homeController.searchKey,
                    title: 'ابحث عن محطة',
                    description: 'ابحث بالاسم أو المنطقة للقي محطة قريبة منك',
                    titleTextStyle: _showcaseTitle,
                    descTextStyle: _showcaseDesc,
                    tooltipBackgroundColor: AppColors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SearchBarWidget(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onFilterTap: () => _homeController.changeTab(1),
                        ),
                        const PlaceSearchResults(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildSelectedStationSheet(),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCacheIndicator(),
          ),

          Positioned(
            bottom: 100,
            left: 16,
            child: Column(
              children: [
                // ── Showcase 3: موقعي ──
                Showcase(
                  key: _homeController.markerKey,
                  title: 'موقعي الحالي',
                  description: 'اضغط عشان الخريطة ترجع لموقعك تلقائياً',
                  titleTextStyle: _showcaseTitle,
                  descTextStyle: _showcaseDesc,
                  tooltipBackgroundColor: AppColors.white,
                  targetBorderRadius: BorderRadius.circular(AppRadius.sm),
                  child: _MapActionButton(
                    icon: Icons.my_location,
                    onTap: _locationController.goToCurrentLocation,
                  ),
                ),
                const SizedBox(height: 10),
                // ── Showcase 4: الفلتر ──
                Showcase(
                  key: _homeController.filterKey,
                  title: 'الفلتر والتفضيلات',
                  description:
                  'خصص عرض المحطات حسب الحالة والمسافة واللي يناسبك',
                  titleTextStyle: _showcaseTitle,
                  descTextStyle: _showcaseDesc,
                  tooltipBackgroundColor: AppColors.white,
                  targetBorderRadius: BorderRadius.circular(AppRadius.sm),
                  child: _MapActionButton(
                    icon: Icons.tune,
                    onTap: () =>
                        Get.to(() => const DriverPreferencesScreen()),
                  ),
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

      // ── Showcase 5: كارت المحطة ──
      return Positioned(
        left: 16,
        right: 16,
        bottom: 16,
        child: Showcase(
          key: _homeController.favTabKey,
          title: 'تفاصيل المحطة',
          description:
          'اضغط على المحطة عشان تشوف تفاصيلها وتبدأ الملاحة إليها',
          titleTextStyle: _showcaseTitle,
          descTextStyle: _showcaseDesc,
          tooltipBackgroundColor: AppColors.white,
          targetBorderRadius: BorderRadius.circular(16),
          child: StationCard(
            station: station,
            compact: true,
            onTap: () =>
                Get.to(() => StationDetailsScreen(station: station)),
          ),
        ),
      );
    });
  }

  Widget _buildCacheIndicator() {
    return Obx(() {
      if (!_stationController.isFromCache.value) {
        return const SizedBox.shrink();
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: const Color(0xFFFFF3E0),
        child: Text(
          'يتم عرض بيانات محفوظة محلياً',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: const Color(0xFFE65100),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }

  Widget _buildListView() {
    return Column(
      children: [
        _buildCacheIndicator(),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                  const PlaceSearchResults(),
                ],
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
                  style:
                  GoogleFonts.cairo(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: stations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) =>
                  StationCard(station: stations[index]),
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