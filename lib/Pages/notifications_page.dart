import 'dart:async';
import 'package:eta_school_app/Pages/driver_page.dart';
import 'package:eta_school_app/Pages/help_messages_page.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/NotificationModel.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/slide_action.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  /// Obtener color según prioridad del anuncio
  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgente':
        return const Color(0xFFE74C3C); // Rojo para urgente
      case 'normal':
        return const Color(0xFF61C677); // Verde para normal
      case 'baja':
        return const Color(0xFF95A5A6); // Gris para baja prioridad
      default:
        return const Color(0xFF61C677); // Verde por defecto
    }
  }

  /// Obtener icono según nombre
  IconData _getIconByName(String iconName) {
    if (iconName.isEmpty) return Icons.notifications;

    String normalizedName = iconName.toLowerCase().trim();

    switch (normalizedName) {
      case 'arrow_circle_up':
        return Icons.arrow_circle_up;
      case 'departure_board':
        return Icons.departure_board;
      case 'medical_services':
        return Icons.medical_services;
      case 'flag':
        return Icons.flag;
      case 'adjust':
        return Icons.adjust;
      case 'location_on':
        return Icons.location_on;
      case 'no_transfer':
        return Icons.no_transfer;
      case 'arrow_circle_down':
        return Icons.arrow_circle_down;
      case 'sports_score':
        return Icons.sports_score;
      case 'bus_alert':
        return Icons.bus_alert;
      case 'notifications':
        return Icons.notifications;
      default:
        // Si el icono no está mapeado, devolver un icono predeterminado
        print('Icono no mapeado: $iconName');
        return Icons.notifications;
    }
  }

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
                onRefresh: _refreshData,
                child: Container(
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
                                    if (notificationsList.isEmpty)
                                      SizedBox(
                                          width: double.infinity,
                                          child: Row(children: [
                                            Container(
                                                child: SvgPicture.asset(
                                                    "assets/svg/fire.svg",
                                                    color: activeTheme
                                                        .main_color)),
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
                                    if (notificationsList.isEmpty)
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    if (notificationsList.isEmpty)
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
                                                    onPressed: ((context) =>
                                                        ''),
                                                    backgroundColor: Colors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                    icon: Icons.delete_forever,
                                                    label: lang
                                                        .translate('remove'),
                                                  ),
                                                  SlidableAction(
                                                    // An action can be bigger than the others.
                                                    onPressed: ((context) =>
                                                        ''),
                                                    backgroundColor:
                                                        darkBlueColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                    icon: Icons
                                                        .notifications_active,
                                                    label: lang
                                                        .translate('mark_read'),
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
                                                        color: notificationsList[
                                                                        i]
                                                                    .status ==
                                                                'new'
                                                            ? (darkMode == false
                                                                ? Colors
                                                                    .cyan[50]
                                                                : Colors.white
                                                                    .withOpacity(
                                                                        .2))
                                                            : activeTheme
                                                                .main_bg,
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
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
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              decoration:
                                                                  BoxDecoration(
                                                                // Color según prioridad
                                                                color: _getPriorityColor(notificationsList[i].priority),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  notificationsList[i]
                                                                              .icon !=
                                                                          null
                                                                      ? Positioned(
                                                                          left:
                                                                              0,
                                                                          top:
                                                                              0,
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                32,
                                                                            height:
                                                                                32,
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Positioned(
                                                                                  left: 0,
                                                                                  top: 0,
                                                                                  child: SizedBox(
                                                                                    width: 32,
                                                                                    height: 32,
                                                                                    child: Icon(
                                                                                      _getIconByName(notificationsList[i].icon ?? 'notifications'),
                                                                                      color: Colors.white,
                                                                                      size: 24,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Positioned(
                                                                          left:
                                                                              0,
                                                                          top:
                                                                              0,
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                32,
                                                                            height:
                                                                                32,
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Positioned(
                                                                                  left: 0,
                                                                                  top: 0,
                                                                                  child: SizedBox(
                                                                                    width: 32,
                                                                                    height: 32,
                                                                                    child: Icon(
                                                                                      Icons.notifications,
                                                                                      color: Colors.white,
                                                                                      size: 24,
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
                                                                padding: const EdgeInsets
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
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                double.infinity,
                                                                            child:
                                                                                Text(
                                                                              '${notificationsList[i].title}',
                                                                              style: activeTheme.h6,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 8),
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
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                SizedBox(
                                                                              child: Text(
                                                                                '${notificationsList[i].body}',
                                                                                style: activeTheme.normalText,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12),
                                                                    SizedBox(
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          Text(
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
                          Positioned(
                              top: 0, left: 0, right: 0, child: Header()),
                          // Positioned(
                          //     bottom: 20,
                          //     left: 20,
                          //     right: 20,
                          //     child: BottomMenu('notifications', openPage))
                        ]))));
  }


  ///
  /// Load notifications through API
  /// Carga notificaciones basadas en los topics suscritos
  ///
  loadNotifications() async {
    if (!mounted) return;
    setState(() {
      showLoader = true;
    });

    try {
      // Obtener topics suscritos
      final topicsList = NotificationService.instance.topicsList;
      print("[NotificationsPage] Loading notifications for topics: $topicsList");

      // Cargar notificaciones del backend
      final notificationslistResponse = await httpService
          .getNotifications(topicsList.toString());

      if (!mounted) return;
      setState(() {
        showLoader = false;
        if (notificationslistResponse.isNotEmpty) {
          notificationsList = notificationslistResponse;
          print("[NotificationsPage] Loaded ${notificationsList.length} notifications");
        } else {
          print("[NotificationsPage] No notifications found");
        }
      });
      if (!_didAutoRefresh) {
        _scheduleRefresh();
      }
    } catch (e) {
      print("[NotificationsPage] Error loading notifications: $e");
      if (!mounted) return;
      setState(() {
        showLoader = false;
      });
    }
  }

  bool showLoader = true;
  bool _isFirstLoad = true;
  bool _didAutoRefresh = false;
  int _lastTopicsCount = 0;
  Timer? _debounceTimer;
  Timer? _refreshTimer;

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      showLoader = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      loadNotifications();
    });
  }

  handleNotification(NotificationModel notification) async {
    httpService.readNotification(await storage.getItem('parent_id'), notification.id);

    if (!mounted) return;
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
    if (!mounted) return;
    setState(() => openNewPage(context, page));
  }

  @override
  void initState() {
    super.initState();
    showLoader = true;

    Provider.of<NotificationService>(context, listen: false)
        .addListener(onNotificationServiceChange);

    if (NotificationService.instance.topicsReady) {
      _isFirstLoad = false;
      loadNotifications();
    } else {
      _startTimeout();
    }
  }

  void _startTimeout() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted && _isFirstLoad) {
        _isFirstLoad = false;
        print("[NotificationsPage] Timeout esperando topics, cargando con los disponibles");
        loadNotifications();
      }
    });
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(Duration(milliseconds: 200), () {
      if (mounted) {
        _didAutoRefresh = true;
        print("[NotificationsPage] Refrescando automáticamente después de 500ms");
        _refreshData();
      }
    });
  }

  void onNotificationServiceChange() {
    if (NotificationService.instance.topicsReady && _isFirstLoad) {
      _isFirstLoad = false;
      _lastTopicsCount = NotificationService.instance.topicsList.length;
      loadNotifications();
      return;
    }

    final currentCount = NotificationService.instance.topicsList.length;
    if (!_isFirstLoad && currentCount > _lastTopicsCount) {
      _lastTopicsCount = currentCount;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(seconds: 2), () {
        if (mounted && !showLoader) {
          loadNotifications();
        }
      });
    }

    final LastMessage? lastMessage = NotificationService.instance.lastMessage;
    if (lastMessage != null && mounted) {
      final title = lastMessage.message.notification!.title ?? "Nuevo mensaje";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(title),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _refreshTimer?.cancel();
    Provider.of<NotificationService>(context, listen: false)
        .removeListener(onNotificationServiceChange);
    super.dispose();
  }
}
