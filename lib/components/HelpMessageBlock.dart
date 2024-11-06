import 'package:MediansSchoolDriver/Pages/HelpMessagePage.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:MediansSchoolDriver/Models/HelpMessageModel.dart';
import 'package:flutter/material.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';

class HelpMessageBlock extends StatelessWidget {
  const HelpMessageBlock(this.message, {super.key});

  final HelpMessageModel message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (() => {
              openNewPage(
                  context,
                  HelpMessagePage(
                    message: message,
                  ))
            }),
        child: Container(
          child: Column(children: [
            Container(
              width: double.infinity,
              // height: 446.03,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: activeTheme.main_bg,
                shadows: [
                  BoxShadow(
                    color: activeTheme.shadowColor,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                                    constraints: const BoxConstraints(
                                        minWidth: 100, maxWidth: 290),
                                    child: Row(
                                      children: [
                                        Text(
                                          message.title!,
                                          style: TextStyle(
                                            color: activeTheme.main_color,
                                            fontSize: 14,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            // height: 1,
                                          ),
                                        ),
                                        // Container(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       horizontal: 10, vertical: 3),
                                        //   margin: const EdgeInsets.symmetric(
                                        //       horizontal: 20),
                                        //   decoration: BoxDecoration(
                                        //       border: Border.all(
                                        //           width: 1,
                                        //           color: message.status == 'new'
                                        //               ? Colors.red
                                        //               : activeTheme.main_color),
                                        //       borderRadius:
                                        //           BorderRadius.circular(50)),
                                        //   child: Text(
                                        //     '${message.status}',
                                        //     style: TextStyle(
                                        //         color: message.status == 'new'
                                        //             ? Colors.red
                                        //             : activeTheme.main_color,
                                        //         fontSize: 14,
                                        //         fontWeight: FontWeight.bold),
                                        //   ),
                                        // ),
                                      ],
                                    ))),
                            Container(
                              child: Text(
                                "${message.short_date}",
                                style: activeTheme.smallText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            message.message!,
                            style: activeTheme.h5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    // decoration: BoxDecoration(color: Colors.black12.withOpacity(.1)),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        darkMode == false
                            ? const Color.fromRGBO(249, 250, 254, 1)
                            : const Color.fromRGBO(249, 250, 254, .15),
                      ],
                    )),

                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                              minWidth: 100, maxWidth: 120),
                          height: 51,
                          child: Stack(children: [
                            Positioned(
                              top: 15,
                              child: Row(
                                children: [
                                  Icon(Icons.comment_outlined,
                                      color: activeTheme.main_color),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${message.comments!.length}',
                                    style: activeTheme.h5,
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                              color: activeTheme.buttonBG,
                              border: Border.all(
                                  width: 1, color: activeTheme.main_color),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            '${lang.translate("View details")}',
                            style: TextStyle(
                              color: activeTheme.buttonColor,
                              fontSize: 14,
                              // decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]),
        ));
  }
}
