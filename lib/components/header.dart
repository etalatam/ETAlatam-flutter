// import 'package:eta_school_app/Pages/NotificationsPage.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';

import 'user_avatar_widget.dart';

// import 'package:get/get.dart';

class Header extends StatelessWidget {
  const Header(this.title, {super.key});
  final String? title;

  @override
  Widget build(BuildContext context) {
    return header_2();
  }

  // Basic header
  Widget header_1() {
    return Center(
      widthFactor: 1,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            alignment: FractionalOffset.topCenter,
            image: AssetImage(localeController.selectedLocale.value
                        .toString()
                        .toLowerCase() ==
                    'en'
                ? 'assets/header.png'
                : 'assets/header-ar.png'),
            // fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        child: Row(
          children: [
            const SizedBox(
              width: 50,
            ),
            Expanded(
              flex: 1,
              child: Text(
                "",
                style: TextStyle(
                    fontFamily: activeTheme.h4.fontFamily,
                    color: activeTheme.main_bg,
                    fontSize: activeTheme.h4.fontSize),
              ),
            ),
            const SizedBox(height: 80),
            const Image(
              image: AssetImage("assets/logo.png"),
              width: 120,
              height: 120,
            )
            // TextButton(
            //   style: TextButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(horizontal: 55)),
            //   onPressed: () {
            //     Get.to(NotificationsPage());
            //   },
            //   child: Icon(
            //     Icons.notifications_active,
            //     color: activeTheme.main_bg,
            //     size: 30,
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  // Light Header
  Widget header_2() {
    darkMode = storage.getItem('darkmode') ?? false;

    return Center(
        widthFactor: 1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              // color: darkMode ? activeTheme.main_bg : activeTheme.main_color,
              //borderRadius: BorderRadius.circular(15),
              // gradient: LinearGradient(
              //   colors: [
              //     darkMode ? activeTheme.main_bg : activeTheme.main_color,
              //     //Color.fromARGB(255, 169, 199, 226)
              //     Color.fromARGB(255, 17, 24, 39)
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              // boxShadow: [
              //   BoxShadow(
              //     color: shadowColor,
              //     blurRadius: 10,
              //     offset: const Offset(0, 5),
              //     spreadRadius: 0,
              //   )
              // ],
              ),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
          child: Row(
            children: [
              const Image(
                image: AssetImage("assets/logo.png"),
                width: 60,
                height: 60,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  // "$title",
                  "",
                  style: activeTheme.h4,
                ),
              ),
              UserAvatar() // TextButton(
              //   onPressed: () {
              //     Get.to(NotificationsPage());
              //   },
              //   child: Icon(
              //     Icons.notifications_active,
              //     color: activeTheme.main_color,
              //   ),
              // )
            ],
          ),
        ));
  }

  // Dark Header
  Widget header_3() {
    return Center(
        widthFactor: 1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: activeTheme.main_color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              )
            ],
          ),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
          child: Row(
            children: [
              const Image(
                image: AssetImage("assets/logo.png"),
                width: 60,
                height: 60,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '$title',
                  style: TextStyle(
                      fontFamily: activeTheme.h4.fontFamily,
                      fontSize: activeTheme.h4.fontSize,
                      color: activeTheme.main_bg,
                      fontWeight: activeTheme.h4.fontWeight),
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     Get.to(NotificationsPage());
              //   },
              //   child: Icon(
              //     Icons.notifications_active,
              //     color: activeTheme.main_bg,
              //   ),
              // )
            ],
          ),
        ));
  }
}
