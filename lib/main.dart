import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe_city/chatbot.dart';
import 'package:safe_city/fake_call_page.dart';
import 'package:safe_city/report_crime_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:safe_city/marker_icon.dart';
import 'package:safe_city/walk_with_me.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "gemini_api.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapPage(),
      routes: {
    '/fake': (context) => const FakeCallPage(),
    '/chat': (context) => const ChatBot(),
    '/report_crime': (context) => const ReportCrimePage(),
    '/map': (context) => MapPage(),
    },
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
  static const LatLng _Roi = LatLng(
      14.677778005314575, 121.0321500772428);
  static const LatLng _Mhyca = LatLng(
      14.670549534316887, 121.03700195954309);
  static const LatLng _Denrick = LatLng(
      14.669716400002702, 121.03272666778895);
  LatLng? _currentPosition = null;
  LatLng? _destinationPosition = null;
  BitmapDescriptor? _reyIcon;
  BitmapDescriptor? _roiIcon;
  BitmapDescriptor? _denrickIcon;
  BitmapDescriptor? _mhycaIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    getLocationUpdates();
  }

  void _loadCustomMarker() async {
    _reyIcon = await createCustomMarkerWithTail('assets/rey.png');
    _roiIcon = await createCustomMarkerWithTail('assets/roi.png');
    _denrickIcon = await createCustomMarkerWithTail('assets/denrick.png');
    _mhycaIcon = await createCustomMarkerWithTail('assets/mhyca.png');// Replace with your actual image
    setState(() {});
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
                icon: _reyIcon ?? BitmapDescriptor.defaultMarker,
                position: _currentPosition!,
              ),
              Marker(
                markerId: MarkerId("_Roi"),
                icon: _roiIcon ?? BitmapDescriptor.defaultMarker,
                position: _Roi,
              ),
              Marker(
                markerId: MarkerId("_Denrick"),
                icon: _denrickIcon ?? BitmapDescriptor.defaultMarker,
                position: _Denrick,
              ),
              Marker(
                markerId: MarkerId("_Mhyca"),
                icon: _mhycaIcon ?? BitmapDescriptor.defaultMarker,
                position: _Mhyca,
              ),
              if (_destinationPosition != null)
                Marker(
                  markerId: MarkerId("_destination"),
                  position: _destinationPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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

          Positioned(
            top: 100,
            left: 10,
            right: 10,
            child: GestureDetector(
              onTap: () async {
                final LatLng? selectedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PinLocationPage()),
                );

                if (selectedLocation != null) {
                  setState(() {
                    _destinationPosition = selectedLocation;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.nordic_walking),
                    SizedBox(width: 10),
                    Text("Walk-with-me", style: TextStyle(color: Colors.grey)),
                  ],
                ),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportCrimePage()),
                      );
                    },
                  ),
                  NavItem(
                    icon: Icons.phone_in_talk,
                    label: 'Fake Call',
                    onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FakeCallPage()),
                      );
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
