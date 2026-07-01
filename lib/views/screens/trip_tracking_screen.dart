import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/services/osrm_service.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/utils/helpers.dart';

class TripTrackingScreen extends StatefulWidget {
  const TripTrackingScreen({super.key, required this.station});

  final StationModel station;

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  // Route data
  List<LatLng> _polylineCoords = [];
  bool _isLoadingRoute = true;
  String? _routeError;

  // Live location
  StreamSubscription<Position>? _locationSub;
  LatLng _currentLatLng = const LatLng(0, 0);
  double _remainingKm = 0;
  int _remainingMinutes = 0;
  bool _arrived = false;
  bool _cancelled = false;

  late final LatLng _destination;

  /// latlong2 distance calculator — replaces the custom haversine formula.
  static const _distance = Distance();

  @override
  void initState() {
    super.initState();
    _destination = LatLng(
      widget.station.latitude,
      widget.station.longitude,
    );

    final locationController = Get.find<LocationController>();
    _currentLatLng = locationController.currentLatLng;
    _remainingKm =
        _distance.as(LengthUnit.Kilometer, _currentLatLng, _destination);
    _remainingMinutes = _estimateMinutes(_remainingKm);

    _fetchRoute();
    _startLocationStream();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  // ── Route fetching ──────────────────────────────────────────────────────────

  Future<void> _fetchRoute() async {
    try {
      final result = await OsrmService().getRoute(
        _currentLatLng.latitude,
        _currentLatLng.longitude,
        _destination.latitude,
        _destination.longitude,
      );

      if (!mounted) return;

      if (result != null && result.polyline.isNotEmpty) {
        setState(() {
          _polylineCoords = result.polyline;
          _isLoadingRoute = false;
          _routeError = null;
          _remainingMinutes = (result.durationSeconds / 60).ceil();
          _remainingKm = result.distanceMeters / 1000;
        });
        _fitBounds(_polylineCoords);
      } else {
        setState(() {
          _polylineCoords = [_currentLatLng, _destination];
          _isLoadingRoute = false;
          _routeError = 'تعذّر جلب الطريق، يُعرض خط مستقيم';
        });
        _fitBounds([_currentLatLng, _destination]);
      }
    } catch (e) {
      debugPrint('Route fetch exception: $e');
      if (!mounted) return;
      setState(() {
        _polylineCoords = [_currentLatLng, _destination];
        _isLoadingRoute = false;
        _routeError = 'تعذّر الاتصال، يُعرض خط مستقيم';
      });
      _fitBounds([_currentLatLng, _destination]);
    }
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty || !_isMapReady) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(80),
      ),
    );
  }

  // ── Live GPS ────────────────────────────────────────────────────────────────

  void _startLocationStream() {
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update every 10 m
      ),
    ).listen((pos) {
      if (!mounted || _cancelled) return;
      final newLatLng = LatLng(pos.latitude, pos.longitude);
      final dist =
          _distance.as(LengthUnit.Kilometer, newLatLng, _destination);

      setState(() {
        _currentLatLng = newLatLng;
        _remainingKm = dist;
        _remainingMinutes = _estimateMinutes(dist);
        if (dist < 0.05) _arrived = true;
      });

      // Smoothly follow user
      if (_isMapReady) {
        _mapController.move(newLatLng, _mapController.camera.zoom);
      }
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  int _estimateMinutes(double km) {
    // ~30 km/h average in city traffic
    return (km / 30 * 60).ceil();
  }

  void _cancelTrip() {
    _locationSub?.cancel();
    setState(() => _cancelled = true);
    Get.back();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                (_currentLatLng.latitude + _destination.latitude) / 2,
                (_currentLatLng.longitude + _destination.longitude) / 2,
              ),
              initialZoom: 13,
              onMapReady: () {
                _isMapReady = true;
                if (_polylineCoords.isNotEmpty) {
                  _fitBounds(_polylineCoords);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tafwela.app',
              ),
              if (_polylineCoords.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylineCoords,
                      color: AppColors.primaryBlue,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Destination marker
                  Marker(
                    point: _destination,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue
                                .withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_gas_station,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  // Current position
                  Marker(
                    point: _currentLatLng,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.success.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Loading indicator while fetching route
          if (_isLoadingRoute)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: _Banner(
                color: AppColors.primaryBlue,
                icon: Icons.route,
                text: 'جاري رسم الطريق...',
                trailing: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

          // Error banner (fallback straight line)
          if (!_isLoadingRoute && _routeError != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: _Banner(
                color: AppColors.warning,
                icon: Icons.warning_amber_rounded,
                text: _routeError!,
              ),
            ),

          // Arrived banner
          if (_arrived)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: _Banner(
                color: AppColors.success,
                icon: Icons.check_circle,
                text: 'وصلت إلى ${widget.station.name}!',
              ),
            ),

          // Bottom sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_forward_ios,
              color: AppColors.navyDark, size: 18),
          onPressed: _cancelTrip,
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          'تتبع الرحلة',
          style: GoogleFonts.cairo(
            color: AppColors.navyDark,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Station info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.local_gas_station,
                    color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.station.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.navyDark,
                      ),
                    ),
                    Text(
                      widget.station.address,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      Helpers.crowdStatusColor(widget.station.crowdStatus)
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Text(
                  Helpers.crowdStatusLabel(widget.station.crowdStatus),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Helpers.crowdStatusColor(
                        widget.station.crowdStatus),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoTile(
                icon: Icons.route_outlined,
                value: _arrived
                    ? 'وصلت'
                    : Helpers.formatDistance(_remainingKm),
                label: 'المسافة المتبقية',
              ),
              _InfoTile(
                icon: Icons.timer_outlined,
                value: _arrived ? '0 د' : '$_remainingMinutes د',
                label: 'الوقت المتوقع',
              ),
              _InfoTile(
                icon: Icons.star_outlined,
                value: widget.station.rating.toStringAsFixed(1),
                label: 'التقييم',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action button
          if (!_arrived)
            _ActionButton(
              label: 'إلغاء الرحلة',
              icon: Icons.close,
              color: AppColors.danger,
              onTap: _cancelTrip,
            )
          else
            _ActionButton(
              label: 'انتهاء الرحلة',
              icon: Icons.check,
              color: AppColors.success,
              filled: true,
              onTap: Get.back,
            ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ─────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
    this.trailing,
  });

  final Color color;
  final IconData icon;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.navyDark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: filled
              ? null
              : Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: filled ? AppColors.white : color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: filled ? AppColors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
