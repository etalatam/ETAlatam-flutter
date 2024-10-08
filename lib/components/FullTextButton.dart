import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:flutter/material.dart';

class FullTextButton extends StatelessWidget {
  const FullTextButton(this.callback, this.title, {super.key});

  final Function callback;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: activeTheme.main_color,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: GestureDetector(
        onTap: () async {
          callback();
        },
        child: Text(
          "$title",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: activeTheme.main_bg,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
