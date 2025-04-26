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

  Future<Uint8List> getNetworkImage(String imageUrl, {String name = ""}) async {
    try {
      final http.Response response =
          await http.get(Uri.parse(imageUrl), headers: {'Accept': 'image/png'});
      
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {

        return await _generateDefaultImage(name);
      }
      
      final Uint8List bytes = response.bodyBytes;

      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageData = byteData!.buffer.asUint8List();

      return imageData;
    } catch (e) {
      print("Error cargando imagen: $e");
      return await _generateDefaultImage(name);
    }
  }
  

  Future<Uint8List> _generateDefaultImage(String name) async {
    try {

      final http.Response response = await http.get(
        Uri.parse('https://ui-avatars.com/api/?background=0D8ABC&format=png&name=$name'),
      );
      
      return response.bodyBytes;
    } catch (e) {
      print("Error generando imagen por defecto: $e");
      return await _createBlankImage();
    }
  }
  
  Future<Uint8List> _createBlankImage() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 100.0;
    
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      Paint()..color = Color(0xFF0D8ABC),
    );
    
    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> createCircleImage(Uint8List imageData, {bool hasActiveTrip = false, bool isOnBoard = false}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();
    const double size = 250.0;
    const double borderSize = 10.0;

    final ui.Image image = await decodeImageFromList(imageData);
    final Rect rect = Rect.fromLTWH(
        borderSize, borderSize, size - 2 * borderSize, size - 2 * borderSize);
    final Path path = Path()..addOval(rect);

    canvas.drawOval(
        Rect.fromLTWH(0, 0, size + 2, size + 2), Paint()..color = Colors.black);
    canvas.drawOval(
        Rect.fromLTWH(0, 0, size, size), 
        Paint()..color = hasActiveTrip ? (isOnBoard ? Colors.green : Colors.red) : Colors.white);
    
    if (hasActiveTrip) {
      canvas.drawOval(
          Rect.fromLTWH(5, 5, size - 10, size - 10), 
          Paint()..color = Colors.white);
    }

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
      annotationManager, Position position, Uint8List imageData, String label) async {
    return await annotationManager?.create(PointAnnotationOptions(
        geometry: Point(coordinates: position),
        textOffset: [0.0, -2.0],
        iconSize: 0.35,
        iconOffset: [0.0, -5.0],
        symbolSortKey: 100,
        image: imageData,
        textField: label,
        textSize: 14.0,
        textColor: Colors.black.value,
        textHaloColor: Colors.white.value,
        textHaloWidth: 2.0,
        textHaloBlur: 0.5
    ));
  }
}
