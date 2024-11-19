import 'package:eta_school_app/components/header.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/help_message_block.dart';
import 'package:eta_school_app/components/empty_data.dart';
import 'package:eta_school_app/components/loader.dart';

const List<String> list = <String>['Support', 'Human Resources', 'Other'];
// String subject = 'Support';
const List<String> priorities = <String>['Normal', 'High', 'Low'];

class HelpMessagesPage extends StatefulWidget {
  const HelpMessagesPage({super.key});

  @override
  _SentMessageState createState() => _SentMessageState();
}

class _SentMessageState extends State<HelpMessagesPage> {
  final HttpService httpService = HttpService();

  String email = '';
  String message = '';
  String? status;

  String? token;
  String? response;
  String? priority;
  List<HelpMessageModel>? messagesList = [];

  @override
  Widget build(BuildContext context) {
    return showLoader
        ? Loader()
        : Scaffold(
            body: RefreshIndicator(
                onRefresh:
                    _refreshData, // Function to be called on pull-to-refresh
                child: messagesList!.isEmpty
                    ? EmptyData(
                        title: lang.translate('Empty'),
                        text: lang.translate('No data here'),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: activeTheme.main_bg,
                            height: MediaQuery.of(context).size.height,
                            child: SingleChildScrollView(
                                primary: true,
                                child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 110, 10, 10),
                                    color: activeTheme.main_bg,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                width: double.infinity,
                                                color: activeTheme.main_bg,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                child: Row(children: [
                                                  // Container(
                                                  //     child: SvgPicture.asset(
                                                  //         "assets/svg/help.svg",
                                                  //         width: 30,
                                                  //         height: 30,
                                                  //         color: activeTheme
                                                  //             .main_color)),
                                                  // const SizedBox(width: 15),
                                                  // Text(
                                                  //     lang.translate(
                                                  //         'Your help messages'),
                                                  //     style: TextStyle(
                                                  //         fontSize: 22,
                                                  //         color: activeTheme
                                                  //             .main_color,
                                                  //         fontWeight:
                                                  //             FontWeight.w600),
                                                  //     textAlign:
                                                  //         TextAlign.left),
                                                ])),
                                            const SizedBox(height: 20),
                                            for (var i = 0;
                                                i < messagesList!.length;
                                                i++)
                                              (status == null ||
                                                      status ==
                                                          messagesList![i]
                                                              .status)
                                                  ? HelpMessageBlock(
                                                      messagesList![i])
                                                  : const Center()
                                          ],
                                        ),
                                        const SizedBox(height: 48),
                                        const SizedBox(height: 48),
                                      ],
                                    ))),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: Header(lang.translate('sitename'))),
                          // Positioned(
                          //     top: 50,
                          //     left: 0,
                          //     right: 0,
                          //     child: Container(
                          //       width: double.infinity,
                          //       color: activeTheme.main_bg,
                          //       child: Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         mainAxisSize: MainAxisSize.max,
                          //         crossAxisAlignment: CrossAxisAlignment.center,
                          //         children: [
                          //           Expanded(
                          //               child: GestureDetector(
                          //                   onTap: () {
                          //                     setStatus('new');
                          //                   },
                          //                   child: Container(
                          //                       child: Text(
                          //                           lang.translate('New'),
                          //                           textAlign: TextAlign.center,
                          //                           style: status == 'new'
                          //                               ? activeTheme.h5
                          //                               : activeTheme.h6)))),
                          //           Expanded(
                          //               child: GestureDetector(
                          //                   onTap: () {
                          //                     setStatus('completed');
                          //                   },
                          //                   child: Container(
                          //                       child: Text(
                          //                           lang.translate('Completed'),
                          //                           textAlign: TextAlign.center,
                          //                           style: status == 'completed'
                          //                               ? activeTheme.h5
                          //                               : activeTheme.h6)))),
                          //           Expanded(
                          //               child: GestureDetector(
                          //                   onTap: () {
                          //                     setStatus(null);
                          //                   },
                          //                   child: Container(
                          //                       child: Text(
                          //                           lang.translate('All'),
                          //                           textAlign: TextAlign.center,
                          //                           style: status == null
                          //                               ? activeTheme.h5
                          //                               : activeTheme.h6)))),
                          //         ],
                          //       ),
                          //     )),
                          // Positioned(
                          //     top: 0,
                          //     left: 0,
                          //     right: 0,
                          //     child: Header(lang.translate('Help page'))),
                          // Positioned(
                          //     bottom: 20,
                          //     left: 20,
                          //     right: 20,
                          //     child: BottomMenu('help', openPage))
                        ],
                      )));
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  ///
  /// Load devices through API
  ///
  loadMessages() async {
    showLoader = true;

    final messagesList_ = await httpService.getHelpMessages();

    setState(() {
      messagesList = messagesList_;
      showLoader = false;
    });
  }

  /// Change Tabs status
  ///
  setStatus(newStatus) {
    setState(() {
      status = newStatus;
    });
  }

  bool showLoader = true;
  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    setState(() {
      showLoader = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      loadMessages();
    });
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
  }
}
