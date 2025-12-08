import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'marquee_text.dart';

class ActiveTrip extends StatefulWidget {
  const ActiveTrip(this.openTripCallback, this.trip, {super.key});

  final TripModel? trip;

  final Function? openTripCallback;

  @override
  State<ActiveTrip> createState() => _ActiveTripState();
}

class _ActiveTripState extends State<ActiveTrip> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Actualizar cada segundo para viajes activos (para mostrar segundos)
    if (widget.trip?.trip_status == 'Running') {
      _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            // Trigger rebuild to update duration and other dynamic data
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // return Consumer<EmitterService>(builder:(context, emitterService, child) {
      return GestureDetector(
          onTap: () => {widget.openTripCallback!(widget.trip)},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.fromLTRB(25, 0, 25, 20),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              // color: activeTheme.main_color,
              color: widget.trip?.trip_id == 0
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return MarqueeText(
                                            text: "${lang.translate('Trip')} #${widget.trip?.trip_id} ${widget.trip?.route?.route_name ?? ''}",
                                            width: constraints.maxWidth - 80, // Ajustar según el espacio disponible menos el icono y placa
                                            style: TextStyle(
                                                color: activeTheme.buttonColor),
                                            autoStart: true,
                                            velocity: 60.0, // Velocidad de desplazamiento
                                            pauseAfterRound: Duration(seconds: 2), // Pausa después de cada ciclo
                                            blankSpace: 80.0, // Espacio entre repeticiones del texto
                                          );
                                        },
                                      ),
                                    ),
                                    Row(children: [
                                      SvgPicture.asset("assets/svg/bus.svg",
                                          width: 15,
                                          color: activeTheme.buttonColor),
                                      SizedBox(width: 5),
                                      Text(
                                        widget.trip?.vehicle?.plate_number ?? '',
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
                                      Icon(Icons.access_time,
                                          color: activeTheme.buttonColor,
                                          size: 20),
                                      Text(
                                        widget.trip?.trip_id == 0
                                            ? ""
                                            : "${widget.trip?.runningTripDuration()}",
                                        style: TextStyle(
                                            color: activeTheme.buttonColor),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(Icons.route,
                                          color: activeTheme.buttonColor,
                                          size: 20),
                                      // Text('${widget.trip?.distance} KM',
                                      //     style: TextStyle(
                                      //         color: activeTheme.buttonColor)),
                                      Text(
                                        ((widget.trip?.distance ?? 0) >= 1000)
                                            ? '${((widget.trip?.distance ?? 0) / 1000).toStringAsFixed(2)} KM'
                                            : '${(widget.trip?.distance ?? 0).toStringAsFixed(2)} m',
                                        style: TextStyle(
                                            color: activeTheme.buttonColor),
                                      ),
                                      const SizedBox(width: 10),
                                      (widget.trip != null &&
                                              widget.trip!.pickup_locations != null)
                                          ? Icon(Icons.pin_drop_outlined,
                                              color: activeTheme.buttonColor,
                                              size: 20)
                                          : const Center(),
                                      (widget.trip != null &&
                                              widget.trip!.pickup_locations != null)
                                          ? Text(
                                              '${widget.trip!.visitedLocation()}/${widget.trip!.pickup_locations!.length.toString()} ',
                                              style: TextStyle(
                                                  color: activeTheme.buttonColor),
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
    // });
  }
}
