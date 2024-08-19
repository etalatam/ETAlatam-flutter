import 'package:flutter/material.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';

class ButtonTextIcon extends StatelessWidget {
  const ButtonTextIcon(this.text, this.icon, {super.key});

  final String? text;

  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: ShapeDecoration(
              color: activeTheme.main_color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(child: icon),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 15,
                  width: 2,
                  child: Container(color: Colors.blueGrey),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: activeTheme.main_bg,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
