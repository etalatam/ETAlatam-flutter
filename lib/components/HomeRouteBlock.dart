import 'package:MediansSchoolDriver/Pages/PickupsPage.dart';
import 'package:MediansSchoolDriver/Pages/RouteMapPage.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/Models/RouteModel.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeRouteBlock extends StatelessWidget {
  const HomeRouteBlock({super.key, required this.route, this.callback});

  final RouteModel route;
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
                decoration: const BoxDecoration(),
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
                                openNewPage(context,
                                    RouteMap(route_id: route.route_id!));
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
                            "${route.busPlate}",
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
                        height: 51,
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
                                        onTap:  (() => {
                                                  //TODO
                                                  openNewPage(
                                                      context,
                                                      PickupsPage(
                                                        pickup_locations: route
                                                            .pickup_locations,
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
                                              side:  BorderSide(
                                                  width: 4,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )),
                                route.pickup_locations.isEmpty
                                    ? const Center()
                                    : Positioned(
                                        right: 0,
                                        top: 15,
                                        child: GestureDetector(
                                            // onTap: (() => {
                                            //   //TODO
                                            //   openNewPage(
                                            //       openNewPage(
                                            //           context,
                                            //           PickupsPage(
                                            //             pickup_locations: route
                                            //                 .pickup_locations,
                                            //           ))
                                            //     }),
                                            child: Row(
                                          children: [
                                            Icon(
                                              Icons.pin_drop,
                                              color: activeTheme.main_color,
                                            ),
                                            Text(
                                              '${route.pickup_locations.length}',
                                              style: activeTheme.normalText,
                                            ),
                                          ],
                                        )),
                                      ),
                              ]),
                      ),
                      GestureDetector(
                          onTap: () {
                            // return;
                            //TODO
                            callback!(
                                route.route_id, route.vehicle!.vehicle_id);
                            // openNewPage(context, DriverPage(driver: route.driver, vehicle: route.vehicle,));
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: activeTheme.buttonBG,
                                  border: Border.all(
                                      width: 1, color: activeTheme.main_color),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.route_rounded,
                                    color: activeTheme.buttonColor,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "${lang.translate('Start trip')}",
                                    style: TextStyle(
                                        fontSize: activeTheme.h6.fontSize,
                                        fontFamily: activeTheme.h6.fontFamily,
                                        color: activeTheme.buttonColor),
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
