import 'package:eta_school_app/Pages/settings_page.dart';
import 'package:eta_school_app/Pages/help_page.dart';
import 'package:eta_school_app/methods.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/controllers/helpers.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu(this.active_menu_prefix, this.callback, {super.key});

  final Function callback;

  final String? active_menu_prefix;

  bool checkTrue(item) {
    return active_menu_prefix == item ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    List<MenuModel> menu = [
      MenuModel(
          iconData: Icons.settings_outlined,
          active: checkTrue('settings'),
          page: SettingsPage()),
      // MenuModel(
      //     iconData: Icons.face_sharp,
      //     active: checkTrue('profile'),
      //     page: ProfilePage()),
      // MenuModel(
      //     iconData: Icons.home, active: checkTrue('home'), page: HomePage()),
      // MenuModel(
      //     iconData: Icons.map_rounded,
      //     active: checkTrue('home'),
      //     page: MapView()),
      // MenuModel(
      //     iconData: Icons.notifications_on_outlined,
      //     active: checkTrue('notifications'),
      //     page: NotificationsPage()),
      MenuModel(
          iconData: Icons.help_outline,
          active: checkTrue('help'),
          page: SendMessagePage()),
    ];

    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();
    return Center(
        child: Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 10, left: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: activeTheme.main_bg,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 8),
              blurStyle: BlurStyle.normal,
            )
          ]
          // color: Colors.white
          ),
      child: Row(
        textDirection: isRTL() ? TextDirection.rtl : TextDirection.ltr,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < menu.length; i++)
            TextButton(
                onPressed: (() {
                  callback(context, menu[i].page);
                }),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: ShapeDecoration(
                    color: menu[i].active!
                        ? activeTheme.main_color
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(menu[i].iconData,
                          color: menu[i].active!
                              ? activeTheme.main_bg
                              : activeTheme.main_color),
                    ],
                  ),
                )),
        ],
      ),
    ));
  }
}

class IconWidget extends StatelessWidget {
  final IconData icon;
  const IconWidget(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: activeTheme.main_color,
    );
  }
}

class MenuModel {
  IconData? iconData;
  bool? active;
  dynamic page;

  MenuModel({this.iconData, this.active, this.page});
}
