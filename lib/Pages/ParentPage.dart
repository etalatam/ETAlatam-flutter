import 'package:eta_school_app/Models/ParentModel.dart';
import 'package:eta_school_app/Pages/ChangePasswordPage.dart';
import 'package:eta_school_app/methods.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/CustomRow.dart';
import 'package:eta_school_app/controllers/Helpers.dart';

class ParentPage extends StatefulWidget {
  const ParentPage({super.key, this.parent});

  final ParentModel? parent;

  @override
  State<ParentPage> createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {
  bool showLoader = true;

  ParentModel parent = ParentModel(parent_id: 0, students: []);

  final String profilePicture = "${apiURL}uploads/images/parent.gif";

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage(profilePicture),
                      fit: BoxFit.fitHeight,
                    ),
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize: .7,
                  minChildSize: 0.7,
                  maxChildSize: 0.8,
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
                                  textDirection: isRTL()
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: CircleAvatar(
                                        radius: 50,
                                        foregroundImage: NetworkImage(
                                            httpService.croppedImage(
                                                "/uploads/images/60x60.png",
                                                200,
                                                200)))),
                                Column(
                                  textDirection: isRTL()
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Text("${parent.first_name}",
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
                                      child: Text("${parent.email}",
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
                                              launchCall(parent.contact_number);
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
                                              launchWP(parent.contact_number);
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
                              ])),
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
                              crossAxisAlignment: isRTL()
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                CustomRow(lang.translate('First Name'),
                                    parent.first_name),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                CustomRow(lang.translate('last Name'),
                                    parent.last_name),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                CustomRow(
                                    lang.translate('email'), parent.email),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                CustomRow(lang.translate('Contact number'),
                                    parent.contact_number),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      openNewPage(
                                          context, ChangePasswordPage());
                                    },
                                    child: CustomRow(
                                        lang.translate('Change password'), '')),
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

  ///
  /// Load devices through API
  ///
  loadParent() async {
    final parentId = widget.parent != null ? widget.parent!.parent_id : 0;
    final parentQuery = await httpService.getParent(parentId);
    setState(() {
      parent = parentQuery;
      showLoader = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadParent();
  }
}
