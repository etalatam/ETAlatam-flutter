import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActiveTrip extends StatelessWidget {
  const ActiveTrip(this.openTripcallback, this.trip, {super.key});

  final TripModel? trip;

  final Function? openTripcallback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {openTripcallback!(trip)},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.fromLTRB(25, 0, 25, 20),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            // color: activeTheme.main_color,
            color: trip?.trip_id == 0
                ? Color.fromARGB(255, 123, 161, 180)
                : Color.fromARGB(255, 59, 140, 135),
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
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 1,
                    left: 3,
                    right: 15,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      "${lang.translate('Trip')} #${trip?.trip_id} (${trip?.route?.route_name})",
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: activeTheme.buttonColor
                                      ),
                                    ),
                                  ),
                                  
                                  Row(children: [
                                    SvgPicture.asset("assets/svg/bus.svg",
                                        width: 15, color: activeTheme.buttonColor),
                                    SizedBox(width: 5),
                                    Text(
                                      trip?.vehicle?.plate_number ?? '',
                                      style: TextStyle(
                                        color: activeTheme.buttonColor,
                                      ),
                                    )
                                  ]),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  textDirection: TextDirection.ltr,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (trip?.trip_id != 0)
                                    Container(
                                      decoration: ShapeDecoration(
                                          //color: activeTheme.main_color,
                                          // color: Colors.amber,
                                          shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      )),
                                      width: 80,
                                      alignment: Alignment.center,
                                      child: Image(
                                          width: 70,
                                          height: 60,
                                          image: AssetImage("assets/moving_car.gif")),
                                    ),
                                    const SizedBox(width: 10),

                                    Icon(
                                      Icons.access_time,
                                      color: activeTheme.buttonColor,
                                      size: 20
                                    ),

                                    Text(
                                      trip?.trip_id == 0
                                          ? ""
                                          : "${trip?.trip_date}",
                                      style: TextStyle(
                                        color: activeTheme.buttonColor
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      Icons.route,
                                      color: activeTheme.buttonColor,
                                      size: 20
                                    ),
                                    Text(
                                      '${trip?.distance} KM',
                                      style: TextStyle(
                                        color: activeTheme.buttonColor
                                      )
                                    ),
                                    const SizedBox(width: 10),
                                    (trip != null &&
                                            trip!.pickup_locations != null) ?
                                    Icon(
                                      Icons.pin_drop_outlined,
                                      color: activeTheme.buttonColor,
                                      size: 20
                                    ) :const Center(),
                                    (trip != null &&
                                            trip!.pickup_locations != null)
                                        ? Text(
                                            '${trip!.pickup_locations!.length.toString()} ',
                                            style: TextStyle(
                                              color: activeTheme.buttonColor
                                            ),
                                          )
                                        : const Center(),
                                  ],
                                ),
                              ),
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
        ));
  }
}
