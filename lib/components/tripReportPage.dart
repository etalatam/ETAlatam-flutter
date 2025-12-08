import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Pages/driver_home.dart';
import 'package:eta_school_app/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripReport extends StatefulWidget {
  const TripReport({super.key, required this.trip});

  final TripModel? trip;
  @override
  _TripReport createState() => _TripReport();
}

class _TripReport extends State<TripReport> {
  TripModel? trip;

  bool showMapRoute = false;

  HttpService httpService = HttpService();

  getTrip() async {
    final currentTrip =
        await httpService.getTrip(widget.trip!.trip_id.toString());

    setState(() {
      trip = currentTrip;
    });
  }

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    getTrip();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
      color: activeTheme.main_color.withOpacity(.8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              shadows: const [
                BoxShadow(
                  color: Color(0x1E000000),
                  blurRadius: 18,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x23000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                  spreadRadius: -1,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => {
                    setState(() {
                      Navigator.pop(context);
                    })
                  },
                  child: Container(
                      child: Container(
                    width: 150,
                    height: 100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.close),
                        const SizedBox(width: 10),
                        Text(lang.translate("close"))
                      ],
                    ),
                  )),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: ShapeDecoration(
                                color: Colors.green.withOpacity(.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(130),
                                ),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 80,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    lang.translate('Trip number') +
                                        ' #' +
                                        trip!.trip_id.toString(),
                                    style: TextStyle(
                                      color: Colors.black
                                          .withOpacity(0.8),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(
                                      //   '${lang.translate('Trip status')} ${lang.translate(trip!.trip_status!)}',
                                      //   style: TextStyle(
                                      //     color: Colors.green
                                      //         .withOpacity(0.6000000238418579),
                                      //     fontSize: 16,
                                      //     fontFamily: 'Heebo',
                                      //     fontWeight: FontWeight.w400,
                                      //     height: 0,
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            !showMapRoute
                                ? const Center()
                                : const SizedBox(height: 20),
                            const SizedBox(
                                width: double.infinity, child: Center()
                                // Text(
                                //   !showMapRoute ? '' :  lang.translate('Distance to pickup location')+pickupLocation!.distance.toString() +' KM',
                                //   textAlign: TextAlign.center,
                                //   style: TextStyle(
                                //     color: Colors.black.withOpacity(0.8700000047683716),
                                //     fontSize: 20,
                                //     fontWeight: FontWeight.w400,
                                //   ),
                                // ),
                                ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 10),
                                  Text(
                                    lang.translate('Sueccessfully ended'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.green
                                          .withOpacity(0.8700000047683716),
                                      fontSize: 22,
                                      fontFamily: 'Heebo',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: ShapeDecoration(
                                          color: activeTheme.buttonBG,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.time_to_leave,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                              lang.translate('Trip duration'))),
                                      Text(
                                        Utils.formatElapsedTime(trip!.dt!),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: ShapeDecoration(
                                          color: activeTheme.buttonBG,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.route,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(5),
                                          child:
                                              Text(lang.translate('Distance'))),
                                      // Text(
                                      //   '${trip!.distance} KM',
                                      //   style: const TextStyle(
                                      //       fontSize: 16,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      Text(
                                        ((trip!.distance ?? 0) >= 1000)
                                            ? '${((trip!.distance ?? 0) / 1000).toStringAsFixed(2)} KM'
                                            : '${(trip!.distance ?? 0).toStringAsFixed(2)} m',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: ShapeDecoration(
                                          color: activeTheme.buttonBG,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.pin_drop,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(lang
                                              .translate('Pickup locations'))),
                                      if(trip!.pickup_locations != null)
                                      Text(
                                        "${trip!.visitedLocation()}/${trip!.pickup_locations!.length
                                            .toString()}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ],
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
          ),
          GestureDetector(
            onTap: () => {Get.offAll(DriverHome())},
            child: Container(
                child: Container(
              width: 100,
              height: 40,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.close),
                  const SizedBox(width: 10),
                  Text(lang.translate("close"))
                ],
              ),
            )),
          )
        ],
      ),
    );
  }
}
