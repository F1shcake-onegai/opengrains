import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS);

  static Future<bool> ensurePermission() async {
    if (!isSupported) return false;
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  static Future<(double, double)?> getCurrentPosition() async {
    if (!await ensurePermission()) return null;
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return (position.latitude, position.longitude);
  }

  static String formatCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) return '';
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }
}
