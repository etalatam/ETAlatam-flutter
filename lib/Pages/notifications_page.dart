import 'package:eta_school_app/Pages/driver_page.dart';
import 'package:eta_school_app/Pages/help_messages_page.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/NotificationModel.dart';
import 'package:eta_school_app/Pages/providers/notification_provider.dart';
import 'package:eta_school_app/components/animated_snackbar_content.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/slide_action.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  List<NotificationModel> notificationsList = [];

  ParentModel? parent;

  @override
  Widget build(BuildContext context) {
    return showLoader
        ? Loader()
        : Material(
            type: MaterialType.transparency,
            child: RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh:
                    _refreshData, // Function to be called on pull-to-refresh
                child: VisibilityDetector(
                  key: Key('my-widget-key'),
                  onVisibilityChanged: (visibilityInfo) {
                    if (visibilityInfo.visibleFraction > 0) {
                      print('Widget visible');
                      if(notificationsList.isEmpty){
                        loadNotifications();
                      }
                    } else {
                      print('Widget oculto');
                    }
                  },
                  child:
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    color: activeTheme.main_bg,
                    child: Stack(children: [
                      SingleChildScrollView(
                        child: Stack(children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(top: 25),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Container(
                                //   margin: const EdgeInsets.only(left: 30),
                                //   child: SizedBox(
                                //       width: double.infinity,
                                //       child: Text(
                                //         "Medians Trips",
                                //         style: TextStyle(
                                //           color: activeTheme.textColor,
                                //           fontSize: 26,
                                //           // height: 1,
                                //         ),
                                //       )),
                                // ),
                                const SizedBox(height: 60),
                                if(notificationsList.isEmpty)
                                SizedBox(
                                    width: double.infinity,
                                    child: Row(children: [
                                      Container(
                                          child: SvgPicture.asset(
                                              "assets/svg/fire.svg",
                                              color: activeTheme.main_color)),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 2,
                                        child: Container(
                                            color: activeTheme.textColor),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        lang.translate("Notifications"),
                                        style: activeTheme.h3,
                                      )
                                    ])),
                                if(notificationsList.isEmpty)
                                const SizedBox(
                                  height: 10,
                                ),
                                if(notificationsList.isEmpty)
                                SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      lang.translate(
                                          "List of your notifications"),
                                      style: activeTheme.largeText,
                                    )),
                              ],
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 130),
                              child: notificationsList.isEmpty
                                  ? const Center()
                                  : Column(children: [
                                      for (var i = 0;
                                          i < notificationsList.length;
                                          i++)
                                        SlideAction(
                                            [
                                              SlidableAction(
                                                // An action can be bigger than the others.
                                                onPressed: ((context) => ''),
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                icon: Icons.delete_forever,
                                                label: lang.translate('Remove'),
                                              ),
                                              SlidableAction(
                                                // An action can be bigger than the others.
                                                onPressed: ((context) => ''),
                                                backgroundColor: darkBlueColor,
                                                foregroundColor: Colors.white,
                                                icon:
                                                    Icons.notifications_active,
                                                label:
                                                    lang.translate('Mark read'),
                                              )
                                            ],
                                            GestureDetector(
                                              onTap: () => {
                                                handleNotification(
                                                    notificationsList[i])
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    color: notificationsList[i]
                                                                .status ==
                                                            'new'
                                                        ? (darkMode == false
                                                            ? Colors.cyan[50]
                                                            : Colors.white
                                                                .withOpacity(
                                                                    .2))
                                                        : activeTheme.main_bg,
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 16,
                                                      left: 24,
                                                      right: 16,
                                                      bottom: 16,
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: 32,
                                                          height: 32,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration:
                                                              ShapeDecoration(
                                                            color: const Color(
                                                                0xFF61C677),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: SizedBox(
                                                                  width: 32,
                                                                  height: 32,
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              32,
                                                                          height:
                                                                              32,
                                                                          clipBehavior:
                                                                              Clip.antiAlias,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            image:
                                                                                DecorationImage(
                                                                              image: NetworkImage("https://via.placeholder.com/32x32"),
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 2,
                                                                    horizontal:
                                                                        10),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: double
                                                                            .infinity,
                                                                        child:
                                                                            Text(
                                                                          '${notificationsList[i].title}',
                                                                          style:
                                                                              activeTheme.h6,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            SizedBox(
                                                                          child:
                                                                              Text(
                                                                            '${notificationsList[i].body}',
                                                                            style:
                                                                                activeTheme.normalText,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 12),
                                                                SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child: Text(
                                                                    '${notificationsList[i].formatDate}',
                                                                    style: activeTheme
                                                                        .xsmallText,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    color: activeTheme
                                                        .main_color
                                                        .withOpacity(.4),
                                                    width: double.infinity,
                                                    height: 1,
                                                  )
                                                ],
                                              ),
                                            )),
                                      const SizedBox(
                                        height: 100,
                                      ),
                                    ])),
                        ]),
                      ),
                      Positioned(top: 0, left: 0, right: 0, child: Header()),
                      // Positioned(
                      //     bottom: 20,
                      //     left: 20,
                      //     right: 20,
                      //     child: BottomMenu('notifications', openPage))
                    ])))));
  }

  ///
  /// Load devices through API
  ///
  loadNotifications() async {
      setState(() {
        showLoader = true;
      });

    final notificationslistResponse = await httpService.getNotifications(
      notificationServiceProvider.topicsList.toString()
    );

    setState(() {
      showLoader = false;
      if(notificationslistResponse.isNotEmpty){
        notificationsList = notificationslistResponse;  
      }
    });

     showTooltip(null);
  }

  bool showLoader = true;

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    setState(() {
      showLoader = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      loadNotifications();
    });
  }

  handleNotification(NotificationModel notification) async {
    httpService.readNotification(storage.getItem('parent_id'), notification.id);

    setState(() {
      notification.status = 'read';
    });
    switch (notification.notification_model) {
      case 'PickupLocation':
        // openPage(context, RouteMap(route_id: notification.model_id!.toInt()));
        break;
      case 'Driver':
        openPage(context, DriverPage());
        break;
      case 'HelpMessageComment':
        openPage(context, HelpMessagesPage());
        break;
      default:
    }
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  @override
  void initState() {
    super.initState();
    showLoader = true;
    loadNotifications();
    
    Provider.of<NotificationService>(context, listen: false)
          .addListener(onPushMessage);
  }

  onPushMessage(){
    if(!mounted) return;
    final LastMessage? lastMessage =
          Provider.of<NotificationService>(context, listen: false).lastMessage;

    setState(() {
      if(lastMessage?.status == 'foreground'){
        showTooltip(lastMessage!.lastMessage);
      }

      loadNotifications();
    });
  }

  void showTooltip(RemoteMessage? message) {
    final title = message?.notification!.title ?? "Nuevo mensaje";
    final snackBar = SnackBar(
      duration: Duration(seconds: 5),
      content: AnimatedSnackBarContent(title: title,),
      backgroundColor: Color.fromARGB(255, 236, 243, 242),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.white, // Color del borde
          width: 2.0, // Ancho del borde
        ),
        borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
      ),
      behavior: SnackBarBehavior.floating, // Hace que el SnackBar flote
      margin: EdgeInsets.all(20.0), // Margen alrededor del SnackBar
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
