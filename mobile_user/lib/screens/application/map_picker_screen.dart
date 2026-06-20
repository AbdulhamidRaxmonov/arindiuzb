import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/l10n.dart';

class PickedLocation {
  final double latitude;
  final double longitude;
  final String address;
  PickedLocation(this.latitude, this.longitude, this.address);
}

/// Full-screen Google Map; user drags the map to position a center pin and
/// confirms. We reverse-geocode the coordinates into a human address.
class MapPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const MapPickerScreen({super.key, this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  // Default to Tashkent center.
  LatLng _center = const LatLng(41.2995, 69.2401);
  String _address = '';
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) _center = widget.initial!;
    _locateMe();
  }

  Future<void> _locateMe() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final target = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = target);
      _controller?.animateCamera(CameraUpdate.newLatLng(target));
      _resolveAddress();
    } catch (_) {}
  }

  Future<void> _resolveAddress() async {
    setState(() => _resolving = true);
    try {
      final placemarks =
          await placemarkFromCoordinates(_center.latitude, _center.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _address = [p.street, p.subLocality, p.locality, p.administrativeArea]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
      }
    } catch (_) {
      _address = '${_center.latitude.toStringAsFixed(5)}, '
          '${_center.longitude.toStringAsFixed(5)}';
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('pick_on_map'))),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            onMapCreated: (c) => _controller = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onCameraMove: (pos) => _center = pos.target,
            onCameraIdle: _resolveAddress,
          ),
          // Center pin.
          const Padding(
            padding: EdgeInsets.only(bottom: 36),
            child: Icon(Icons.location_on, size: 48, color: Colors.red),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _resolving
                              ? const Text('...')
                              : Text(
                                  _address.isEmpty
                                      ? '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}'
                                      : _address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(
                        context,
                        PickedLocation(
                          _center.latitude,
                          _center.longitude,
                          _address.isEmpty
                              ? '${_center.latitude}, ${_center.longitude}'
                              : _address,
                        ),
                      ),
                      icon: const Icon(Icons.check),
                      label: Text(t.t('save')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
