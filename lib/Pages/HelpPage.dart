import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:MediansSchoolDriver/Pages/HelpMessagesPage.dart';
import 'package:MediansSchoolDriver/Models/DriverModel.dart';
import 'package:MediansSchoolDriver/API/client.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:MediansSchoolDriver/components/header.dart';
import 'package:MediansSchoolDriver/components/InfoBlock.dart';
import 'package:MediansSchoolDriver/components/loader.dart';

class SendMessagePage extends StatefulWidget {
  const SendMessagePage({super.key, this.driver});

  final DriverModel? driver;

  @override
  _SentMessageState createState() => _SentMessageState();
}

class _SentMessageState extends State<SendMessagePage> {
  final HttpService httpService = HttpService();

  String email = '';
  String message = '';

  String? token;
  String? response;

  bool showLoader = true;

  List<String> list = <String>[
      'Support', 
      'Problems on the road',
      'Crashed bus',
      'Other'];
  String subject = 'Support';
  List<String> priorities = <String>['Normal', 'High', 'Low'];
  String priority = 'Normal';

  @override
  Widget build(BuildContext context) {
    return showLoader
        ? Loader()
        : Scaffold(
            body: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                  primary: true,
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      color: activeTheme.main_bg,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                            child: const Center(),
                          ),
                          InfoBlock(
                              openHelpMesssagesPage,
                              lang.translate('Your old sent messages list'),
                              lang.translate(
                                  'Click here to view your previous sent messages'),
                              SvgPicture.asset(
                                "assets/svg/check.svg",
                                width: 30,
                                height: 30,
                                color: activeTheme.icon_color,
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.translate("We can help") + "👋",
                                textAlign: TextAlign.center,
                                style: activeTheme.h1,
                              ),
                              const SizedBox(height: 28),
                              Text(
                                lang.translate('send_your_message_below'),
                                style: activeTheme.xlargeText,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          form(),
                          const SizedBox(height: 28),
                          const SizedBox(height: 100),
                        ],
                      ))),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Header(lang.translate('Help page'))),
              // Positioned(
              //     bottom: 20,
              //     left: 20,
              //     right: 20,
              //     child: BottomMenu('help', openPage))
            ],
          ));
  }

  /// Help form widget
  Widget form() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                response == null ? const Center() : Text("$response"),
                Text(
                  lang.translate("Subject"),
                  style: activeTheme.normalText,
                ),
                const SizedBox(height: 8),
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(
                            width: 1, color: const Color.fromRGBO(0, 0, 0, .6)),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      value: subject,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          subject = value!;
                        });
                      },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(lang.translate(value)),
                        );
                      }).toList(),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.translate("Message"),
                  style: activeTheme.normalText,
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: lang.translate('Your message here'),
                      fillColor: const Color.fromRGBO(233, 235, 235, 1)),
                  onChanged: (val) => setState(() {
                    message = val;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.translate("Priority"),
                  style: activeTheme.normalText,
                ),
                const SizedBox(height: 8),
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(
                            width: 1, color: const Color.fromRGBO(0, 0, 0, .6)),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      value: priority,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (String? value) {
                        setState(() {
                          priority = value!;
                        });
                      },
                      items: priorities
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(lang.translate(value)),
                        );
                      }).toList(),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: activeTheme.buttonBG,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: GestureDetector(
              onTap: sendMessage,
              child: Text(
                lang.translate("Send now"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: activeTheme.buttonColor,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  openHelpMesssagesPage() {
    setState(() => openNewPage(context, HelpMessagesPage()));
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  loadPage() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showLoader = false;
    });
  }

  sendMessage() async {
    dynamic res = await httpService.sendMessage(subject, message, priority);
    setState(() {
      showSuccessDialog(context, lang.translate('Done'),
          lang.translate("student_info_updated"), res);
    });
  }

  @override
  void initState() {
    super.initState();
    loadPage();
  }
}
