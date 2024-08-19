/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:flutter/material.dart';

class InfoButtonBlock extends StatelessWidget with MediansTheme {
  const InfoButtonBlock(
      this.callback, this.title, this.subtitle, this.btnText, this.icon,
      {super.key});

  final Function callback;
  final String? title;
  final String? subtitle;
  final String? btnText;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (() => {callback()}),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: activeTheme.main_color,
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
                        color: activeTheme.main_bg.withOpacity(.8),
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
                                fontSize: activeTheme.h6.fontSize,
                                fontFamily: activeTheme.h6.fontFamily,
                                fontWeight: activeTheme.h6.fontWeight,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            child: Text(
                              '$subtitle',
                              style: TextStyle(
                                color: activeTheme.main_bg,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                fontFamily: activeTheme.h6.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: activeTheme.main_bg,
                        border: Border.all(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        "$btnText",
                        style: activeTheme.smallText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
