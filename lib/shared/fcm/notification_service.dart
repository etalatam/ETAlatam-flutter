import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Models/recipient_group_model.dart';
import 'package:eta_school_app/Models/user_topic_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/Pages/support_messages_unified_page.dart';
import 'package:eta_school_app/Pages/notifications_page.dart';
import 'package:eta_school_app/components/animated_snackbar_content.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

// Handler de mensajes en background - debe estar fuera de la clase
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    print('[FCM] Handling a background message: ${message.messageId}');
    print('[FCM] Message data: ${message.data}');

    final String? status = message.data['status']?.toString();
    print('[FCM] Background message status: $status');

    if (status == '1' || status == '2') {
      // Usuario agregado/removido de grupo → Se sincronizará al abrir la app
      print('[FCM] Group membership changed in background');
    }
  } catch (e) {
    print('[FCM] Error handling background message: $e');
  }
}

class NotificationService with ChangeNotifier {
  LastMessage? lastMessage;

  // Bandera para indicar que hay nuevas notificaciones pendientes
  bool hasNewNotifications = false;

  // Declaración del singleton
  static final NotificationService _instance = NotificationService._internal();

  final HttpService _httpService = HttpService();

  final Set<String> _topicsSet = {};
  List<String> get topicsList => _topicsSet.toList();
  String? userTopic;
  List<RecipientGroupModel> recipientGroups = [];
  bool _topicsReady = false;
  final Set<String> _subscribingTopics = {};

  bool get topicsReady => _topicsReady;

  void setTopicsReady() {
    if (_topicsReady) return;
    _topicsReady = true;
    notifyListeners();
  }

  void resetTopicsReady() {
    _topicsReady = false;
  }

  // Constructor privado
  NotificationService._internal() {
    configureFirebaseMessaging();
  }

  // Método factory para retornar la misma instancia del singleton
  factory NotificationService() {
    return _instance;
  }

  static NotificationService get instance => _instance;

