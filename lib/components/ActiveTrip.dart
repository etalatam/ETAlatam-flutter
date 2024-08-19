import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/Models/TripModel.dart';
import 'package:flutter/material.dart';

class ActiveTrip extends StatelessWidget {
  const ActiveTrip(this.openTrip, this.trip, {super.key});

  final TripModel? trip;

  final Function? openTrip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {openTrip!(trip)},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.fromLTRB(25, 0, 25, 20),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: activeTheme.main_color,
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
              Container(
                decoration: ShapeDecoration(
                    color: activeTheme.main_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                width: 80,
                alignment: Alignment.center,
                child: const Image(
                    width: 80,
                    height: 70,
                    image: AssetImage("assets/moving_car.gif")),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 10,
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
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      lang.translate('Your active trip'),
                                      style: TextStyle(
                                        color: activeTheme.buttonColor,
                                        fontSize: activeTheme.h5.fontSize,
                                        fontFamily: activeTheme.h6.fontFamily,
                                        fontWeight: activeTheme.h6.fontWeight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  textDirection: TextDirection.ltr,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${trip!.trip_date}",
                                      style: TextStyle(
                                        color: activeTheme.buttonColor,
                                        fontSize: activeTheme.h6.fontSize,
                                        fontFamily: activeTheme.h6.fontFamily,
                                        fontWeight: activeTheme.h6.fontWeight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    (trip != null &&
                                            trip!.pickup_locations != null)
                                        ? Text(
                                            '${lang.translate('pickups')} : ${trip!.pickup_locations!.length.toString()} ',
                                            style: TextStyle(
                                              color: activeTheme.buttonColor,
                                              fontSize: activeTheme
                                                  .normalText.fontSize,
                                              fontFamily: activeTheme
                                                  .normalText.fontFamily,
                                              fontWeight: activeTheme
                                                  .normalText.fontWeight,
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
