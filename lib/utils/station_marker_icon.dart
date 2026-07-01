/// Legacy marker icon builder — no longer used.
///
/// `flutter_map` uses the [StationMapPin] Flutter widget directly as marker
/// children, so Canvas-based [BitmapDescriptor] generation is unnecessary.
///
/// Kept as a stub to prevent import errors in files that may still reference it.
abstract final class StationMarkerIcon {
  static void clearCache() {}
}
