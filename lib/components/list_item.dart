import 'package:flutter/material.dart';
import 'package:MediansSchoolDriver/API/client.dart';

class ListItem extends StatelessWidget {
  
  ListItem(this.index, this.text, this.subText, this.picture,this.callbackPopup, {super.key});

  final HttpService httpService = HttpService();

  final Function callbackPopup;

  final int? index;

  final String? text;

  final String? subText;

  final String? picture;

  @override
  Widget build(BuildContext context) {
    return Expanded(
          child: Container(
            height: 60,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  MainAxisAlignment.start,
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Container(
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center,
                    children: [
                      GestureDetector(
                          child: Container(
                        width: 48,
                        height: 48,
                        decoration:
                            ShapeDecoration(
                          image:
                              DecorationImage(
                            image: NetworkImage((picture!
                                    .isNotEmpty)
                                ? httpService.croppedImage(picture ,0, 0)
                                : httpService.croppedImage("/uploads/images/60x60.png" ,200, 200)),
                            fit: BoxFit.fill,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 2,
                                color: Colors
                                    .deepPurple),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        50),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    callbackPopup(index);
                  },
                  child: Container(
                    clipBehavior:
                        Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          text!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(
                          width:
                              double.infinity,
                          child: subText ==
                                  null
                              ? const Center()
                              : Text(
                                  subText!,
                                  style:
                                      const TextStyle(
                                    color: Color(
                                        0xFF78858F),
                                    fontSize:
                                        16,
                                    fontFamily:
                                        'Roboto',
                                    fontWeight:
                                        FontWeight
                                            .w400,
                                    height: 0,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
  }
}
