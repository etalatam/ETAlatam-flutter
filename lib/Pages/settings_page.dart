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
                            Row(
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
                            ),
                            Divider(
                              height: 1,
                              color: theme.dividerColor,
                              indent: 15,
                              endIndent: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            style: theme.textTheme.titleLarge,
                                          ),
                                          Text(
                                              lang.translate(
                                                  'Show template in darkmode'),
                                              style: theme.textTheme.bodyMedium)
                                        ],
                                      ),
                                    )),
                                Switch(
                                    value: themeProvider.isDarkMode,
                                    onChanged: (value) {
                                      themeProvider.setDarkMode(value);
                                    }),
                              ],
                            ),
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