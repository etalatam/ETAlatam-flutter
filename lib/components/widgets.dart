import 'package:eta_school_app/Models/driver_model.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/Pages/event_page.dart';
import 'package:eta_school_app/Pages/help_messages_page.dart';
import 'package:eta_school_app/Pages/parent_page.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/methods.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:eta_school_app/components/image_default.dart';

Widget buttonText(callback, index, text) {
  return Center(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: ShapeDecoration(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: GestureDetector(
            onTap: (() {
              callback(index);
            }),
            child: Text(
              text!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
          )));
}

mixin ETAWidgets {
  static Widget eventCarousel(List<EventModel> events, context) {
    List<Widget> list = [];

    for (var i = 0; i < events.length; i++) {
      list.add(pictureWidget(events[i], context));
    }

    return Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
            // borderRadius: BorderRadius.circular(30),
            ),
        child: events.isEmpty
            ? const Center()
            : CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  onPageChanged: (index, reason) {},
                ),
                items: list,
              ));
  }

  Widget profileInfoBlock(DriverModel parentModel, context) {
    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();

    return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Stack(
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: double.infinity,
                height: 50,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: activeTheme.main_color,
                  borderRadius: BorderRadius.circular(30),
                )),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 5),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: activeTheme.main_bg,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    // height: 110,
                    padding: const EdgeInsets.all(15),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: activeTheme.main_bg),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: (() => {}),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: ShapeDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: parentModel.picture !=
                                                              null &&
                                                          parentModel.picture!
                                                              .isNotEmpty
                                                      ? NetworkImage((parentModel
                                                                      .picture !=
                                                                  null)
                                                              ? ('${httpService.getImageUrl()}${parentModel.picture}')
                                                              : httpService
                                                                  .croppedImage(
                                                                      "/uploads/images/60x60.png",
                                                                      200,
                                                                      200))
                                                          as ImageProvider
                                                      : AssetImage(
                                                          'assets/logo.png'), // AssetImage es un ImageProvider
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${parentModel.name}",
                                              style: activeTheme.h5,
                                            ),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                "${parentModel.contact_number}",
                                                style: activeTheme.normalText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  static Widget settingRow(
      context, Function setLang, Function setMode, Function setNotifications) {
    List<String> list = <String>['Español', 'English'];
    String? subject;
    bool allowNotifications = storage.getItem('allowNotifications');

    return Stack(children: <Widget>[
      Container(
          margin: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.translate('Language'), style: activeTheme.h4),
                        Text(lang.translate('select your language'),
                            style: activeTheme.smallText)
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton<String>(
                      value: subject,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (String? value) {
                        setLang(value);
                      },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
              Divider(
                height: 1,
                color: activeTheme.main_color.withOpacity(.3),
                indent: 15,
                endIndent: 10,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lang.translate('Notifications'),
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(lang.translate('Allow recieve notifications'),
                              style: Theme.of(context).textTheme.bodySmall)
                        ],
                      ),
                    ),
                  ),
                  Switch(
                      activeColor: activeTheme.main_color,
                      activeTrackColor: activeTheme.main_color.withOpacity(.5),
                      inactiveThumbColor: Colors.blueGrey.shade500,
                      inactiveTrackColor: Colors.grey.shade300,
                      splashRadius: 50.0,
                      value: allowNotifications,
                      onChanged: (value) {
                        setNotifications(value);
                      }),
                ],
              ),
              Divider(
                height: 1,
                color: activeTheme.main_color.withOpacity(.3),
                indent: 15,
                endIndent: 10,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.translate('Dark mode'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(lang.translate('Show template in darkmode'),
                                style: Theme.of(context).textTheme.bodySmall)
                          ],
                        ),
                      )),
                  Switch(
                      activeColor: activeTheme.main_color,
                      activeTrackColor: activeTheme.main_color.withOpacity(.5),
                      inactiveThumbColor: Colors.blueGrey.shade500,
                      inactiveTrackColor: Colors.grey.shade300,
                      splashRadius: 50.0,
                      value: darkMode,
                      onChanged: (value) {
                        setMode(value);
                      }),
                ],
              ),
            ],
          )),
    ]);
  }

  static Widget svgTitle(String svgIcon, String title) {
    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();
    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Container(
              child: SvgPicture.asset(svgIcon,
                  width: 30, height: 30, color: activeTheme.main_color)),
          const SizedBox(width: 10),
          Text(
            title,
            style: activeTheme.h5,
          ),
        ]));
  }

  static Widget pictureWidget(EventModel item, context) {
    return GestureDetector(
        onTap: () => {
              Get.to(EventPage(
                event: item,
              ))
            },
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          decoration: ShapeDecoration(
            shadows: [
              BoxShadow(
                color: darkBlueColor.withOpacity(.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                blurStyle: BlurStyle.normal,
              )
            ],
            // image: DecorationImage(
            //   image: NetworkImage((item.. != null)
            //       ? (httpService.croppedImage(item.picture!, 800, 600))
            //       : httpService.croppedImage(
            //           "/uploads/images/60x60.png", 200, 200)),
            //   fit: BoxFit.fill,
            // ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ));
  }

  static Widget homeHelpBlock() {
    return GestureDetector(
      onTap: (() => {Get.to(HelpMessagesPage())}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
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
                      color: const Color(0xFFD1E3FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/help.svg",
                      width: 30,
                      height: 30,
                      color: activeTheme.icon_color,
                    ),
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
                            lang.translate('Have a problem'),
                            style: TextStyle(
                              color: activeTheme.main_bg,
                              fontSize: activeTheme.h6.fontSize,
                              fontFamily: activeTheme.h6.fontFamily,
                              fontWeight: activeTheme.h6.fontWeight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          child: Text(
                            lang.translate('Send message if you need any help'),
                            style: TextStyle(
                              color: activeTheme.main_bg,
                              fontSize: 13,
                              fontFamily: activeTheme.normalText.fontFamily,
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
                      lang.translate('Send message'),
                      style: activeTheme.h6,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  static Widget homeTripBlock(context, TripModel tripInfo) {
    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
          width: MediaQuery.of(context).size.width / 1.2,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(10),
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                      width: 1,
                      color: activeTheme.border_color.withOpacity(.1))),
              color: Colors.white,
              shadows: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                  spreadRadius: 0,
                )
              ]),
          child: Stack(children: [
            // Positioned(
            //   top: -30,
            //   right: 0,
            //   height: 120,
            //   width: 120,
            //   child: SvgPicture.asset("assets/svg/corner-circle.svg"),
            // ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      // gradient: LinearGradient(
                      //   colors: [
                      //     Color.fromARGB(255, 223, 231, 238),
                      //     Color.fromARGB(255, 246, 237, 248)
                      //   ],
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      // ),
                      ),
                  width: double.infinity,
                  // height: 240,
                  padding: const EdgeInsets.all(20),
                  clipBehavior: Clip.antiAlias,
                  //decoration: const BoxDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 190,
                            child: Text(
                              "${lang.translate('Trip')} #${tripInfo.trip_id} ${tripInfo.route?.route_name}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: activeTheme.h6,
                            ),
                          ),
                          Row(children: [
                            SvgPicture.asset("assets/svg/bus.svg",
                                width: 20, color: activeTheme.main_color),
                            SizedBox(width: 10),
                            Text(
                              // tripInfo.busPlate ?? 'Sin información',
                              tripInfo.vehicle?.plate_number ?? '',
                              style: TextStyle(
                                color: activeTheme.main_color,
                              ),
                            )
                          ]),
                        ],
                      ),
                      Text("${tripInfo.formatDate}"),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: tripInfoRow(tripInfo),
                      )
                    ],
                  ),
                ),
                // SizedBox(
                //   width: 20,
                // ),
                // Row(
                //     mainAxisSize: MainAxisSize.max,
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       SizedBox(
                //         width: 10,
                //       ),
                //       Expanded(
                //           child: Container(
                //               constraints:
                //                   BoxConstraints(minWidth: 100, maxWidth: 150),
                //               width: 200,
                //               height: 51,
                //               clipBehavior: Clip.antiAlias,
                //               decoration: BoxDecoration(),
                //               child: Center())),
                // Container(
                //     padding:
                //         EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                //     decoration: BoxDecoration(
                //         color: activeTheme.buttonBG,
                //         border: Border.all(
                //             width: 1, color: activeTheme.border_color),
                //         borderRadius: BorderRadius.circular(10)),
                //     child: Row(
                //       children: [
                //         Icon(
                //           Icons.route_rounded,
                //           color: activeTheme.buttonColor,
                //         ),
                //         SizedBox(
                //           width: 10,
                //         ),
                //         Text(
                //           '${tripInfo.done_locations_count}',
                //           style: TextStyle(color: Colors.white),
                //         ),
                //         SizedBox(
                //           width: 10,
                //         ),
                //         Text(
                //           "${lang.translate('Locations')}",
                //           style: TextStyle(
                //               fontSize: activeTheme.h6.fontSize,
                //               fontFamily: activeTheme.h6.fontFamily,
                //               color: activeTheme.buttonColor),
                //         ),
                //       ],
                //     )),
                // ]),
              ],
            ),
            // Container(
            //   child: ETAWidgets.sectioEndShadow(context),
            // )
          ])),
    );
  }

  // Widget pickupDays()
  static Widget studentMenuWidget(student) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
          width: double.infinity,
          height: 1,
          color: activeTheme.main_color.withOpacity(.3),
        ),
        const SizedBox(
          height: 40,
        ),
        Column(
          textDirection: isRTL() ? TextDirection.rtl : TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.translate('Name'),
              style: activeTheme.h5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Text("${student.first_name} ${student.last_name}",
                      style: activeTheme.h6),
                )
              ],
            )
          ],
        ),
      ]),
    );
  }

  static Widget studentMenuRow(title, subtitle, value) {
    return Row(
      textDirection: isRTL() ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            flex: 1,
            child: Container(
              child: Column(
                crossAxisAlignment:
                    isRTL() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title",
                    style: activeTheme.h5,
                  ),
                  Text("$subtitle", style: activeTheme.normalText)
                ],
              ),
            )),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: isRTL() ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Text("$value",
                style:
                    TextStyle(color: activeTheme.main_color.withOpacity(.5))),
            Icon(
              isRTL()
                  ? Icons.arrow_back_ios_outlined
                  : Icons.arrow_forward_ios_outlined,
              color: activeTheme.main_color.withOpacity(.5),
              size: 16,
            ),
          ],
        ),
      ],
    );
  }

  static Widget tripInfoRow(TripModel trip) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: Color.fromARGB(255, 234, 244, 243),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(64),
                ),
              ),
              child: Icon(Icons.access_time,
                  // color: activeTheme.main_bg,
                  color: Color.fromARGB(255, 15, 148, 136)),
            ),
            Container(
                padding: const EdgeInsets.all(5),
                child: Text(lang.translate('Trip duration'),
                    style: activeTheme.smallText)),
            Text(
              formatTimeWithSeconds(trip.duration.toString()),
              style: activeTheme.h6,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: Color.fromARGB(255, 234, 244, 243),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(64),
                ),
              ),
              child: Icon(
                Icons.route,
                color: Color.fromARGB(255, 15, 148, 136),
              ),
            ),
            Container(
                padding: const EdgeInsets.all(5),
                child: Text(lang.translate('Distance'),
                    style: activeTheme.smallText)),
            Text(
              '${trip.distance} KM',
              style: activeTheme.h6,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: Color.fromARGB(255, 234, 244, 243),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(64),
                ),
              ),
              child: Icon(
                Icons.pin_drop_outlined,
                color: Color.fromARGB(255, 15, 148, 136),
              ),
            ),
            Container(
                padding: const EdgeInsets.all(5),
                child: Text(lang.translate('Pickup locations'),
                    style: activeTheme.smallText)),
            Text("${trip.visitedLocation()}/${trip.done_locations_count.toString()}", style: activeTheme.h6),
            // Text(trip.pickup_locations!.length.toString(),
            //     style: activeTheme.h6),
          ],
        )
      ],
    );
  }

  static String formatTimeWithSeconds(String time) {
    List<String> parts = time.split(':');
    if (parts.length == 3) {
      List<String> secondsParts = parts[2].split('.');
      String secondsFormatted = secondsParts.length > 1
          ? "${secondsParts[0]}.${secondsParts[1].substring(0, 2)}"
          : parts[2];
      return "${parts[0]}:${parts[1]}:$secondsFormatted";
    } else {
      throw FormatException("El formato de tiempo no es válido");
    }
  }

  static Widget sectioEndShadow(context) {
    return Positioned(
      bottom: 0,
      child: SizedBox(
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width / 1,
          padding: const EdgeInsets.all(10),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0),
              Colors.white.withOpacity(.2),
              Color.fromRGBO(200, 200, 200, 0.1).withOpacity(.1),
            ],
          )),
          child: Center(),
        ),
      ),
    );
  }

  static Widget infoMessage(String message) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Color.fromARGB(255, 228, 201, 119),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadows: [
            BoxShadow(
              color: activeTheme.main_color.withOpacity(.3),
              blurRadius: 10,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            )
          ],
        ),
        child: Text(lang.translate(message),
            style: TextStyle(
              color: Color.fromARGB(255, 112, 88, 16),
              fontSize: activeTheme.h5.fontSize,
              fontFamily: activeTheme.h6.fontFamily,
              fontWeight: activeTheme.h6.fontWeight,
            )));
  }

  static Widget homeStudentBlock(context, StudentModel student, {bool hasActiveTrip = false, bool isOnBoard = false}) {
    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();

    return Container(
      width: MediaQuery.of(context).size.width / 1.6,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(children: [
        Container(
            margin: EdgeInsets.only(top: 45),
            width: double.infinity,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: activeTheme.buttonBG,
              borderRadius: BorderRadius.circular(30),
            )),
        SizedBox(
            child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.only(top: 50, bottom: 10),
              width: double.infinity,
              height: double.infinity,
              padding:
                  EdgeInsets.only(top: 60, left: 10, right: 10, bottom: 20),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withOpacity(.15),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                      spreadRadius: 0,
                    )
                  ],
                  color: activeTheme.main_bg,
                  // gradient:  LinearGradient(
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  //   colors: [
                  //     activeTheme.main_bg,

                  //     // activeTheme.main_bg,
                  //     // darkMode == false ? Color.fromRGBO(255, 255, 255, .95) : Color.fromRGBO(201, 206, 223, .95),
                  //     darkMode == true ? activeTheme.main_bg.withOpacity(.2) : Color.fromRGBO(201, 206, 223, 1),
                  //   ],
                  // ),
                  border: Border.all(
                      width: 1,
                      color: activeTheme.border_color.withOpacity(.5)),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text(
                    "${student.first_name} ${student.last_name}",
                    style: activeTheme.h4,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Icon(Icons.arrow_right_alt, color: activeTheme.icon_color,),
                                // Text(lang.translate('View details'), style: activeTheme.h6),
                              ])),
                      // Container(
                      //   transformAlignment: Alignment.center,
                      //   padding: EdgeInsets.symmetric(horizontal: 5),
                      //   decoration: BoxDecoration(
                      //     color: student.transfer_status.toString().toLowerCase() == 'approved' ? activeTheme.main_color : Colors.red,
                      //     borderRadius: BorderRadius.circular(10)
                      //   ),
                      //   child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Icon(Icons.arrow_right_alt, color: activeTheme.buttonColor,),
                      //     Text(lang.translate("${student.transfer_status}"), textAlign: TextAlign.center, style: TextStyle( fontFamily: activeTheme.h6.fontFamily, color: activeTheme.buttonColor,fontSize: activeTheme.h6.fontSize)),
                      //     ]),
                      // ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: hasActiveTrip 
                ? ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 3,
                        color: isOnBoard ? Colors.green : Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  )
                : null,
              child: ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.white,
                  child:Image.network(
                        httpService.getAvatarUrl(student.student_id, 'eta.students'),
                        headers: {'Accept': 'image/png'},
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                           return CircularProgressIndicator();
                        },
                        errorBuilder: (context, error, stackTrace) => 
                          ImageDefault(name: student.first_name ?? "", height: 100, width: 100),
                      )
                ),
              ),
            )
          ],
        ))
      ]),
    );
  }

  static Widget studentTripBlock(context, TripModel tripInfo) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                  width: 1, color: activeTheme.main_color.withOpacity(.2))),
          color: activeTheme.main_bg,
          shadows: [
            BoxShadow(
              color: activeTheme.shadowColor,
              blurRadius: 10,
              offset: Offset(0, 5),
              spreadRadius: 0,
            )
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: (() => {}),
                        child: Text(
                          lang.translate('Trip') +
                              ' # ' +
                              tripInfo.trip_id.toString(),
                          style: activeTheme.h3,
                        )),
                    Text(tripInfo.trip_date!),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: ShapeDecoration(
                                      color: activeTheme.main_color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(64),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.time_to_leave,
                                      color: activeTheme.main_bg,
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                          lang.translate(tripInfo.trip_status!
                                                      .toString()
                                                      .toLowerCase() ==
                                                  'completed'
                                              ? 'Trip duration'
                                              : 'Estimated time'),
                                          style: activeTheme.smallText)),
                                  Text(
                                    tripInfo.duration.toString(),
                                    style: activeTheme.h6,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: ShapeDecoration(
                                      color: activeTheme.main_color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(64),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.merge_type_sharp,
                                      color: activeTheme.main_bg,
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(lang.translate('Distance'),
                                          style: activeTheme.smallText)),
                                  Text(
                                    "${tripInfo.distance.toString()} M",
                                    style: activeTheme.h6,
                                  ),
                                ],
                              ),
                            ]),
                      ],
                    )),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0),
                darkMode == false
                    ? Color.fromRGBO(249, 250, 254, 1)
                    : Color.fromRGBO(249, 250, 254, .15),
              ],
            )),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Stack(children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: 5,
                          right: isRTL() ? 70 : 0,
                          left: isRTL() ? 0 : 70),
                      child: Text(
                        "${tripInfo.driver!.first_name}",
                        style: activeTheme.h5,
                      ),
                    ),
                    Positioned(
                        child: Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.all(5),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color:
                                      activeTheme.border_color.withOpacity(1),
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: CircleAvatar(
                              maxRadius: 40,
                              backgroundColor: Colors.white,
                              foregroundImage: NetworkImage(
                                  (tripInfo.driver!.picture != null)
                                      ? (httpService.croppedImage(
                                          tripInfo.driver!.picture, 200, 200))
                                      : httpService.croppedImage(
                                          "/uploads/images/60x60.png",
                                          200,
                                          200)),
                            ))),
                  ]),
                ),
                const SizedBox(width: 30),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(children: [
                    SvgPicture.asset(
                      "assets/svg/bus.svg",
                      color: activeTheme.main_color,
                      width: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "${tripInfo.vehicle!.plate_number}",
                      style: activeTheme.largeText,
                    )
                  ]),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget parentProfileInfoBlock(ParentModel parentModel, context) {
    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();

    return Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Stack(
          children: [
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 2),
            //   width: double.infinity,
            //   height: 50,
            //   clipBehavior: Clip.antiAlias,
            //   decoration: BoxDecoration(
            //     color: activeTheme.main_color,
            //     borderRadius: BorderRadius.circular(30),
            //   )
            // ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 5),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: activeTheme.main_bg,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: activeTheme.main_bg),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.to(ParentPage());
                          },
                          child: Container(
                            width: double.infinity,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: (() => {}),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: ShapeDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        httpService.croppedImage(
                                                            "/uploads/images/60x60.png",
                                                            200,
                                                            200)),
                                                    fit: BoxFit.fill,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                parentModel.firstName!,
                                                style: activeTheme.h5,
                                              ),
                                              SizedBox(height: 10),
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  parentModel.contactNumber!,
                                                  style: activeTheme.normalText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
