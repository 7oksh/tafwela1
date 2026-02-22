import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/station.dart';
import '../services/station_status_service.dart';

/// Widget الخريطة - منفصل لتحسين الأداء (Lazy Loading)
class StationsMapWidget extends StatefulWidget {
  final List<Station> stations;
  final Position? userPosition;
  final Function(Station)? onStationTap;

  const StationsMapWidget({
    super.key,
    required this.stations,
    this.userPosition,
    this.onStationTap,
  });

  @override
  State<StationsMapWidget> createState() => _StationsMapWidgetState();
}

class _StationsMapWidgetState extends State<StationsMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  CameraPosition? _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _buildMarkers();
  }

  @override
  void didUpdateWidget(StationsMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث العلامات فقط إذا تغيرت المحطات
    if (oldWidget.stations != widget.stations ||
        oldWidget.userPosition != widget.userPosition) {
      _buildMarkers();
    }
  }

  void _initializeCamera() {
    if (widget.userPosition != null) {
      _initialCameraPosition = CameraPosition(
        target: LatLng(
          widget.userPosition!.latitude,
          widget.userPosition!.longitude,
        ),
        zoom: 13.0,
      );
    } else if (widget.stations.isNotEmpty) {
      // إذا لم يكن هناك موقع للمستخدم، نركز على أول محطة
      final firstStation = widget.stations.first;
      _initialCameraPosition = CameraPosition(
        target: LatLng(firstStation.latitude, firstStation.longitude),
        zoom: 12.0,
      );
    } else {
      // القاهرة كموقع افتراضي
      _initialCameraPosition = const CameraPosition(
        target: LatLng(30.0444, 31.2357),
        zoom: 11.0,
      );
    }
  }

  void _buildMarkers() {
    final markers = <Marker>{};

    // إضافة علامة موقع المستخدم
    if (widget.userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            widget.userPosition!.latitude,
            widget.userPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(
            title: 'موقعك الحالي',
            snippet: 'أنت هنا',
          ),
        ),
      );
    }

    // إضافة علامات المحطات
    for (final station in widget.stations) {
      final color = _getMarkerColor(station.status);
      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(color),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: station.status != null
                ? '${station.status!.label}${station.distanceKm != null ? ' • ${station.distanceKm!.toStringAsFixed(1)} كم' : ''}'
                : station.address,
          ),
          onTap: () {
            if (widget.onStationTap != null) {
              widget.onStationTap!(station);
            }
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });

    // تحديث الكاميرا لتشمل جميع العلامات
    if (_mapController != null && widget.stations.isNotEmpty) {
      _fitBounds();
    }
  }

  double _getMarkerColor(CrowdStatus? status) {
    switch (status) {
      case CrowdStatus.crowded:
        return BitmapDescriptor.hueRed; // أحمر
      case CrowdStatus.medium:
        return BitmapDescriptor.hueOrange; // برتقالي
      case CrowdStatus.quiet:
        return BitmapDescriptor.hueGreen; // أخضر
      default:
        return BitmapDescriptor.hueBlue; // رمادي
    }
  }

  Future<void> _fitBounds() async {
    if (_mapController == null || widget.stations.isEmpty) return;

    final positions = <LatLng>[];

    // إضافة موقع المستخدم إذا كان متاحاً
    if (widget.userPosition != null) {
      positions.add(LatLng(
        widget.userPosition!.latitude,
        widget.userPosition!.longitude,
      ));
    }

    // إضافة مواقع المحطات
    for (final station in widget.stations) {
      positions.add(LatLng(station.latitude, station.longitude));
    }

    if (positions.isEmpty) return;

    // حساب الحدود
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      minLat = minLat < pos.latitude ? minLat : pos.latitude;
      maxLat = maxLat > pos.latitude ? maxLat : pos.latitude;
      minLng = minLng < pos.longitude ? minLng : pos.longitude;
      maxLng = maxLng > pos.longitude ? maxLng : pos.longitude;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding بالبكسل
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // بعد إنشاء الخريطة، نضبط الحدود لتشمل جميع العلامات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMapsWeb() async {
    String url;
    if (widget.userPosition != null) {
      // فتح Google Maps على موقع المستخدم
      url = 'https://www.google.com/maps/@${widget.userPosition!.latitude},${widget.userPosition!.longitude},13z';
    } else if (widget.stations.isNotEmpty) {
      // فتح Google Maps على أول محطة
      final firstStation = widget.stations.first;
      url = 'https://www.google.com/maps/@${firstStation.latitude},${firstStation.longitude},12z';
    } else {
      // القاهرة كموقع افتراضي
      url = 'https://www.google.com/maps/@30.0444,31.2357,11z';
    }

    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح Google Maps')),
        );
      }
    }
  }

  Widget _buildWebFallback() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'الخريطة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الخريطة متاحة على Android و iOS فقط',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openGoogleMapsWeb,
              icon: const Icon(Icons.open_in_new),
              label: const Text('فتح Google Maps'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (widget.stations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${widget.stations.length} محطة متاحة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // على Web، نعرض بديل
    if (kIsWeb) {
      return _buildWebFallback();
    }

    if (_initialCameraPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _initialCameraPosition!,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      onMapCreated: _onMapCreated,
      compassEnabled: true,
    );
  }
}
