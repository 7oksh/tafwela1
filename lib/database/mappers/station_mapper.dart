import 'dart:convert';

import 'package:new_version/database/entities/station_entity.dart';
import 'package:new_version/models/fuel_type_model.dart';
import 'package:new_version/models/station_model.dart';

extension StationEntityMapper on StationEntity {
  StationModel toModel() {
    return StationModel(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceKm: 0,
      rating: rating,
      crowdStatus: _parseCrowdStatus(crowdStatus),
      imageUrl: imageUrl,
      fuelTypes: _decodeFuelTypes(fuelTypesJson),
      services: _decodeServices(servicesJson),
      isOpen: isOpen,
    );
  }

  static CrowdStatus _parseCrowdStatus(String value) {
    return switch (value) {
      'low' => CrowdStatus.low,
      'medium' => CrowdStatus.medium,
      'high' => CrowdStatus.high,
      'none' => CrowdStatus.none,
      _ => CrowdStatus.low,
    };
  }

  static List<FuelTypeModel> _decodeFuelTypes(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => FuelTypeModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static List<String> _decodeServices(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }
}

extension StationModelMapper on StationModel {
  StationEntity toEntity() {
    return StationEntity(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
      crowdStatus: crowdStatus.name,
      imageUrl: imageUrl,
      isOpen: isOpen,
      fuelTypesJson: jsonEncode(fuelTypes.map((e) => e.toMap()).toList()),
      servicesJson: jsonEncode(services),
      cachedAt: DateTime.now().toIso8601String(),
    );
  }
}
