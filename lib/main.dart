import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'; // Add this import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController = Completer<
      GoogleMapController>();

  static const LatLng _pGooglePlex = LatLng(
      14.676178523935386, 121.03316764130763);
  static const LatLng _pApplePark = LatLng(
      14.599173347940376, 121.01186908646466);
  LatLng? _currentPosition = null;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: Text("Loading..."))
          : Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _pGooglePlex,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId("_currentLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: _currentPosition!,
              ),
              Marker(
                markerId: MarkerId("_sourceLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: _pGooglePlex,
              ),
              Marker(
                markerId: MarkerId("_destinationLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: _pApplePark,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NavItem(
                    icon: Icons.location_on,
                    label: 'Maps',
                    onTap: () {
                      // Do something
                    },
                  ),
                  NavItem(
                    icon: Icons.local_police_sharp,
                    label: 'Report a Crime',
                    onTap: () {
                      // Do something
                    },
                  ),
                  NavItem(
                    icon: Icons.phone_in_talk,
                    label: 'Fake Call',
                    onTap: () {
                      // Do something
                    },
                  ),
                  NavItem(
                    icon: Icons.nordic_walking,
                    label: 'Walk-with-Me',
                    onTap: () {
                      // Do something
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 15,);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),);
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((
        LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentPosition!);
        });
      }
    });
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(height: 6, width: 6),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
