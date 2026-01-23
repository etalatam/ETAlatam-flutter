import 'dart:async';
import 'package:eta_school_app/Pages/driver_page.dart';
import 'package:eta_school_app/Pages/help_messages_page.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/NotificationModel.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/controllers/page_controller.dart' as p;
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
    // Si los topics no están listos, mostrar loader
    if (!NotificationService.instance.topicsReady) {
      return const Loader();
    }

    return showLoader
        ? const Loader()
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
                                                ),
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
    } catch (e) {
      print("[NotificationsPage] Error loading notifications: $e");
      if (!mounted) return;
      setState(() {
        showLoader = false;
      });
    }
  }

  bool showLoader = true;
  Worker? _pageListener;

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      showLoader = true;
    });

    // Si no hay topics, intentar cargarlos
    if (NotificationService.instance.topicsList.isEmpty) {
      print("[NotificationsPage._refreshData] No hay topics, intentando cargar...");
      await NotificationService.instance.syncGroups().catchError((e) {
        print("[NotificationsPage._refreshData] Error cargando topics: $e");
      });
    }

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

    // Limpiar bandera de nuevas notificaciones al entrar
    NotificationService.instance.clearNewNotificationsFlag();

    // Escuchar cambios de página para recargar cuando se entra a esta vista
    final pageController = Get.find<p.PageController>();
    _pageListener = ever(pageController.currentIndex, (index) {
      if (index == 2 && mounted) {
        print("[NotificationsPage] Tab seleccionado, recargando...");

        // Si no hay topics, intentar cargarlos automáticamente
        if (NotificationService.instance.topicsList.isEmpty) {
          print("[NotificationsPage] No hay topics, intentando cargar...");
          NotificationService.instance.syncGroups().then((_) {
            print("[NotificationsPage] Topics cargados, ahora cargando notificaciones");
            if (mounted) loadNotifications();
          }).catchError((e) {
            print("[NotificationsPage] Error cargando topics: $e");
          });
        } else {
          loadNotifications();
        }
      }
    });

    // Si los topics están listos, cargar notificaciones
    if (NotificationService.instance.topicsReady) {
      // Verificar si hay topics, si no intentar cargarlos
      if (NotificationService.instance.topicsList.isEmpty) {
        print("[NotificationsPage.initState] No hay topics, intentando cargar...");
        NotificationService.instance.syncGroups().then((_) {
          print("[NotificationsPage.initState] Topics cargados");
          if (mounted) loadNotifications();
        }).catchError((e) {
          print("[NotificationsPage.initState] Error cargando topics: $e");
        });
      } else {
        loadNotifications();
      }
    }
  }

  void onNotificationServiceChange() {
    // Si los topics se vuelven ready, recargar el widget para mostrar notificaciones
    if (NotificationService.instance.topicsReady) {
      if (mounted) setState(() {});
      loadNotifications();
      return;
    }

    // Si hay nuevas notificaciones, refrescar la lista
    if (NotificationService.instance.hasNewNotifications && mounted && !showLoader) {
      NotificationService.instance.clearNewNotificationsFlag();
      loadNotifications();
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
    _pageListener?.dispose();
    Provider.of<NotificationService>(context, listen: false)
        .removeListener(onNotificationServiceChange);
    super.dispose();
  }
}
