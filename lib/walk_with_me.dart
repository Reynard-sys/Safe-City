import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinLocationPage extends StatefulWidget {
  const PinLocationPage({super.key});

  @override
  State<PinLocationPage> createState() => _PinLocationPageState();
}

class _PinLocationPageState extends State<PinLocationPage> {
  LatLng _pinnedLocation = const LatLng(14.676178523935386, 121.03316764130763);
  GoogleMapController? _mapController;

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _pinnedLocation = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pin Destination'), backgroundColor: Color(0xFFE5FFFF)),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _pinnedLocation,
              zoom: 15,
            ),
            onTap: _onMapTapped,
            markers: {
              Marker(
                markerId: MarkerId("pinned"),
                position: _pinnedLocation,
              )
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _pinnedLocation);
              },
              child: Text("Set this as destination"),
            ),
          )
        ],
      ),
    );
  }
}
