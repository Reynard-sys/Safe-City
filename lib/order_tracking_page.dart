import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();

  static const LatLng sourceLocation = LatLng(14.676177015667808, 121.03316472313361);
  static const LatLng destination = LatLng(14.599216975400015, 121.0118302854665);

  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final userLocation = await _location.getLocation();

    _initialCameraPosition = CameraPosition(
      target: LatLng(userLocation.latitude!, userLocation.longitude!),
      zoom: 15,
    );

    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(_initialCameraPosition),
    );

    setState(() {}); // to rebuild the widget with new camera position
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialCameraPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {
          Marker(
            markerId: MarkerId('source'),
            position: sourceLocation,
            infoWindow: InfoWindow(title: 'Source'),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: destination,
            infoWindow: InfoWindow(title: 'Destination'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}