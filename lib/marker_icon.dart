import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createCustomMarkerWithTail(String assetPath) async {
  final ByteData byteData = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List(), targetWidth: 128);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Paint paint = Paint()..isAntiAlias = true;

  final double size = 128;

  // Draw circle
  canvas.drawCircle(Offset(size / 2, size / 2 - 16), 40, paint);

  // Draw image clipped in circle
  canvas.saveLayer(null, Paint());
  Path clipPath = Path()
    ..addOval(Rect.fromCircle(center: Offset(size / 2, size / 2 - 16), radius: 40));
  canvas.clipPath(clipPath);
  paintImage(canvas: canvas, rect: Rect.fromLTWH(24, 24, 80, 80), image: image, fit: BoxFit.cover);
  canvas.restore();

  // Draw point tail
  final path = Path()
    ..moveTo(size / 2 - 10, size / 2 + 30)
    ..lineTo(size / 2 + 10, size / 2 + 30)
    ..lineTo(size / 2, size / 2 + 60)
    ..close();
  canvas.drawPath(path, paint);

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
}
