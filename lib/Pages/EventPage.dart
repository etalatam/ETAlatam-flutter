import 'package:MediansSchoolDriver/Models/EventModel.dart';
import 'package:flutter/material.dart';
import 'package:MediansSchoolDriver/components/loader.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key, this.event});

  final EventModel? event;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool showLoader = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                Container(
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage((widget.event!.picture != null)
                          ? (httpService.croppedImage(
                              widget.event!.picture!, 800, 1200))
                          : httpService.croppedImage(
                              "/uploads/images/60x60.png", 200, 200)),
                      fit: BoxFit.fitHeight,
                    ),
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize:
                      .7, // The initial size of the sheet (0.2 means 20% of the screen)
                  minChildSize:
                      0.1, // Minimum size of the sheet (10% of the screen)
                  maxChildSize:
                      0.9, // Maximum size of the sheet (80% of the screen)
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
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
                        child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            flex: 10,
                                            child: Text(
                                                "${widget.event!.title}",
                                                textAlign: TextAlign.left,
                                                style: activeTheme.h3)),
                                        Expanded(
                                            child: Icon(
                                          Icons.event,
                                          color: activeTheme.icon_color,
                                        ))
                                      ],
                                    )),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.2),
                                ),
                                Center(
                                  child: Image(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      image: NetworkImage(
                                          (widget.event!.picture != null)
                                              ? (httpService.croppedImage(
                                                  widget.event!.picture!,
                                                  800,
                                                  0))
                                              : httpService.croppedImage(
                                                  "/uploads/images/60x60.png",
                                                  200,
                                                  200))),
                                ),
                                Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Text("${widget.event!.description}",
                                        textAlign: TextAlign.left,
                                        style: activeTheme.largeText)),
                              ],
                            )));
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
