import 'package:eta_school_app/Pages/pickups_page.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeRouteBlock extends StatelessWidget {
   HomeRouteBlock({super.key, required this.route, this.callback, this.hasActiveTrip});

  final RouteModel route;
  bool? hasActiveTrip;
  final Function? callback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // width: double.infinity,
          // height: 446.03,
          width: MediaQuery.of(context).size.width / 1.2,
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.all(10),
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
                // height: 235,
                padding: const EdgeInsets.all(20),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 223, 231, 238),
                      Color.fromARGB(255, 246, 237, 248)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
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
                          child: GestureDetector(
                              onTap: (() {
                                // return;
                                //TODO ir a mapa
                                // openNewPage(context,
                                //     RouteMap(route_id: route.route_id!));
                              }),
                              child: Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 100, maxWidth: 290),
                                  child: Text(
                                    route.route_name!,
                                    style: activeTheme.h5,
                                  ))),
                        ),
                        const SizedBox(width: 10),
                        Row(mainAxisSize: MainAxisSize.max, children: [
                          SvgPicture.asset(
                            "assets/svg/bus.svg",
                            // ignore: deprecated_member_use
                            color: activeTheme.main_color,
                            width: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${route.vehicle?.plate_number}",
                            style: activeTheme.h6,
                          )
                        ]),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "${route.description}",
                        style: activeTheme.normalText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                clipBehavior: Clip.antiAlias,
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
                        constraints:
                            const BoxConstraints(minWidth: 100, maxWidth: 150),
                        width: 200,
                        height: 10,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: route.pickup_locations.isEmpty
                            ? const Center()
                            : Stack(children: [
                                for (var i = 0;
                                    i < route.pickup_locations.length && i < 3;
                                    i++)
                                  Positioned(
                                      left: (i * (1 - .4) * 60).toDouble(),
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: (() => {
                                              //TODO
                                              openNewPage(
                                                  context,
                                                  PickupsPage(
                                                    pickup_locations:
                                                        route.pickup_locations,
                                                  ))
                                            }),
                                        child: Container(
                                          width: 51.03,
                                          height: 51.03,
                                          decoration: ShapeDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image:
                                                    // route.pickup_locations[i]
                                                    //                 .picture !=
                                                    //             null &&
                                                    //         route.pickup_locations[i]
                                                    //             .picture!.isNotEmpty
                                                    //     ?
                                                    NetworkImage((route
                                                                .pickup_locations[
                                                                    i]
                                                                .picture !=
                                                            null)
                                                        ? ('${httpService.getImageUrl()}${route.pickup_locations[i].picture}')
                                                        : httpService.croppedImage(
                                                            "/uploads/images/60x60.png",
                                                            200,
                                                            200)) as ImageProvider
                                                // : AssetImage(
                                                //     'assets/logo.png'),
                                                ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              side: BorderSide(
                                                  width: 4,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )),
                                // route.pickup_locations.isEmpty
                                //     ? const Center()
                                //     : GestureDetector(
                                //             onTap: (() => {
                                //                 openNewPage(
                                //                     context,
                                //                     PickupsPage(
                                //                       pickup_locations: route
                                //                           .pickup_locations,
                                //                     ))
                                //             }),
                                //             child: Row(
                                //               children: [
                                //                 Icon(
                                //                   Icons.pin_drop,
                                //                   color: activeTheme.main_color,
                                //                 ),
                                //                 Text(
                                //                   '${route.pickup_locations.length}',
                                //                   style: activeTheme.normalText,
                                //                 ),
                                //               ],
                                //         )),
                              ]),
                      ),
                      GestureDetector(
                          onTap: (hasActiveTrip != null && hasActiveTrip == false) ? () {
                            // return;
                            callback!(route);
                            // openNewPage(context, DriverPage(driver: route.driver, vehicle: route.vehicle,));
                          } : null,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  // color: activeTheme.buttonBG,
                                  color:
                                      (hasActiveTrip != null && hasActiveTrip == false) ?
                                       Color.fromARGB(255, 234,244,243)
                                       :
                                       Color.fromARGB(255, 225, 224, 224),
                                  //     Border.all(width: 1, color: Colors.green),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.route_rounded,
                                    color: (hasActiveTrip != null && hasActiveTrip == false) ?
                                    Color.fromARGB(255,15,148,136):
                                    Colors.grey
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "${lang.translate('Start trip')}",
                                    style: TextStyle(
                                        fontSize: activeTheme.h6.fontSize,
                                        fontFamily: activeTheme.h6.fontFamily,
                                        // color: activeTheme.buttonColor
                                        color: (hasActiveTrip != null && hasActiveTrip == false) ?
                                          Color.fromARGB(255,15,148,136):
                                          Colors.grey
                                        ),
                                  )
                                ],
                              )))
                    ]),
              ),
            ],
          ),
        )
      ],
    );
  }

  handleTrip() {
    // return RouteMap(vehicle: route.driver.vehicle);
  }
}