  /// Suscribirse a un topic específico
  Future<void> subscribeToTopic(String topic) async {
    if (_topicsSet.contains(topic) || _subscribingTopics.contains(topic)) {
      return;
    }

    _subscribingTopics.add(topic);

    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.subscribeToTopic(topic);
      _topicsSet.add(topic);
    } catch (e) {
      print("[NotificationService.subscribeToTopic] error: ${e.toString()}");
    } finally {
      _subscribingTopics.remove(topic);
    }
  }

  /// Desuscribirse de un topic específico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (_topicsSet.contains(topic)) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        _topicsSet.remove(topic);
        print("[NotificationService] Desuscrito de: $topic");
      }
    } catch (e) {
      print("[NotificationService.unsubscribeFromTopic] error: ${e.toString()}");
    }
  }

  /// Setup inicial de notificaciones al hacer login
  Future<void> setupNotifications() async {
    print("[NotificationService.setupNotifications] Iniciando setup");

    try {
      final UserTopicModel? userTopicModel = await _httpService.getMyUserTopic(useSessionCheck: false)
        .timeout(Duration(seconds: 3), onTimeout: () => null);

      if (userTopicModel != null) {
        userTopic = userTopicModel.userTopic;
        await subscribeToTopic(userTopic!);
        await storage.setItem('user_topic', userTopic!);
        print("[NotificationService] Topic personal guardado: $userTopic");
      }

      final dynamic userId = await storage.getItem('id_usu');
      if (userId != null) {
        String userIdTopic = 'user-${userId.toString()}';
        await subscribeToTopic(userIdTopic);
        print("[NotificationService] Suscrito a topic de user ID: $userIdTopic");
      }

      final String? userEmail = await storage.getItem('user_email');
      if (userEmail != null && userEmail.isNotEmpty) {
        String emailTopic = 'email-${userEmail.replaceAll('@', '_at_').replaceAll('.', '_dot_').replaceAll('+', '_plus_')}';
        await subscribeToTopic(emailTopic);
        print("[NotificationService] Suscrito a topic de email: $emailTopic");
      }

      final List<RecipientGroupModel> groups = await _httpService.getMyRecipientGroups(useSessionCheck: false)
        .timeout(Duration(seconds: 3), onTimeout: () => <RecipientGroupModel>[]);
      recipientGroups = groups;

      if (groups.isNotEmpty) {
        await Future.wait(
          groups.map((group) => subscribeToTopic(group.topic)),
        ).timeout(Duration(seconds: 3), onTimeout: () => []);
      }

      await storage.setItem('recipient_groups', groups.map((g) => g.toJson()).toList());

      print("[NotificationService] Setup completado. Topics: ${topicsList.length}");
    } catch (e) {
      print("[NotificationService.setupNotifications] error: ${e.toString()}");
    }
  }

  /// Sincronizar grupos cuando cambian las membresías
  Future<void> syncGroups() async {
    print("[NotificationService.syncGroups] Sincronizando grupos");

    try {
      // Obtener nuevos grupos del backend
      final List<RecipientGroupModel> newGroups = await _httpService.getMyRecipientGroups();

      // Obtener grupos anteriores del storage
      final dynamic storedGroups = await storage.getItem('recipient_groups');
      List<RecipientGroupModel> oldGroups = [];

      if (storedGroups != null && storedGroups is List) {
        oldGroups = (storedGroups as List).map((g) => RecipientGroupModel.fromJson(g)).toList();
      }

      final List<String> oldTopics = oldGroups.map((g) => g.topic).toList();
      final List<String> newTopics = newGroups.map((g) => g.topic).toList();

      // Desuscribirse de topics removidos (en paralelo)
      final List<String> toUnsubscribe = oldTopics.where((t) => !newTopics.contains(t)).toList();
      if (toUnsubscribe.isNotEmpty) {
        await Future.wait(
          toUnsubscribe.map((topic) => unsubscribeFromTopic(topic)),
        );
      }

      // Suscribirse a nuevos topics (en paralelo)
      final List<String> toSubscribe = newTopics.where((t) => !oldTopics.contains(t)).toList();
      if (toSubscribe.isNotEmpty) {
        await Future.wait(
          toSubscribe.map((topic) => subscribeToTopic(topic)),
        );
      }

      // Actualizar grupos almacenados
      recipientGroups = newGroups;
      await storage.setItem('recipient_groups', newGroups.map((g) => g.toJson()).toList());

      print("[NotificationService.syncGroups] Sincronización completada");
      print("[NotificationService] Topics desuscritos: ${toUnsubscribe.length}");
      print("[NotificationService] Topics suscritos: ${toSubscribe.length}");
    } catch (e) {
      print("[NotificationService.syncGroups] error: ${e.toString()}");
    }
  }

  // Marcar que ya se leyeron las notificaciones nuevas
  void clearNewNotificationsFlag() {
    hasNewNotifications = false;
  }

  /// Navegar según el tipo de notificación
  Future<void> _navigateBasedOnNotificationType(RemoteMessage message) async {
    try {
      print('[FCM] Navigating based on notification type');
      print('[FCM] Message data: ${message.data}');

      // Extraer información del payload
      final Map<String, dynamic> data = message.data;
      final String? notificationType = data['type']?.toString();
      final String? topic = data['topic']?.toString();

      // Detectar tipo de notificación basado en el tipo o topic
      if (notificationType != null) {
        switch (notificationType.toLowerCase()) {
          case 'trip':
          case 'viaje':
            await _navigateToTrip(data);
            break;
          case 'support':
          case 'soporte':
          case 'message':
          case 'mensaje':
            await _navigateToSupportMessage(data);
            break;
          case 'announcement':
          case 'anuncio':
            await _navigateToAnnouncements(data);
            break;
          default:
            // Si no hay tipo específico, intentar detectar por topic
            if (topic != null && topic.contains('trip-')) {
              await _navigateToTrip(data);
            } else {
              await _navigateToNotifications();
            }
        }
      } else if (topic != null) {
        // Detectar por el formato del topic si no hay type
        if (topic.contains('trip-')) {
          await _navigateToTrip(data);
        } else if (topic.contains('support-') || topic.contains('message-')) {
          await _navigateToSupportMessage(data);
        } else {
          await _navigateToNotifications();
        }
      } else {
        // Por defecto, ir a la página de notificaciones
        await _navigateToNotifications();
      }
    } catch (e) {
      print('[FCM] Error navigating: $e');
      // En caso de error, ir a notificaciones por defecto
      await _navigateToNotifications();
    }
  }

  /// Navegar a un viaje específico
  Future<void> _navigateToTrip(Map<String, dynamic> data) async {
    try {
      // Extraer trip_id del payload
      final dynamic tripId = data['trip_id'] ?? data['tripId'] ?? data['id'];

      if (tripId != null) {
        print('[FCM] Navigating to trip: $tripId');

        // Obtener información del viaje
        final tripIdInt = int.tryParse(tripId.toString());
        if (tripIdInt != null) {
          // Crear un modelo de viaje básico con el ID
          // El TripPage se encargará de cargar los detalles
          final TripModel trip = TripModel(
            trip_id: tripIdInt,
            trip_status: data['trip_status'] ?? 'Running',
          );

          // Determinar el modo de navegación basado en el rol del usuario
          final String? relationName = await storage.getItem('relation_name');
          bool navigationMode = false;
          bool showBus = true;

          if (relationName == 'Driver') {
            navigationMode = trip.trip_status == 'Running';
            showBus = false;
          } else {
            navigationMode = false;
            showBus = true;
          }

          // Navegar a la página del viaje
          Get.to(() => TripPage(
            trip: trip,
            navigationMode: navigationMode,
            showBus: showBus,
            showStudents: true,  // Mostrar estudiantes por defecto en notificaciones
          ));
        } else {
          print('[FCM] Invalid trip_id format');
          await _navigateToNotifications();
        }
      } else {
        print('[FCM] No trip_id in notification data');
        await _navigateToNotifications();
      }
    } catch (e) {
      print('[FCM] Error navigating to trip: $e');
      await _navigateToNotifications();
    }
  }

  /// Navegar a un mensaje de soporte específico
  Future<void> _navigateToSupportMessage(Map<String, dynamic> data) async {
    try {
      // Extraer message_id del payload
      final dynamic messageId = data['message_id'] ?? data['messageId'] ?? data['id'];

      if (messageId != null) {
        print('[FCM] Navigating to support message: $messageId');

        // Navegar a la página unificada de mensajes de soporte
        Get.to(() => SupportMessagesUnifiedPage());
      } else {
        print('[FCM] No message_id in notification data');
        await _navigateToNotifications();
      }
    } catch (e) {
      print('[FCM] Error navigating to support message: $e');
      await _navigateToNotifications();
    }
  }

  /// Navegar a anuncios
  Future<void> _navigateToAnnouncements(Map<String, dynamic> data) async {
    try {
      print('[FCM] Navigating to announcements');
      Get.to(() => NotificationsPage());
    } catch (e) {
      print('[FCM] Error navigating to announcements: $e');
      await _navigateToNotifications();
    }
  }

  /// Navegar a la página de notificaciones por defecto
  Future<void> _navigateToNotifications() async {
    try {
      print('[FCM] Navigating to notifications page');
      Get.to(() => NotificationsPage());
    } catch (e) {
      print('[FCM] Error navigating to notifications: $e');
    }
  }

  configureFirebaseMessaging() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Solicitar permisos en iOS
      await messaging.requestPermission();

      // Obtener el token de FCM
      messaging.getToken().then((token) {
        print("[FCM] Token: $token");
      });

      // Manejar mensajes en segundo plano
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Manejar mensajes cuando la app está en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('[FCM] Got a message whilst in the foreground!');
        print('[FCM] Message data: ${message.data}');

        // Obtener el status del mensaje
        final String? status = message.data['status']?.toString();
        print('[FCM] Message status: $status');

        if (status == '1') {
          // Usuario agregado a grupo → Sincronizar
          print('[FCM] Usuario agregado a grupo, sincronizando...');
          syncGroups();
        } else if (status == '2') {
          // Usuario removido de grupo → Sincronizar
          print('[FCM] Usuario removido de grupo, sincronizando...');
          syncGroups();
        } else {
          // Marcar que hay nuevas notificaciones para refrescar la lista
          hasNewNotifications = true;
          notifyListeners();

          // Mostrar snackbar si tiene notification
          if (message.notification != null) {
            print('[FCM] Message also contained a notification: ${message.notification}');
            lastMessage = LastMessage(message, 'foreground');
          }
        }
      });

      // Manejar cuando el usuario toca una notificación
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('[FCM] Message opened from notification!');
        print('[FCM] Message data: ${message.data}');

        final String? status = message.data['status']?.toString();
        if (status == '1' || status == '2') {
          // Sincronizar grupos al abrir la app desde notificación
          syncGroups();
        } else {
          // Navegar según el tipo de notificación
          _navigateBasedOnNotificationType(message);
        }
      });
    } catch (e) {
      print("[FCM] ${e.toString()}");
    }
  }

  /// Cerrar servicio y desuscribirse de todos los topics
  Future<void> close() async {
    print("[NotificationService.close] Desuscribiendo de todos los topics (${topicsList.length} topics)");
    try {
      final List<String> topicsToUnsubscribe = List.from(topicsList);

      // Desuscribir de todos los topics en paralelo para acelerar el proceso
      final unsubscribeFutures = topicsToUnsubscribe.map((topic) {
        print("[NotificationService] Desuscribiendo de: $topic");
        return FirebaseMessaging.instance.unsubscribeFromTopic(topic).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print("[NotificationService] Timeout desuscribiendo de: $topic");
          },
        ).catchError((e) {
          print("[NotificationService] Error desuscribiendo de $topic: $e");
        });
      }).toList();

      // Esperar a que todas las desuscripciones completen (máximo 5 segundos cada una)
      await Future.wait(unsubscribeFutures);

      _topicsSet.clear();
      userTopic = null;
      recipientGroups.clear();
      _topicsReady = false;

      // Limpiar storage
      await storage.deleteItem('user_topic');
      await storage.deleteItem('recipient_groups');

      print("[NotificationService.close] Todos los topics desuscritos completado");
    } catch (e) {
      print("[NotificationService.close] error: ${e.toString()}");
    }
  }

  void showTooltip(BuildContext context, RemoteMessage? message) {
    final title = message?.notification!.body ?? "Nuevo mensaje";
    final snackBar = SnackBar(
      duration: Duration(seconds: 5),
      content: AnimatedSnackBarContent(
        title: title,
      ),
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
}

class LastMessage {
  final RemoteMessage message;

  final String status;

  LastMessage(this.message, this.status);
}
