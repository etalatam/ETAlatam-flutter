import 'package:flutter/material.dart';
import 'package:eta_school_app/controllers/Helpers.dart';

class ButtonTextIcon extends StatelessWidget {
  const ButtonTextIcon(this.text, this.icon, this.bgcolor, {super.key});

  final String? text;

  final Icon? icon;

  final Color? bgcolor;

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
              color: bgcolor ?? activeTheme.main_color,
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
                // SizedBox(
                //   height: 15,
                //   width: 2,
                //   child: Container(color: const Color.fromARGB(255, 252, 252, 252)),
                // ),
                // const SizedBox(
                //   width: 10,
                // ),
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
