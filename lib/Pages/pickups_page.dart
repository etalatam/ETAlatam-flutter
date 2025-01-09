import 'package:eta_school_app/Models/PickupLocationModel.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/slideable.dart';
import 'package:eta_school_app/components/user_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eta_school_app/components/bottom_menu.dart';

class PickupsPage extends StatefulWidget {
  const PickupsPage(
      {super.key, this.pickup_locations, this.trip_pickup_locations});

  final List<PickupLocationModel>? pickup_locations;
  final List<TripPickupLocation>? trip_pickup_locations;

  @override
  State<PickupsPage> createState() => _PickupsPageState();
}

class _PickupsPageState extends State<PickupsPage> {
  final HttpService httpService = HttpService();

  List<PickupLocationModel>? pickup_locations = [];

  String search_val = '';

  bool showUserModal = false;
  bool showLoader = true;
  PickupLocationModel? activePickup;

  handlePickups(pickups) {
    setState(() {
      /// Handle the pickup locations if is trip
      if (widget.pickup_locations == null || widget.pickup_locations!.isEmpty) {
        for (var i = 0; i < pickups.length; i++) {
          pickup_locations!.add(pickups[i].location);
        }

        /// Handle the pickup locations if is route
      } else {
        pickup_locations = widget.pickup_locations;
      }
      showLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoader
        ? Loader()
        : (Material(
            type: MaterialType.transparency,
            child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                color: activeTheme.main_bg,
                child: Stack(children: [
                  SingleChildScrollView(
                    child: Stack(children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 25),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 30),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "Medians Trips",
                                    style: TextStyle(
                                      color: activeTheme.textColor,
                                      fontSize: 26,
                                      // height: 1,
                                    ),
                                  )),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                                width: double.infinity,
                                child: Row(children: [
                                  Container(
                                      child: SvgPicture.asset(
                                          "assets/svg/fire.svg",
                                          color: activeTheme.main_color)),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    width: 2,
                                    child:
                                        Container(color: activeTheme.textColor),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    lang.translate("Pickup locations"),
                                    style: activeTheme.h4,
                                  )
                                ])),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Text(
                                  lang.translate(
                                      "List of route pickup locations"),
                                  style: activeTheme.largeText,
                                )),
                            Container(
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                height: 54,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                margin: const EdgeInsets.only(top: 20),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFF1F1F3),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.face,
                                      size: 26,
                                      color: activeTheme.icon_color,
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                        width: 1,
                                        child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            color: Colors.black12)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide.none),
                                            filled: true,
                                            hintStyle: TextStyle(
                                                color: Colors.grey[600]),
                                            hintText: lang
                                                .translate('Search by name'),
                                            fillColor: const Color.fromRGBO(
                                                233, 235, 235, .2)),
                                        onChanged: (val) {
                                          setState(() {
                                            search_val = val;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: double.infinity,
                                child: Row(children: [
                                  Container(
                                      child: SvgPicture.asset(
                                    "assets/svg/circles.svg",
                                    width: 28,
                                  )),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    width: 2,
                                    child: Container(color: Colors.black12),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    lang.translate('Route pickup locations'),
                                    style: activeTheme.h5,
                                  )
                                ])),
                          ],
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 320),
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Column(children: [
                            for (var i = 0; i < pickup_locations!.length; i++)
                              !canView(pickup_locations![i])
                                  ? const Center()
                                  : Slideable(
                                      model: pickup_locations![i],
                                      hasLeft: false,
                                      hasRight: true,
                                      widget: Container(
                                        width: double.infinity,
                                        // height: 446.03,
                                        clipBehavior: Clip.antiAlias,
                                        margin: const EdgeInsets.all(10),
                                        decoration: ShapeDecoration(
                                          color: activeTheme.main_bg,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: const BorderSide(
                                                  width: 2,
                                                  color: Colors.black12)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              // height: 110,
                                              padding: const EdgeInsets.all(15),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: const BoxDecoration(),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    decoration:
                                                        const BoxDecoration(),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: (() =>
                                                                      {}),
                                                                  child:
                                                                      Container(
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              60,
                                                                          height:
                                                                              60,
                                                                          decoration:
                                                                              ShapeDecoration(
                                                                            image:
                                                                                DecorationImage(
                                                                              image: NetworkImage((pickup_locations![i].picture!.isNotEmpty) ? (httpService.getImageUrl() + pickup_locations![i].picture!) : "https://via.placeholder.com/51x51"),
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(50),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 15),
                                                                SizedBox(
                                                                  width: 1,
                                                                  child: Container(
                                                                      color: Colors
                                                                          .black12),
                                                                ),
                                                                const SizedBox(
                                                                    width: 15),
                                                                Expanded(
                                                                  child:
                                                                      GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              activePickup = pickup_locations![i];
                                                                              showUserModal = true;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            clipBehavior:
                                                                                Clip.antiAlias,
                                                                            decoration:
                                                                                const BoxDecoration(),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  pickup_locations![i].student_name!,
                                                                                  style: activeTheme.h6,
                                                                                ),
                                                                                const SizedBox(height: 10),
                                                                                SizedBox(
                                                                                  width: double.infinity,
                                                                                  child: Text(
                                                                                    pickup_locations![i].address!,
                                                                                    style: activeTheme.normalText,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration:
                                                              const BoxDecoration(),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      width: 14,
                                                                      height:
                                                                          14,
                                                                      clipBehavior:
                                                                          Clip.antiAlias,
                                                                      decoration:
                                                                          const BoxDecoration(),
                                                                      child: const Stack(
                                                                          children: []),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    GestureDetector(
                                                                        onTap: (() =>
                                                                            {
                                                                              (pickup_locations![i].contact_number).toString().isEmpty ? '' : launchCall(pickup_locations![i].contact_number)
                                                                            }),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .phone,
                                                                          color:
                                                                              activeTheme.main_color,
                                                                        )),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
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
                                          ],
                                        ),
                                      ),
                                      finishCallback: null),
                            const SizedBox(
                              height: 20,
                            ),
                          ])),
                      Container(
                        child: showUserModal
                            ? UserModal(activePickup, switchPopup, false)
                            : const Center(),
                      ),
                    ]),
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Header()),
                  Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: BottomMenu('', openPage))
                ]))));
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  switchPopup(val) {
    setState(() {
      showUserModal = val;
    });
  }

  canView(PickupLocationModel pickupLocation) {
    if (search_val.isEmpty || search_val == '') return true;

    if (pickupLocation.location_name
        .toString()
        .toLowerCase()
        .contains(search_val.toLowerCase())) return true;

    return false;
  }

  @override
  void initState() {
    super.initState();

    handlePickups(widget.trip_pickup_locations);
  }
}
