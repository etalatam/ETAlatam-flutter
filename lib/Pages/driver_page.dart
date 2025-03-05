import 'package:eta_school_app/Models/driver_model.dart';
import 'package:eta_school_app/Models/VehicleModel.dart';
import 'package:eta_school_app/methods.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key, this.driver, this.vehicle});

  final DriverModel? driver;
  final VehicleModel? vehicle;

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  bool showLoader = true;

  VehicleModel? vehicle;

  @override
  Widget build(BuildContext context) {
    final driver = widget.driver!;
    vehicle = widget.vehicle;

    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          (driver.driver_id != null)
                              ? (httpService.croppedImage(
                                  driver.picture, 800, 1200))
                              : httpService.croppedImage(
                                  "/avatars/person.svg", 200, 200),
                          headers: {"acept": "image/png"}),
                      fit: BoxFit.fitHeight,
                    ),
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize:
                      .6, // The initial size of the sheet (0.2 means 20% of the screen)
                  minChildSize:
                      0.6, // Minimum size of the sheet (10% of the screen)
                  maxChildSize:
                      0.7, // Maximum size of the sheet (80% of the screen)
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                        child: Stack(children: [
                      // Container(
                      //   width: double.infinity,
                      //   height: 75,
                      //   clipBehavior: Clip.antiAlias,
                      //   decoration: BoxDecoration(
                      //       gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       Colors.black.withOpacity(0),
                      //       Colors.black.withOpacity(.5),
                      //     ],
                      //   )),
                      // ),
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: activeTheme.main_bg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0.0, -3.0),
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        controller: scrollController,
                        child: Container(
                            child: Stack(children: [
                          Container(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor:
                                          Color.fromARGB(255, 234, 244, 243),
                                      foregroundImage: NetworkImage(
                                          (driver.picture != null)
                                              ? (httpService.croppedImage(
                                                  driver.picture!, 200, 200))
                                              : httpService.croppedImage(
                                                  "/uploads/images/60x60.png",
                                                  200,
                                                  200)))),
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text("${driver.first_name}",
                                        style: TextStyle(
                                            fontSize: activeTheme.h5.fontSize,
                                            fontWeight:
                                                activeTheme.h4.fontWeight,
                                            color: Colors.white)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: activeTheme.buttonBG,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    margin: const EdgeInsets.only(top: 15),
                                    child:
                                        Text("${driver.driver_license_number}",
                                            style: TextStyle(
                                              color: activeTheme.buttonColor,
                                              fontWeight: FontWeight.bold,
                                            )),
                                  ),
                                ],
                              ),
                              const Expanded(child: Center()),
                              // Expanded(child: Icon(Icons.edit, color: activeTheme.icon_color,)),
                              Column(
                                children: [
                                  const SizedBox(height: 50),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            launchCall(driver.contact_number);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, right: 20, left: 20),
                                            child: Icon(
                                              Icons.call,
                                              color: activeTheme.icon_color,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            launchWP(driver.contact_number);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, right: 20, left: 20),
                                            child: Icon(
                                              Icons.maps_ugc_outlined,
                                              color: activeTheme.icon_color,
                                            ),
                                          ),
                                        ),
                                        // Padding(padding: EdgeInsets.only(top: 10, right: 20, left: 20), child: Icon(Icons., color: activeTheme.icon_color,),)
                                      ])
                                ],
                              )
                            ],
                          )),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 1,
                            color: activeTheme.main_color.withOpacity(.2),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 120),
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: storage
                                          .getItem('lang')
                                          .toString()
                                          .toLowerCase() ==
                                      'español'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${driver.name}",
                                      style: activeTheme.h4,
                                    ),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/svg/bus.svg",
                                          color: activeTheme.main_color,
                                          width: 20,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text("${vehicle!.plate_number}",
                                            style: activeTheme.h6),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          )
                        ])),
                      )
                    ]));
                  },
                ),
              ]),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    showLoader = false;
  }
}
