import 'dart:math';
import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class CreateEventLocationScreen extends ConsumerStatefulWidget {
  const CreateEventLocationScreen({super.key});

  @override
  ConsumerState<CreateEventLocationScreen> createState() =>
      _CreateEventLocationScreenState();
}

class _CreateEventLocationScreenState
    extends ConsumerState<CreateEventLocationScreen> {
  late TextEditingController _searchController;
  late TextEditingController _manualLinkController;
  late final MapController _mapController;

  double _currentLat = 28.7041;
  double _currentLng = 77.1025;
  double? _userGpsLat;
  double? _userGpsLng;
  bool _isGpsFetching = false;

  String _selectedVenueName = 'Current Location';
  String _selectedAddress = 'Fetching nearby area...';
  bool _isManualLinkMode = false;

  final List<Map<String, dynamic>> _curatedVenues = [
    {
      'name': 'The Glasshouse Terrace',
      'address': 'Hauz Khas Village, New Delhi, 110016',
      'lat': 28.5494,
      'lng': 77.1932,
    },
    {
      'name': 'Cyber Pier 9',
      'address': 'Cyber City, Sector 24, Gurugram, Haryana',
      'lat': 28.4950,
      'lng': 77.0895,
    },
    {
      'name': 'Skyline Rooftop Club',
      'address': 'Connaught Place, Central Delhi, 110001',
      'lat': 28.6315,
      'lng': 77.2167,
    },
    {
      'name': 'Vijay Nagar Hub',
      'address': 'Vijay Nagar, North Delhi, 110009, India',
      'lat': 28.6946,
      'lng': 77.2023,
    },
    {
      'name': 'Indiranagar Social Den',
      'address': '100 Feet Rd, Indiranagar, Bengaluru, 560038',
      'lat': 12.9716,
      'lng': 77.6412,
    },
    {
      'name': 'Bandra West Arena',
      'address': 'Hill Road, Bandra West, Mumbai, 400050',
      'lat': 19.0596,
      'lng': 72.8295,
    },
  ];

  List<Map<String, dynamic>> _sortedVenues = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    final draft = ref.read(createEventProvider);
    _selectedVenueName = draft.venueName.isNotEmpty ? draft.venueName : 'Current Location';
    _selectedAddress = draft.venueAddress.isNotEmpty
        ? draft.venueAddress
        : 'Detecting closest venue...';
    _searchController = TextEditingController(text: _selectedVenueName);
    _manualLinkController = TextEditingController(text: draft.googleMapsUrl ?? '');
    _sortedVenues = List.from(_curatedVenues);

    _initUserGpsLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _manualLinkController.dispose();
    super.dispose();
  }

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  Future<void> _initUserGpsLocation() async {
    setState(() => _isGpsFetching = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _sortVenuesByDefault();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _sortVenuesByDefault();
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _userGpsLat = position.latitude;
      _userGpsLng = position.longitude;
      _currentLat = position.latitude;
      _currentLng = position.longitude;

      // Sort curated venues by real distance from user
      _sortVenuesByGps(position.latitude, position.longitude);

      // Reverse geocode user location name
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final area = p.subLocality?.isNotEmpty == true
              ? p.subLocality!
              : (p.locality?.isNotEmpty == true ? p.locality! : 'Detected Location');
          final fullAddr = [p.name, p.subLocality, p.locality, p.administrativeArea, p.country]
              .where((s) => s != null && s.isNotEmpty)
              .toSet()
              .join(', ');

          if (mounted) {
            setState(() {
              _selectedVenueName = area;
              _selectedAddress = fullAddr;
              _searchController.text = area;
            });
            _mapController.move(LatLng(_currentLat, _currentLng), 14.0);
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _selectedVenueName = 'Current Location';
            _selectedAddress = 'Lat: ${_currentLat.toStringAsFixed(4)}, Lng: ${_currentLng.toStringAsFixed(4)}';
            _searchController.text = _selectedVenueName;
          });
        }
      }
    } catch (_) {
      _sortVenuesByDefault();
    } finally {
      if (mounted) setState(() => _isGpsFetching = false);
    }
  }

  void _sortVenuesByDefault() {
    _sortedVenues = List.from(_curatedVenues);
  }

  void _sortVenuesByGps(double uLat, double uLng) {
    final list = List<Map<String, dynamic>>.from(_curatedVenues);
    for (var v in list) {
      v['distanceKm'] = _calculateDistanceKm(uLat, uLng, v['lat'] as double, v['lng'] as double);
    }
    list.sort((a, b) => ((a['distanceKm'] as double)).compareTo(b['distanceKm'] as double));
    if (mounted) {
      setState(() {
        _sortedVenues = list.take(4).toList();
      });
    }
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _currentLat = point.latitude;
      _currentLng = point.longitude;
      _selectedVenueName = 'Selected Pin Location';
      _selectedAddress = 'Fetching address...';
    });
    _mapController.move(point, _mapController.camera.zoom);

    try {
      final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final name = p.name?.isNotEmpty == true
            ? p.name!
            : (p.subLocality?.isNotEmpty == true ? p.subLocality! : 'Custom Location');
        final addr = [p.name, p.subLocality, p.locality, p.administrativeArea, p.country]
            .where((s) => s != null && s.isNotEmpty)
            .toSet()
            .join(', ');
        setState(() {
          _selectedVenueName = name;
          _selectedAddress = addr;
          _searchController.text = name;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedAddress = 'Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  void _parseAndApplyGoogleMapsUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    // 1. Try matching @lat,lng
    final latLngReg = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = latLngReg.firstMatch(trimmed);

    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null) {
        _onMapTap(LatLng(lat, lng));
        setState(() => _isManualLinkMode = false);
        return;
      }
    }

    // 2. Try matching query parameter ?q=lat,lng
    final qReg = RegExp(r'[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)');
    final qMatch = qReg.firstMatch(trimmed);
    if (qMatch != null) {
      final lat = double.tryParse(qMatch.group(1)!);
      final lng = double.tryParse(qMatch.group(2)!);
      if (lat != null && lng != null) {
        _onMapTap(LatLng(lat, lng));
        setState(() => _isManualLinkMode = false);
        return;
      }
    }

    // 3. Fallback: extract place query text
    final placeReg = RegExp(r'/place/([^/@]+)');
    final placeMatch = placeReg.firstMatch(trimmed);
    if (placeMatch != null) {
      final placeName = Uri.decodeComponent(placeMatch.group(1)!.replaceAll('+', ' '));
      setState(() {
        _selectedVenueName = placeName;
        _selectedAddress = 'Google Maps: $placeName';
        _searchController.text = placeName;
        _isManualLinkMode = false;
      });
      return;
    }

    // Direct link accepted
    setState(() {
      _selectedVenueName = 'Google Maps Location';
      _selectedAddress = trimmed;
      _isManualLinkMode = false;
    });
  }

  void _onContinue() {
    ref.read(createEventProvider.notifier).updateLocation(
          venueName: _selectedVenueName,
          venueAddress: _selectedAddress,
          googleMapsUrl: _manualLinkController.text.trim().isNotEmpty
              ? _manualLinkController.text.trim()
              : null,
        );
    context.push('/organizer/events/create/audience');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: 140,
            height: 6,
            color: OrganizerColors.surfaceContainerHigh,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 90,
                height: 6,
                color: OrganizerColors.primary,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Location for your big thing',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Live Map Preview Box
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(_currentLat, _currentLng),
                        initialZoom: 14.0,
                        onTap: (tapPosition, point) => _onMapTap(point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.den',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_currentLat, _currentLng),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Color(0xFF630ED4),
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Tap to pin hint pill
                    Positioned(
                      top: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.touch_app, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Tap map to drop pin',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // My GPS Location Button
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton.small(
                        heroTag: 'gps_loc_btn',
                        backgroundColor: Colors.white,
                        foregroundColor: OrganizerColors.primary,
                        onPressed: _initUserGpsLocation,
                        child: _isGpsFetching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (!_isManualLinkMode) ...[
                // Selected Venue Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: OrganizerColors.primary.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: OrganizerColors.primary.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: OrganizerColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.place,
                          color: OrganizerColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedVenueName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: OrganizerColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Top 4 Nearest / Popular Venues
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nearby Approved Venues',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    if (_userGpsLat != null && _userGpsLng != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: OrganizerColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Ranked by Distance',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: OrganizerColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                ...List.generate(_sortedVenues.length, (index) {
                  final loc = _sortedVenues[index];
                  final isSelected = loc['name'] == _selectedVenueName;
                  final dist = loc['distanceKm'] as double?;

                  return InkWell(
                    onTap: () {
                      final lat = loc['lat'] as double;
                      final lng = loc['lng'] as double;
                      setState(() {
                        _selectedVenueName = loc['name'] as String;
                        _selectedAddress = loc['address'] as String;
                        _currentLat = lat;
                        _currentLng = lng;
                        _searchController.text = loc['name'] as String;
                      });
                      _mapController.move(LatLng(lat, lng), 15.0);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? OrganizerColors.primary.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? OrganizerColors.primary
                              : OrganizerColors.surfaceContainerHigh,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 20,
                            color: isSelected
                                ? OrganizerColors.primary
                                : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc['name'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: OrganizerColors.onSurface,
                                  ),
                                ),
                                Text(
                                  loc['address'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (dist != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${dist.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: OrganizerColors.primary,
                              ),
                            ),
                          ],
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle,
                                size: 18, color: OrganizerColors.primary),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),

                // Link to Google Maps input
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _isManualLinkMode = true),
                    icon: const Text(
                      'Paste a Google Maps link',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: OrganizerColors.primary,
                      ),
                    ),
                    label: const Icon(Icons.link,
                        size: 18, color: OrganizerColors.primary),
                  ),
                ),
              ] else ...[
                // Manual Google Maps Link Screen
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Google Maps Link',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: OrganizerColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _manualLinkController,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: OrganizerColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'https://maps.app.goo.gl/... or @28.70,77.10',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () => _parseAndApplyGoogleMapsUrl(_manualLinkController.text),
                          icon: const Icon(Icons.pin_drop, size: 18),
                          label: const Text(
                            'Load from Maps Link',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OrganizerColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _isManualLinkMode = false),
                  child: const Text('← Back to nearby list'),
                ),
              ],

              const SizedBox(height: 36),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _onContinue,
                  icon: const SizedBox.shrink(),
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
