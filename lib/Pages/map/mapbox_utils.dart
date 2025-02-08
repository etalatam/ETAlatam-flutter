import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

final MapboxUtils mapboxUtils = MapboxUtils();

class MapboxUtils {
  static final MapboxUtils _instance = MapboxUtils._internal();

  factory MapboxUtils() => _instance;

  MapboxUtils._internal();

  Future<Uint8List> getNetworkImage(String imageUrl) async {
    final http.Response response =
        await http.get(Uri.parse(imageUrl), headers: {'Accept': 'image/png'});
    final Uint8List bytes = response.bodyBytes;

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = byteData!.buffer.asUint8List();

    return imageData;
  }

  Future<Uint8List> createCircleImage(Uint8List imageData) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();
    const double size = 250.0;
    const double borderSize = 10.0;

    final ui.Image image = await decodeImageFromList(imageData);
    final Rect rect = Rect.fromLTWH(
        borderSize, borderSize, size - 2 * borderSize, size - 2 * borderSize);
    final Path path = Path()..addOval(rect);

    // Dibujar el borde blanco
    canvas.drawOval(
        Rect.fromLTWH(0, 0, size + 2, size + 2), Paint()..color = Colors.black);
    canvas.drawOval(
        Rect.fromLTWH(0, 0, size, size), Paint()..color = Colors.white);

    // Dibujar la imagen circular
    canvas.clipPath(path);
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        rect,
        paint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image circularImage =
        await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await circularImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<PointAnnotation?> createAnnotation(
      annotationManager, Position position, Uint8List imageData) async {
    return await annotationManager?.create(PointAnnotationOptions(
        geometry: Point(coordinates: position),
        textField: "",
        textOffset: [0.0, -1.0],
        textColor: Colors.black.value,
        iconSize: 0.35,
        iconOffset: [0.0, -5.0],
        symbolSortKey: 1,
        image: imageData));
  }
}
