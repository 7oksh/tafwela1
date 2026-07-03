import 'package:new_version/models/station_model.dart';

class StationsResult {
  final List<StationModel> stations;
  final bool fromCache;

  const StationsResult({
    required this.stations,
    required this.fromCache,
  });
}
