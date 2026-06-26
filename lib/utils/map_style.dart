/// Google Maps JSON style — white & blue Tafwela theme.
/// Shows road labels only; hides POIs, transit, and clutter.
abstract final class MapStyles {
  static const tafwela = '''
[
  {"featureType":"all","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.business","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.neighborhood","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"featureType":"landscape","elementType":"geometry.fill","stylers":[{"color":"#f5f7fa"}]},
  {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#dbeafe"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#93c5fd"}]},
  {"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#cbd5e1"}]},
  {"featureType":"road.arterial","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.arterial","elementType":"geometry.stroke","stylers":[{"color":"#e2e8f0"}]},
  {"featureType":"road.local","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.local","elementType":"geometry.stroke","stylers":[{"color":"#e2e8f0"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#64748b"}]},
  {"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#ffffff"},{"weight":3}]}
]
''';
}

/// Street labels for the placeholder map.
abstract final class MapStreetLabels {
  static const labels = [
    MapStreetLabel('شارع النصر', 0.22, 0.38),
    MapStreetLabel('عباس العقاد', 0.55, 0.52),
    MapStreetLabel('26 يوليو', 0.72, 0.28),
    MapStreetLabel('التجمع الخامس', 0.38, 0.68),
  ];
}

class MapStreetLabel {
  const MapStreetLabel(this.name, this.xFactor, this.yFactor);
  final String name;
  final double xFactor;
  final double yFactor;
}
