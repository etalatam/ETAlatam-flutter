import 'package:eta_school_app/Models/PickupLocationModel.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/methods.dart';

class UserModal extends StatelessWidget {
  final PickupLocationModel? pickupLocation;

  final Function callback;

  final bool showMapRoute;

  const UserModal(this.pickupLocation, this.callback, this.showMapRoute,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: activeTheme.main_bg.withOpacity(.8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: activeTheme.main_bg,
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
                  onTap: () => {callback(false)},
                  child: Container(
                      child: Container(
                    width: 100,
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: ShapeDecoration(
                      color: activeTheme.main_bg,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(pickupLocation!.picture!
                                          .toString()
                                          .isNotEmpty
                                      ? loadImage(pickupLocation!.picture!)
                                      : "https://via.placeholder.com/130x130"),
                                  fit: BoxFit.fill,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(64),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    pickupLocation!.location_name!,
                                    textAlign: TextAlign.center,
                                    style: activeTheme.h4,
                                  ),
                                  Text(
                                    pickupLocation!.address!,
                                    style: activeTheme.normalText,
                                  ),
                                ],
                              ),
                            ),
                            !showMapRoute
                                ? const Center()
                                : const SizedBox(height: 20),
                            const SizedBox(
                                width: double.infinity, child: Center()),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 10),
                                  Text(
                                    lang.translate('Get in Contact'),
                                    textAlign: TextAlign.center,
                                    style: activeTheme.h6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: !showMapRoute == false
                                      ? MainAxisSize.min
                                      : MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: GestureDetector(
                                          onTap: () => {
                                                launchCall(pickupLocation!
                                                    .contact_number)
                                              },
                                          child: Icon(
                                            Icons.phone,
                                            color: activeTheme.textColor,
                                          )),
                                    ),
                                    const SizedBox(width: 20),
                                    SizedBox(
                                      height: 30,
                                      child: GestureDetector(
                                          onTap: () => {
                                                launchWP(pickupLocation!
                                                    .contact_number)
                                              },
                                          child: Icon(Icons.maps_ugc_outlined,
                                              color: Colors.green[700])),
                                    ),
                                    !showMapRoute
                                        ? const Center()
                                        : const SizedBox(width: 20),
                                    !showMapRoute
                                        ? const Center()
                                        : SizedBox(
                                            height: 30,
                                            child: GestureDetector(
                                                onTap: () => {
                                                      launchGoogleMaps(
                                                          pickupLocation!
                                                              .latitude!,
                                                          pickupLocation!
                                                              .longitude!)
                                                    },
                                                child: Icon(
                                                    Icons.pin_drop_outlined,
                                                    color:
                                                        activeTheme.textColor)),
                                          ),
                                    !showMapRoute
                                        ? const Center()
                                        : Expanded(
                                            child: GestureDetector(
                                                onTap: () => {
                                                      launchGoogleMaps(
                                                          pickupLocation!
                                                              .latitude!,
                                                          pickupLocation!
                                                              .longitude!)
                                                    },
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      lang.translate(
                                                          "Show map"),
                                                      style: TextStyle(
                                                          color: activeTheme
                                                              .textColor),
                                                    ))))
                                  ],
                                ),
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
            onTap: () => {callback(false)},
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
                  Icon(
                    Icons.close,
                    color: activeTheme.icon_color,
                  ),
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
