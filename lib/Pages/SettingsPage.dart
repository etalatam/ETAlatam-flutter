import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:MediansSchoolDriver/Models/DriverModel.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:MediansSchoolDriver/API/client.dart';
import 'package:MediansSchoolDriver/methods.dart';
import '../components/bottom_menu.dart';
import '../components/header.dart';
import '../components/loader.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/components/Widgets.dart';
import 'package:MediansSchoolDriver/controllers/locale.dart';
import 'package:MediansSchoolDriver/controllers/preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with MediansWidgets, MediansTheme {
  final HttpService httpService = HttpService();

  final LocalStorage storage = LocalStorage('tokens.json');

  bool allowNotifications = false;

  bool showLoader = true;

  List<String> list = <String>['Español', 'English'];
  String? subject;

  LocaleController localeController = Get.find<LocaleController>();

  // PreferencesSetting preferences = Get.find<PreferencesSetting>();
  final preferences = PreferencesSetting();

  @override
  Widget build(BuildContext context) {
    activeTheme = darkMode == true ? DarkTheme() : LightTheme();

    return showLoader
        ? const Loader()
        : Material(
            child: Container(
                width: double.infinity,
                color: activeTheme.main_bg,
                child: Stack(children: [
                  SingleChildScrollView(
                      child: Stack(children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(top: 100),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(lang.translate('Language'),
                                          style: activeTheme.h5),
                                      Text(
                                          lang.translate(
                                              'select your language'),
                                          style: activeTheme.normalText)
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: DropdownButton<String>(
                                    value: subject,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 16,
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        showLoader = true;
                                      });

                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        setState(() {
                                          localeController.changeLocale(Locale(
                                              value == 'Arabic' ? 'ar' : 'en'));
                                          subject = value;
                                          storage.setItem('lang', value);
                                          showLoader = false;
                                        });
                                      });
                                    },
                                    items: list.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                              color: Colors.grey[500]),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              height: 1,
                              color: activeTheme.main_color.withOpacity(.3),
                              indent: 15,
                              endIndent: 10,
                            ),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(lang.translate('Notifications'),
                                            style: activeTheme.h5),
                                        Text(
                                            lang.translate(
                                                'Allow recieve notifications'),
                                            style: activeTheme.normalText)
                                      ],
                                    ),
                                  ),
                                ),
                                Switch(
                                    activeColor: activeTheme.main_color,
                                    activeTrackColor:
                                        activeTheme.main_color.withOpacity(.5),
                                    inactiveThumbColor:
                                        Colors.blueGrey.shade500,
                                    inactiveTrackColor: Colors.grey.shade300,
                                    splashRadius: 50.0,
                                    value: allowNotifications,
                                    onChanged: (value) {
                                      setState(
                                          () => allowNotifications = value);

                                      if (!value) {
                                        OneSignal.logout();
                                        OneSignal.Notifications
                                            .removePermissionObserver(
                                                (permission) {});
                                      } else {
                                        setNotes();
                                      }
                                    }),
                              ],
                            ),
                            Divider(
                              height: 1,
                              color: activeTheme.main_color.withOpacity(.3),
                              indent: 15,
                              endIndent: 10,
                            ),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lang.translate('Dark mode'),
                                            style: activeTheme.h5,
                                          ),
                                          Text(
                                              lang.translate(
                                                  'Show template in darkmode'),
                                              style: activeTheme.normalText)
                                        ],
                                      ),
                                    )),
                                Switch(
                                    activeColor: activeTheme.main_color,
                                    activeTrackColor:
                                        activeTheme.main_color.withOpacity(.5),
                                    inactiveThumbColor:
                                        Colors.blueGrey.shade500,
                                    inactiveTrackColor: Colors.grey.shade300,
                                    splashRadius: 50.0,
                                    value: darkMode,
                                    onChanged: (value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        showLoader = true;
                                      });

                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        setState(() {
                                          storage.setItem('darkmode', value);
                                          preferences.setBool(
                                              'darkmode', value);
                                          darkMode = value;
                                          showLoader = false;
                                          activeTheme = value
                                              ? DarkTheme()
                                              : LightTheme();
                                        });
                                      });
                                    }),
                              ],
                            ),
                          ],
                        )),
                  ])),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Header(lang.translate('sitename'))),
                  Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: BottomMenu('settings', openNewPage))
                ])));
  }

  DriverModel? driver;

  loadDriver() async {
    // final driverModel =
    //     await httpService.getDriver(storage.getItem('driver_id'));

    setState(() {
      // driver = driverModel;
      subject = storage.getItem('lang');
      darkMode = storage.getItem('darkmode') ?? false;
      showLoader = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadDriver();
  }
}
