import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/utils/helpers.dart';
import 'package:new_version/utils/maps_config.dart';

class TripTrackingScreen extends StatefulWidget {
  const TripTrackingScreen({super.key, required this.station});

  final StationModel station;

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  final Completer<GoogleMapController> _mapCompleter = Completer();
  GoogleMapController? _mapController;

  // Route data
  final List<LatLng> _polylineCoords = [];
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

  @override
  void initState() {
    super.initState();
    _destination = LatLng(
      widget.station.latitude,
      widget.station.longitude,
    );

    final locationController = Get.find<LocationController>();
    _currentLatLng = locationController.currentLatLng;
    _remainingKm = _haversineKm(_currentLatLng, _destination);
    _remainingMinutes = _estimateMinutes(_remainingKm);

    _fetchRoute();
    _startLocationStream();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Route fetching ──────────────────────────────────────────────────────────

  Future<void> _fetchRoute() async {
    try {
      final polylinePoints = PolylinePoints(apiKey: MapsConfig.apiKey);
      List<PointLatLng> points = [];

      if (kIsWeb) {
        // Web: Directions API blocks CORS → use Routes API (CORS-enabled).
        // Requires "Routes API" to be enabled in Google Cloud Console.
        final response = await polylinePoints.getRouteBetweenCoordinatesV2(
          request: RoutesApiRequest(
            origin: PointLatLng(
                _currentLatLng.latitude, _currentLatLng.longitude),
            destination: PointLatLng(
                _destination.latitude, _destination.longitude),
            travelMode: TravelMode.driving,
          ),
        );
        if (response.routes.isNotEmpty) {
          final encoded = response.routes.first.polylineEncoded;
          if (encoded != null && encoded.isNotEmpty) {
            points = PolylinePoints.decodePolyline(encoded);
          }
        }
        debugPrint('Routes API routes count: ${response.routes.length}');
        debugPrint('Routes API error: ${response.errorMessage}');
      } else {
        // Mobile: Directions API works fine without CORS restrictions.
        // ignore: deprecated_member_use
        final result = await polylinePoints.getRouteBetweenCoordinates(
          // ignore: deprecated_member_use
          request: PolylineRequest(
            origin: PointLatLng(
                _currentLatLng.latitude, _currentLatLng.longitude),
            destination: PointLatLng(
                _destination.latitude, _destination.longitude),
            mode: TravelMode.driving,
          ),
        );
        points = result.points;
        debugPrint('Directions API status: ${result.status}');
        debugPrint('Directions API points: ${result.points.length}');
      }

      if (!mounted) return;

      if (points.isNotEmpty) {
        final coords =
            points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        setState(() {
          _polylineCoords
            ..clear()
            ..addAll(coords);
          _isLoadingRoute = false;
          _routeError = null;
        });
        _fitBounds(coords);
      } else {
        setState(() {
          _polylineCoords
            ..clear()
            ..addAll([_currentLatLng, _destination]);
          _isLoadingRoute = false;
          _routeError = 'تعذّر جلب الطريق، يُعرض خط مستقيم';
        });
        _fitBounds([_currentLatLng, _destination]);
      }
    } catch (e) {
      debugPrint('Route fetch exception: $e');
      if (!mounted) return;
      setState(() {
        _polylineCoords
          ..clear()
          ..addAll([_currentLatLng, _destination]);
        _isLoadingRoute = false;
        _routeError = 'تعذّر الاتصال، يُعرض خط مستقيم';
      });
      _fitBounds([_currentLatLng, _destination]);
    }
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    if (points.isEmpty) return;
    final ctrl = await _mapCompleter.future;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    ctrl.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80, // padding px
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
      final dist = _haversineKm(newLatLng, _destination);

      setState(() {
        _currentLatLng = newLatLng;
        _remainingKm = dist;
        _remainingMinutes = _estimateMinutes(dist);
        if (dist < 0.05) _arrived = true;
      });

      // Smoothly pan camera to follow user
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(newLatLng),
      );
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dlat = _rad(b.latitude - a.latitude);
    final dlng = _rad(b.longitude - a.longitude);
    final h = math.pow(math.sin(dlat / 2), 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.pow(math.sin(dlng / 2), 2);
    return r * 2 * math.asin(math.sqrt(h));
  }

  double _rad(double deg) => deg * math.pi / 180;

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
    final polylines = _polylineCoords.isNotEmpty
        ? {
            Polyline(
              polylineId: const PolylineId('route'),
              points: _polylineCoords,
              color: AppColors.primaryBlue,
              width: 5,
              patterns: [],
              jointType: JointType.round,
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
            ),
          }
        : <Polyline>{};

    final markers = {
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: widget.station.name),
      ),
      Marker(
        markerId: const MarkerId('current'),
        position: _currentLatLng,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'موقعك الحالي'),
      ),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (_currentLatLng.latitude + _destination.latitude) / 2,
                (_currentLatLng.longitude + _destination.longitude) / 2,
              ),
              zoom: 13,
            ),
            onMapCreated: (c) {
              _mapController = c;
              if (!_mapCompleter.isCompleted) _mapCompleter.complete(c);
            },
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Helpers.crowdStatusColor(widget.station.crowdStatus)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Text(
                  Helpers.crowdStatusLabel(widget.station.crowdStatus),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Helpers.crowdStatusColor(widget.station.crowdStatus),
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
                value: _arrived
                    ? '0 د'
                    : '$_remainingMinutes د',
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
          ?trailing,
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
