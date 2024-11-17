import 'package:eta_school_app/Models/StudentModel.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key, this.student});

  final StudentModel? student;

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
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
                      image: NetworkImage((widget.student!.picture != null)
                          ? (httpService.croppedImage(
                              widget.student!.picture!, 800, 1200))
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
                      0.7, // Minimum size of the sheet (10% of the screen)
                  maxChildSize:
                      0.8, // Maximum size of the sheet (80% of the screen)
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                        child: Stack(children: [
                      Container(
                        width: double.infinity,
                        height: 75,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(.5),
                          ],
                        )),
                      ),
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
                            textDirection:
                                isRTL() ? TextDirection.rtl : TextDirection.ltr,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: CircleAvatar(
                                        radius: 50,
                                        foregroundImage: NetworkImage(
                                            (widget.student!.picture != null)
                                                ? (httpService.croppedImage(
                                                    widget.student!.picture!,
                                                    200,
                                                    200))
                                                : httpService.croppedImage(
                                                    "/uploads/images/60x60.png",
                                                    200,
                                                    200)))),
                              ),
                              Column(
                                textDirection: isRTL()
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text("${widget.student!.first_name}",
                                        style: TextStyle(
                                            fontSize: activeTheme.h5.fontSize,
                                            fontWeight:
                                                activeTheme.h4.fontWeight,
                                            color: Colors.white)),
                                  ),
                                  Row(
                                    textDirection: isRTL()
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: activeTheme.buttonBG,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        margin: const EdgeInsets.only(top: 15),
                                        child: Text(
                                            "${lang.translate("${widget.student!.transfer_status}")}",
                                            style: TextStyle(
                                              color: activeTheme.buttonColor,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: activeTheme.buttonBG,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        margin: const EdgeInsets.only(top: 15),
                                        child: Text(
                                            "${widget.student!.route!.route_name}",
                                            style: TextStyle(
                                              color: activeTheme.buttonColor,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const Expanded(child: Center()),
                              // Expanded(child: Icon(Icons.edit, color: activeTheme.icon_color,)),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, right: 20, left: 20),
                                child: Icon(
                                  Icons.edit,
                                  color: activeTheme.icon_color,
                                ),
                              )
                            ],
                          )),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 1,
                            color: activeTheme.main_color.withOpacity(.2),
                          ),
                          MediansWidgets.studentMenuWidget(widget.student),
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