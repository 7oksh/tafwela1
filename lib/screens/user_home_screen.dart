import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/station.dart';
import '../services/stations_service.dart';
import '../services/station_status_service.dart';
import '../services/location_service.dart';
import '../widgets/station_card.dart';
import '../widgets/station_map_widget.dart';
import '../widgets/dark_mode_button.dart';
import 'station_details_screen.dart';

/// شاشة المستخدم الرئيسية - الخريطة والقائمة
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final StationsService _stationsService = StationsService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  List<Station> _allStations = [];
  List<Station> _filteredStations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  CrowdStatus? _selectedFilter;
  Position? _userPosition;
  bool _locationUsed = false;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// [forceRefreshFromNetwork] = true عند السحب للتحديث لجلب أحدث المحطات من الإنترنت
  Future<void> _loadStations({bool forceRefreshFromNetwork = false}) async {
    setState(() => _isLoading = true);
    try {
      final position = await _locationService.getCurrentPosition();
      _userPosition = position;

      if (forceRefreshFromNetwork) {
        await _stationsService.refreshStationsFromNetwork();
      }

      // لو عندنا موقع: نجيب المحطات حولك من النت عشان الأقرب يظهروا كلهم
      final stations = position != null
          ? await _stationsService.getStationsWithNearbyFirst(
        position.latitude,
        position.longitude,
      )
          : await _stationsService.getAllStations();
      var list = stations;

      if (position != null) {
        _locationUsed = true;
        list = list
            .map((s) {
          final distanceMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            s.latitude,
            s.longitude,
          );
          return s.copyWith(distanceKm: distanceMeters / 1000.0);
        })
            .where((s) => s.distanceKm != null && s.distanceKm! <= 20.0)
            .toList()
          ..sort((a, b) {
            final da = a.distanceKm ?? double.infinity;
            final db = b.distanceKm ?? double.infinity;
            return da.compareTo(db);
          });
      } else {
        _locationUsed = false;
      }

      setState(() {
        _allStations = list;
        _filteredStations = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في تحميل المحطات: $e')),
        );
      }
    }
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    // استخدام List.from مرة واحدة فقط
    final result = <Station>[];

    // فلترة حسب البحث والحالة في حلقة واحدة (تحسين الأداء)
    final searchQuery = _searchQuery.toLowerCase();
    final hasSearch = searchQuery.isNotEmpty;

    for (final station in _allStations) {
      // فلترة حسب البحث
      if (hasSearch) {
        final nameMatch = station.name.toLowerCase().contains(searchQuery);
        final addressMatch = station.address.toLowerCase().contains(searchQuery);
        if (!nameMatch && !addressMatch) continue;
      }

      // فلترة حسب حالة الازدحام
      if (_selectedFilter != null && station.status != _selectedFilter) {
        continue;
      }

      result.add(station);
    }

    if (mounted) {
      setState(() {
        _filteredStations = result;
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'فلترة حسب الحالة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...CrowdStatus.values.map((status) {
                return RadioListTile<CrowdStatus?>(
                  title: Text(status.label),
                  value: status,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                  },
                );
              }),
              RadioListTile<CrowdStatus?>(
                title: const Text('الكل'),
                value: null,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = null;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStationDetails(Station station) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StationDetailsScreen(station: station),
      ),
    );
  }

  Future<void> _openGoogleMapsNearby() async {
    // نفتح Google Maps على أقرب محطات بنزين (يعتمد على موقع الجهاز)
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=gas+stations+near+me',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('محطات البنزين'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'فتح Google Maps',
              onPressed: _openGoogleMapsNearby,
            ),
            const DarkModeButton(),
          ],
        ),
        body: _buildListTab(),
      ),
    );
  }

  Widget _buildMapTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // شريط البحث
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن محطة...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                  _applyFilters();
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => _performSearch(),
          ),
        ),
        // الخريطة الفعلية
        Expanded(
          child: StationsMapWidget(
            stations: _filteredStations,
            userPosition: _userPosition,
            onStationTap: _openStationDetails,
          ),
        ),
      ],
    );
  }

  Widget _buildListTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // شريط البحث وفلتر
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن محطة...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _applyFilters();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: _selectedFilter != null
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: _showFilterDialog,
                tooltip: 'فلترة',
              ),
            ],
          ),
        ),
        // رسالة عند استخدام الموقع أو عدمه
        if (_locationUsed && _filteredStations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(Icons.my_location, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'أقرب المحطات لك',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else if (!_locationUsed && _allStations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_off, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لم يتم تحديد موقعك. اضغط "تحديد موقعي" واسمح بالصلاحية لعرض أقرب المحطات.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await _loadStations();
                        },
                        icon: const Icon(Icons.my_location, size: 20),
                        label: const Text('تحديد موقعي'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // عدد النتائج (عند الفلترة)
        if (_filteredStations.length != _allStations.length)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تم العثور على ${_filteredStations.length} محطة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        // قائمة المحطات
        Expanded(
          child: _filteredStations.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد محطات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'جرب البحث بكلمات مختلفة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: () => _loadStations(forceRefreshFromNetwork: true),
            child: ListView.builder(
              itemCount: _filteredStations.length,
              itemBuilder: (context, index) {
                final station = _filteredStations[index];
                return StationCard(
                  key: ValueKey(station.id), // تحسين الأداء
                  station: station,
                  onTap: () => _openStationDetails(station),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
