import 'package:floor/floor.dart';
import 'package:new_version/database/mappers/station_mapper.dart';
import 'package:new_version/models/station_model.dart';

@Entity(tableName: 'stations')
class StationEntity {
  @PrimaryKey()
  final String id;

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final String crowdStatus;
  final String imageUrl;
  final bool isOpen;
  final String fuelTypesJson;
  final String servicesJson;
  final String cachedAt;

  StationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.crowdStatus,
    required this.imageUrl,
    required this.isOpen,
    required this.fuelTypesJson,
    required this.servicesJson,
    required this.cachedAt,
  });

  factory StationEntity.fromModel(StationModel model) => model.toEntity();
}
