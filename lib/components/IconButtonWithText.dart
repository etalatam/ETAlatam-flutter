import 'package:flutter/material.dart';

class IconButtonWithText extends StatelessWidget {
  final Icon icon;
  final Text label;
  final VoidCallback onPressed;

  IconButtonWithText({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          icon,
          label,
        ],
      ),
    );
  }
}
