import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe_city/chatbot.dart';
import 'package:safe_city/fake_call_page.dart';
import 'package:safe_city/report_crime_modal.dart';
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
        '/report_crime': (context) => const ReportCrimeModal(),
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

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer();

  static const double sosButtonSize = 150.0;
  static const double buttonCoreSize = 100.0;
  static const double haloSize = 180.0;
  static const double padding = 0.0;

  static const LatLng _pGooglePlex = LatLng(14.676178523935386, 121.03316764130763);
  static const LatLng _Roi = LatLng(14.677778005314575, 121.0321500772428);
  static const LatLng _Mhyca = LatLng(14.670549534316887, 121.03700195954309);
  static const LatLng _Denrick = LatLng(14.669716400002702, 121.03272666778895);

  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  BitmapDescriptor? _reyIcon, _roiIcon, _denrickIcon, _mhycaIcon;

  Offset _sosButtonPosition = Offset.zero;

  late AnimationController _sosAnimationController;
  late Animation<double> _sosAnimation;
  bool _sosActive = false;

  late AnimationController _locationPulseController;
  late Animation<double> _locationPulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    getLocationUpdates();

    _sosAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..addListener(() {
      if (_sosActive) setState(() {});
    });

    _sosAnimation = Tween<double>(begin: 0, end: 1).animate(_sosAnimationController);

    _locationPulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    _locationPulseAnimation = Tween<double>(begin: 0, end: 1).animate(_locationPulseController);
  }

  @override
  void dispose() {
    _sosAnimationController.dispose();
    _locationPulseController.dispose();
    super.dispose();
  }

  void _loadCustomMarker() async {
    _reyIcon = await createCustomMarkerWithTail('assets/rey.png');
    _roiIcon = await createCustomMarkerWithTail('assets/roi.png');
    _denrickIcon = await createCustomMarkerWithTail('assets/denrick.png');
    _mhycaIcon = await createCustomMarkerWithTail('assets/mhyca.png');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: Text("Loading..."))
          : LayoutBuilder(
        builder: (context, constraints) {
          if (_sosButtonPosition == Offset.zero) {
            _sosButtonPosition = Offset(
              constraints.maxWidth - sosButtonSize - padding,
              constraints.maxHeight - sosButtonSize - 100,
            );
          }

          return Stack(
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

              // Radiating Pulse at Current Location when SOS is active
              if (_currentPosition != null && _sosActive)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _locationPulseAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: RadiatingCirclePainter(_locationPulseAnimation.value),
                          child: Container(),
                        );
                      },
                    ),
                  ),
                ),


              // HEADER
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/logo.png', height: 36),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.contact_support_rounded, color: Colors.black87),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBot())),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.black87),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // WALK-WITH-ME
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

              // SOS BUTTON
              Positioned(
                left: _sosButtonPosition.dx,
                top: _sosButtonPosition.dy,
                child: Draggable(
                  feedback: _buildSosButton(),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragEnd: (details) {
                    setState(() {
                      final newOffset = details.offset;
                      final screenWidth = MediaQuery.of(context).size.width;
                      final screenHeight = MediaQuery.of(context).size.height;

                      final double topLimit = 100 + 12 + 30; // Walk-with-me top + padding + height
                      final double bottomLimit = screenHeight - 80 - 20 - sosButtonSize; // nav bar height + margin + sos height

                      double finalX = newOffset.dx < screenWidth / 2
                          ? padding
                          : screenWidth - sosButtonSize - padding;

                      double finalY = newOffset.dy.clamp(
                        topLimit,
                        bottomLimit,
                      );

                      _sosButtonPosition = Offset(finalX, finalY);
                    });
                  },

                  child: _buildSosButton(),
                ),
              ),

              // BOTTOM NAV
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ModernNavItem(icon: Icons.location_on, label: 'Maps', onTap: () {}),
                        _ModernNavItem(
                          icon: Icons.local_police_sharp,
                          label: 'Report',
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const ReportCrimeModal(),
                            );
                          },
                        ),
                        _ModernNavItem(
                          icon: Icons.phone_in_talk,
                          label: 'Fake Call',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FakeCallPage()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSosButton() {
    return SizedBox(
      width: sosButtonSize,
      height: sosButtonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              print('SOS button pressed');
              setState(() => _sosActive = true);
              _sosAnimationController.repeat();
            },
            fillColor: Colors.red,
            shape: const CircleBorder(),
            constraints: BoxConstraints.tightFor(
              width: buttonCoreSize,
              height: buttonCoreSize,
            ),
            child: const Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 15)));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          _currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentPosition!);
        });
      }
    });
  }
}

class RadiatingCirclePainter extends CustomPainter {
  final double progress;

  RadiatingCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    final double maxRadius = 150; // Maximum radius of the outermost circle
    const int ringCount = 3; // Number of radiating rings
    const double ringSpacing = 1.0 / ringCount;

    for (int i = 0; i < ringCount; i++) {
      final double ringProgress = (progress + i * ringSpacing) % 1.0;
      final double radius = maxRadius * ringProgress;

      final double opacity = (1.0 - ringProgress).clamp(0.0, 1.0);
      paint.color = Colors.red.withOpacity(pow(opacity, 2).toDouble());

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RadiatingCirclePainter oldDelegate) =>
      oldDelegate.progress != progress;
}



class _ModernNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModernNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
