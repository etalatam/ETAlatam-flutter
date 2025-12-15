import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';

class FullTextButton extends StatelessWidget {
  const FullTextButton(this.callback, this.title, {super.key, this.fontSize = 20});

  final Function callback;
  final String? title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        callback();
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: activeTheme.buttonBG,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Text(
          "$title",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: activeTheme.main_bg,
              fontSize: fontSize,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
