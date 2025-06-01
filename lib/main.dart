import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe_city/chatbot.dart';

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
          // Google Map in the background
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
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Custom header on top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Color(0xFFE5FFFF),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/combined_logo.png',
                    width: 10,
                    height: 10,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.contact_support_rounded),
                        onPressed: () {
                          print("Contact Support Icon Tapped!");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChatBot()),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          // Handle settings action
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom nav bar
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
                    onTap: () {},
                  ),
                  NavItem(
                    icon: Icons.local_police_sharp,
                    label: 'Report a Crime',
                    onTap: () {},
                  ),
                  NavItem(
                    icon: Icons.phone_in_talk,
                    label: 'Fake Call',
                    onTap: () {},
                  ),
                  NavItem(
                    icon: Icons.nordic_walking,
                    label: 'Walk-with-Me',
                    onTap: () {},
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

