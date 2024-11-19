import 'package:flutter/material.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';

class CustomRow extends StatelessWidget {
  const CustomRow(this.title, this.value, {super.key});

  final String? title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: isRTL() ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment:
          isRTL() ? MainAxisAlignment.start : MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              textDirection: isRTL() ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title",
                  style: activeTheme.h5,
                ),
              ],
            ),
          ),
        ),
        Text(
          "$value",
          style: activeTheme.h6,
        )
      ],
    );
  }
}
