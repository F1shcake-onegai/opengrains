import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/app_localizations.dart';
import '../services/location_service.dart';

class MapPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerPage({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _pin;
  final MapController _mapController = MapController();
  bool _locatingGps = false;

  @override
  void initState() {
    super.initState();
    _pin = LatLng(
      widget.initialLat ?? 35.6762,
      widget.initialLng ?? 139.6503,
    );
    // If no initial location, try to get current GPS
    if (widget.initialLat == null) {
      _goToCurrentLocation();
    }
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _locatingGps = true);
    try {
      final result = await LocationService.getCurrentPosition();
      if (result != null && mounted) {
        final newPin = LatLng(result.$1, result.$2);
        setState(() => _pin = newPin);
        _mapController.move(newPin, _mapController.camera.zoom);
      }
    } catch (_) {}
    if (mounted) setState(() => _locatingGps = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.t('shot_map_title')),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pin,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => _pin = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.muxianli.photographytoolbox',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pin,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_pin,
                        size: 40, color: cs.error),
                  ),
                ],
              ),
            ],
          ),
          // Coordinate display at top
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surface.withAlpha(230),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                LocationService.formatCoordinates(
                    _pin.latitude, _pin.longitude),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          // GPS button
          Positioned(
            right: 16,
            bottom: 88,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              onPressed: _locatingGps ? null : _goToCurrentLocation,
              child: _locatingGps
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
            ),
          ),
          // Confirm button
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(
                  context, (_pin.latitude, _pin.longitude)),
              icon: const Icon(Icons.check),
              label: Text(l.t('shot_map_confirm')),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
