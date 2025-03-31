import 'package:flutter/material.dart';

class ImageDefault extends StatelessWidget {
  const ImageDefault({super.key, required this.name, required this.height, required this.width});
  final String name;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.network(
        'https://ui-avatars.com/api/?background=random&name=$name',
        fit: BoxFit.fill,
        height: height,
        width: width,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) {
          print("[ImageDefault] error: $error");
          return Icon(Icons.error, size: height);
        },
      ),
    );
  }
}