import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:MediansSchoolDriver/Models/HelpMessageModel.dart';
import 'package:MediansSchoolDriver/API/client.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:MediansSchoolDriver/components/bottom_menu.dart';
import 'package:MediansSchoolDriver/components/header.dart';
import 'package:MediansSchoolDriver/components/loader.dart';
import 'package:MediansSchoolDriver/components/CommentBlock.dart';
import 'package:MediansSchoolDriver/components/CustomRow.dart';
import 'package:MediansSchoolDriver/components/FullTextButton.dart';

class HelpMessagePage extends StatefulWidget {
  const HelpMessagePage({super.key, this.message});

  final HelpMessageModel? message;

  @override
  _SentMessageState createState() => _SentMessageState();
}

class _SentMessageState extends State<HelpMessagePage> {
  final HttpService httpService = HttpService();

  List<CommentModel>? commentsList = [];

  String? reply;
  bool showLoader = true;

  TextEditingController replyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return showLoader
        ? Loader()
        : Scaffold(
            body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: activeTheme.main_bg,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
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
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: double.infinity,
                                    color: activeTheme.main_bg,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Row(children: [
                                      Container(
                                          child: SvgPicture.asset(
                                              "assets/svg/help.svg",
                                              width: 30,
                                              height: 30,
                                              color: activeTheme.main_color)),
                                      const SizedBox(width: 15),
                                      Text(lang.translate('Your help messages'),
                                          style: activeTheme.h4,
                                          textAlign: TextAlign.left),
                                    ])),
                                const SizedBox(height: 20),
                                CustomRow(lang.translate('Ticket Number'),
                                    "${widget.message!.message_id}"),
                                CustomRow(lang.translate('Department'),
                                    "${widget.message!.title}"),
                                CustomRow(lang.translate('Status'),
                                    "${widget.message!.status}"),
                                CustomRow(lang.translate('Priority'),
                                    "${widget.message!.priority}"),
                                CustomRow(lang.translate('Time'),
                                    "${widget.message!.date}"),
                                const SizedBox(height: 25),
                                Text("${widget.message!.message}",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontStyle: FontStyle.italic,
                                        color: activeTheme.main_color,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.left),
                                const SizedBox(height: 25),
                                const SizedBox(height: 15),
                                Row(children: [
                                  Container(
                                      child: SvgPicture.asset(
                                          "assets/svg/comments.svg",
                                          width: 30,
                                          height: 30,
                                          color: activeTheme.main_color)),
                                  const SizedBox(width: 15),
                                  Text(lang.translate('Support Comments'),
                                      style: activeTheme.h5,
                                      textAlign: TextAlign.left),
                                ]),
                                const SizedBox(height: 15),
                                for (var i = 0; i < commentsList!.length; i++)
                                  CommentBlock(commentsList![i])
                              ],
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.translate("Comment"),
                                    style: activeTheme.h5,
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: replyController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        filled: true,
                                        hintStyle:
                                            TextStyle(color: Colors.grey[800]),
                                        hintText:
                                            lang.translate('Your message here'),
                                        fillColor: const Color.fromRGBO(
                                            233, 235, 235, 1)),
                                    onChanged: (val) => setState(() {
                                      reply = val;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            FullTextButton(
                                sendReply, lang.translate('Send now')),
                            const SizedBox(height: 100),
                          ],
                        ))),
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Header(lang.translate('Help page'))),
              Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: BottomMenu('help', openPage))
            ],
          ));
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  ///
  /// Load devices through API
  ///
  loadMessage() async {
    setState(() {
      showLoader = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showLoader = false;
    });
  }

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    setState(() {
      showLoader = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      loadMessage();
    });
  }

  sendReply() async {
    setState(() {
      showLoader = true;
    });
    dynamic res = await httpService.sendMessageComment(
        reply!, widget.message!.message_id!);

    setState(() {
      if (res != null) {
        showSuccessDialog(
            context, lang.translate('Success'), lang.translate('Thanks'), res);
        reply = '';
        replyController.clear();
        showLoader = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadMessage();
    commentsList = widget.message!.comments;
  }
}
