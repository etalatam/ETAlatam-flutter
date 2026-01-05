import 'package:eta_school_app/providers/theme_provider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:provider/provider.dart';
import '../components/header.dart';
import '../components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/controllers/preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with ETAWidgets, MediansTheme {
  final HttpService httpService = HttpService();
  final LocalStorage storage = LocalStorage('tokens.json');

  bool allowNotifications = false;
  bool showLoader = true;

  List<String> langs = <String>['Español', 'English'];
  String? selectedLang = 'Español';

  final preferences = PreferencesSetting();

  String appVersion = '1.12.43';
  String buildNumber = '43';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return showLoader
        ? const Loader()
        : Material(
            child: Container(
                width: double.infinity,
                color: theme.scaffoldBackgroundColor,
                child: Stack(children: [
                  SingleChildScrollView(
                      child: Stack(children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(top: 150),
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
                                          style: theme.textTheme.titleLarge),
                                      Text(
                                          lang.translate(
                                              'select your language'),
                                          style: theme.textTheme.bodyMedium)
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: DropdownButton<String>(
                                    value: selectedLang,
                                    icon: Icon(Icons.arrow_downward,
                                        color: theme.iconTheme.color),
                                    elevation: 16,
                                    dropdownColor: theme.scaffoldBackgroundColor,
                                    style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color),
                                    onChanged: (String? value) {
                                      setState(() {
                                        showLoader = true;
                                      });

                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        setState(() {
                                          localeController.changeLocale(Locale(
                                              value == 'Español'
                                                  ? 'es'
                                                  : 'en'));
                                          setLang(value);
                                          showLoader = false;
                                        });
                                      });
                                    },
                                    items: langs.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                              color: theme.textTheme.bodyMedium?.color),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              height: 1,
                              color: theme.dividerColor,
                              indent: 15,
                              endIndent: 10,
                            ),
                           /* Row(
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
                                            style: theme.textTheme.titleLarge),
                                        Text(
                                            lang.translate(
                                                'Allow recieve notifications'),
                                            style: theme.textTheme.bodyMedium)
                                      ],
                                    ),
                                  ),
                                ),
                                Switch(
                                    value: allowNotifications,
                                    onChanged: (value) {
                                      setState(
                                          () => allowNotifications = value);
                                    }),
                              ],
                            ),*/
                            // Sección "Acerca de" - SOLO visible en DEBUG mode
                            if (kDebugMode) ...[
                              Divider(
                                height: 1,
                                color: theme.dividerColor,
                                indent: 15,
                                endIndent: 10,
                              ),
                              Container(
                                margin: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.translate('About'),
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          '${lang.translate('Version')}: ',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          appVersion.isNotEmpty ? appVersion : '...',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '${lang.translate('Build')}: ',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          buildNumber.isNotEmpty ? buildNumber : '...',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.orange,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.bug_report,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'DEBUG MODE',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Comentado temporalmente - Opción de tema oscuro
                            // Divider(
                            //   height: 1,
                            //   color: theme.dividerColor,
                            //   indent: 15,
                            //   endIndent: 10,
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   mainAxisSize: MainAxisSize.max,
                            //   children: [
                            //     Expanded(
                            //         flex: 1,
                            //         child: Container(
                            //           margin: const EdgeInsets.all(20),
                            //           child: Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               Text(
                            //                 lang.translate('Dark mode'),
                            //                 style: theme.textTheme.titleLarge,
                            //               ),
                            //               Text(
                            //                   lang.translate(
                            //                       'Show template in darkmode'),
                            //                   style: theme.textTheme.bodyMedium)
                            //             ],
                            //           ),
                            //         )),
                            //     Switch(
                            //         value: themeProvider.isDarkMode,
                            //         onChanged: (value) {
                            //           themeProvider.setDarkMode(value);
                            //         }),
                            //   ],
                            // ),
                          ],
                        )),
                  ])),
                  Positioned(left: 0, right: 0, top: 0, child: Header()),
                ])));
  }

  @override
  void initState() {
    super.initState();
    getLang().then((value) => selectedLang = value);

    Future.delayed(const Duration(seconds: 1)).then((value) => {
          setState(() {
            showLoader = false;
          })
        });
  }

  Future<String> getLang() async {
    selectedLang = await storage.getItem('lang');
    return selectedLang ?? 'Español';
  }

  setLang(value) async {
    var selectedLang = value!;
    await storage.setItem('lang', selectedLang);
  }
}