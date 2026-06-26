import 'package:flutter/foundation.dart';

abstract final class MapsConfig {
  // API key used for both the map widget and Directions API calls.
  // Override at build time: flutter run --dart-define=GOOGLE_MAPS_API_KEY=xxx
  static const apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyCyTeU9StDWm9kAQqTpwRHNLz6dGMFJc3E',
  );

  static bool get isConfigured =>
      apiKey.isNotEmpty && !apiKey.startsWith('YOUR_');

  static bool get useGoogleMap => !kIsWeb || isConfigured;
}
