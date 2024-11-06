import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:flutter/material.dart';

class InfoBlock extends StatelessWidget {
  const InfoBlock(this.callback, this.title, this.subtitle, this.icon,
      {super.key});

  final Function callback;
  final String? title;
  final String? subtitle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (() => {callback()}),
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 15, 0, 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              // color: activeTheme.main_color,
              color: Color.fromARGB(255, 59, 140, 135),
              border: Border.all(width: 2, color: Colors.black12)),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    flex: 0,
                    child: Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(8),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD1E3FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: icon!,
                    )),
                const SizedBox(width: 10),
                Expanded(
                    flex: 2,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 10, maxWidth: 180),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              "$title",
                              style: TextStyle(
                                color: activeTheme.main_bg,
                                fontSize: activeTheme.h5.fontSize,
                                fontFamily: activeTheme.h5.fontFamily,
                                fontWeight: activeTheme.h5.fontWeight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            child: Text(
                              '$subtitle',
                              style: TextStyle(
                                color: activeTheme.main_bg,
                                fontFamily: activeTheme.normalText.fontFamily,
                                fontSize: activeTheme.normalText.fontSize,
                                fontWeight: activeTheme.normalText.fontWeight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ));
  }
}
