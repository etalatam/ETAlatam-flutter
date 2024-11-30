import 'dart:async';
import 'package:eta_school_app/Pages/driver_home.dart';
import 'package:eta_school_app/methods.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/controllers/locale.dart';
import 'package:eta_school_app/controllers/preferences.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

bool darkmode = false;
bool showLoader = true;

List<String> list = <String>['Español', 'English'];
String selectedLang = 'Español';

bool _havePermissions = false;

final PageController _controller = PageController();

class GetStartedApp extends StatefulWidget {
  const GetStartedApp({super.key});
  @override
  State<GetStartedApp> createState() => _GetStartedAppState();
}

class _GetStartedAppState extends State<GetStartedApp> {
  // List of widgets representing each slide
  List<Widget> _slides = [];

  @override
  Widget build(BuildContext context) {
    return Material(
        color: activeTheme.main_color,
        type: MaterialType.transparency,
        child: Stack(children: [
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: showLoader == true
                      ? Loader()
                      : PageView(
                          pageSnapping: true,
                          controller: _controller,
                          children: _slides,
                          onPageChanged: (value) {},
                        ),
                ),
              ))
        ]));
  }

  @override
  void initState() {
    super.initState(); // This calls the overridden method in the superclass.
    // Your custom code here
    handle();

    setState(() {
      _slides = [
        SlidePage(
            lang.translate('App Preferences'),
            lang.translate('Set your custom configuration'),
            const Color.fromRGBO(76, 229, 177, 1),
            'assets/slides/slide1.png',
            1,
            setMode,
            setLang),
        SlidePage(
            lang.translate('Get permissions'),
            lang.translate('Some permissions are required to use the APP'),
            const Color.fromRGBO(252, 73, 116, 1),
            'assets/slides/slide2.png',
            2,
            setMode,
            setLang),
        SlidePage(
            lang.translate('Start now'),
            lang.translate('Start with your account'),
            const Color.fromARGB(255, 117, 76, 175),
            'assets/slides/slide3.png',
            3,
            setMode,
            setLang),
      ];
    });
  }

  @override
  void dispose() {
    // Your custom code here
    super.dispose(); // This calls the overridden method in the superclass.
  }

  handle() async {
    final started = await preferences.getBool('started');

    if (started == true) {
      return Get.to(DriverHome());
    }

    String? sessionLang = await storage.getItem('lang');
    String? token = await storage.getItem('token');

    Timer(const Duration(seconds: 1), () async {
      sessionLang = storage.getItem('lang');
      token = storage.getItem('token');

      if (token != null) {
        // Get.offAll(() => MapView());
      } else if (sessionLang != null) {
        Get.offAll(() => Login());
      }

      if (_havePermissions) {
        _controller.nextPage(
          duration: const Duration(
              milliseconds: 500), // You can specify the animation duration
          curve: Curves.ease,
        );
      }
      Timer(const Duration(seconds: 1), () async {
        setState(() {
          showLoader = false;
        });
      });
    });
  }

  setLang(value) async {
    selectedLang = value!;
    localeController
        .changeLocale(Locale(selectedLang == 'Español' ? 'es' : 'en'));
    await storage.setItem('lang', selectedLang);
  }

  setMode(value) async {
    darkmode = value;
    storage.setItem('darkmode', darkmode);
    preferences.setBool('darkmode', darkmode);
    setState(() {});
  }
}

// class SlidePage extends StatefulWidget {

//   final String title;
//   final String text;
//   final Color color;
//   final String image;
//   int step;

//   SlidePage(this.title,this.text, this.color, this.image, this.step);
//   @override
//   _SlidePageState createState() => _SlidePageState();
// }

// class _SlidePageState extends State<SlidePage> {
class SlidePage extends StatelessWidget {
  SlidePage(this.title, this.text, this.color, this.image, this.step,
      this.setMode, this.setLang,
      {super.key});

  final String title;
  final String text;
  final Color color;
  final String image;
  final int step;
  final Function setMode;
  final Function setLang;

  final LocaleController localeController = Get.find<LocaleController>();
  final preferences = PreferencesSetting();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: MediaQuery.of(context).size.height,
      child: Center(
          child: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 120),
          width: 180,
          height: 180,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.fill,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(64),
            ),
          ),
        ),
        const SizedBox(height: 50),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w400))),
        const SizedBox(height: 50),
        step == 1 ? settingSlide(context) : const Center(),
        step == 2 ? permissionsSlide(context) : const Center(),
        step == 3 ? accountSlide(context) : const Center(),
      ])),
    );
  }

  Widget accountSlide(context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
      child: Column(
        children: [
          GestureDetector(
              onTap: () async {
                preferences.setBool('started', true);
                openNewPage(context, Login());
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xff1e3050),
                ),
                child: Text(
                  lang.translate('sign in'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 0.20,
                  ),
                ),
              )),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Future<bool> _checkLocationPermission() async {
    await permissions.Permission.location.request();
    final permission = await permissions.Permission.locationAlways.request();
    await permissions.Permission.notification.request();

    if (permission == permissions.PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  Widget permissionsSlide(context) {
    return Container(
        color: color,
        child: Center(
            child: GestureDetector(
          onTap: (() async {
            _havePermissions = await _checkLocationPermission();
            _controller.nextPage(
              duration: const Duration(
                  milliseconds: 500), // You can specify the animation duration
              curve: Curves.ease,
            );
          }),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(lang.translate("Get permission"),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
        )));
  }

  Widget settingSlide(context) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          children: [
            Divider(
              height: 1,
              color: activeTheme.main_color.withOpacity(.3),
              indent: 15,
              endIndent: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.translate('Language'),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      Text(
                        lang.translate('select your language'),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButton<String>(
                    value: selectedLang,
                    icon: const Icon(Icons.arrow_downward),
                    
                    elevation: 16,
                    onChanged: (String? value) {
                      setLang(value);
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black45),
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
            // Row(
            //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   mainAxisSize: MainAxisSize.max,
            //   children: [
            //     Expanded(
            //         flex: 1,
            //         child: Container(
            //           margin: const EdgeInsets.all(20),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 lang.translate('Dark mode'),
            //                 style: const TextStyle(
            //                     color: Colors.white, fontSize: 24),
            //               ),
            //               Text(
            //                 lang.translate('Show template in darkmode'),
            //                 style: const TextStyle(
            //                     color: Colors.white, fontSize: 18),
            //               ),
            //             ],
            //           ),
            //         )),
            //     Switch(
            //         activeColor: activeTheme.main_color,
            //         activeTrackColor: activeTheme.main_color.withOpacity(.5),
            //         inactiveThumbColor: Colors.blueGrey.shade500,
            //         inactiveTrackColor: Colors.grey.shade300,
            //         splashRadius: 50.0,
            //         value: darkmode,
            //         onChanged: (value) {
            //           setMode(value);
            //         }),
            //   ],
            // ),
            Container(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                    child: GestureDetector(
                  onTap: (() async {
                    _controller.nextPage(
                      duration: const Duration(
                          milliseconds:
                              500), // You can specify the animation duration
                      curve: Curves.ease,
                    );
                  }),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(lang.translate("Next"),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                )))
          ],
        ),
      ),
    );
  }
}
