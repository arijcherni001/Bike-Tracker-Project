import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  final double? bluetoothLatitude;
  final double? bluetoothLongitude;

  const MapScreen({
    super.key,
    this.bluetoothLatitude,
    this.bluetoothLongitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Location location = Location();
  LocationData? _currentLocation;
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  final Set<Marker> _markers = {};
  StreamSubscription<LocationData>? _locationSubscription;

  // Default location (Tunis, Tunisia - adjust as needed)
  static const LatLng _defaultLocation = LatLng(36.8065, 10.1815);

  @override
  void initState() {
    super.initState();
    // Si on a des coordonnées Bluetooth, les utiliser en priorité
    if (widget.bluetoothLatitude != null && widget.bluetoothLongitude != null) {
      _currentLocation = LocationData.fromMap({
        'latitude': widget.bluetoothLatitude,
        'longitude': widget.bluetoothLongitude,
      });
      // Ajouter un marqueur pour la position GPS Bluetooth
      _markers.add(
        Marker(
          markerId: const MarkerId('bluetooth_gps'),
          position:
              LatLng(widget.bluetoothLatitude!, widget.bluetoothLongitude!),
          infoWindow: const InfoWindow(
            title: 'Position GPS Bluetooth',
            snippet: 'Données du module GPS',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // Check if location service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check location permissions
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get current location
    try {
      _currentLocation = await location.getLocation();
      if (_currentLocation != null) {
        _updateMapLocation(_currentLocation!);
      }

      // Listen to location changes
      _locationSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        setState(() {
          _currentLocation = currentLocation;
          _updateMapLocation(currentLocation);
        });
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void _updateMapLocation(LocationData locationData) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(locationData.latitude!, locationData.longitude!),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _updateMapLocation(_currentLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Tracker Map'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_connected),
            onPressed: () {
              Navigator.pushNamed(context, '/affichage');
            },
            tooltip: 'Données GPS Bluetooth',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              if (_currentLocation != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(_currentLocation!.latitude!,
                        _currentLocation!.longitude!),
                    15,
                  ),
                );
              } else {
                // Try to get location again
                try {
                  LocationData locationData = await location.getLocation();
                  _updateMapLocation(locationData);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Unable to get current location')),
                  );
                }
              }
            },
            tooltip: 'My Location',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'bluetooth') {
                Navigator.pushNamed(context, '/ble');
              } else if (value == 'history') {
                Navigator.pushNamed(context, '/historique');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bluetooth',
                child: Row(
                  children: [
                    Icon(Icons.bluetooth, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Bluetooth'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _currentLocation == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('Loading map...'),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _initializeLocation,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation != null
                    ? LatLng(_currentLocation!.latitude!,
                        _currentLocation!.longitude!)
                    : _defaultLocation,
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              compassEnabled: true,
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
