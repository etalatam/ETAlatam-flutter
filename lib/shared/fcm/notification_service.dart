import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Models/recipient_group_model.dart';
import 'package:eta_school_app/Models/user_topic_model.dart';
import 'package:eta_school_app/components/animated_snackbar_content.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  // Declaración del singleton
  static final NotificationService _instance = NotificationService._internal();

  final HttpService _httpService = HttpService();

  List<String> topicsList = [];
  String? userTopic;
  List<RecipientGroupModel> recipientGroups = [];

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
    print("[NotificationService.subscribeToTopic] $topic");
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      if (!topicsList.contains(topic)) {
        await messaging.subscribeToTopic(topic);
        topicsList.add(topic);
        print("[NotificationService] Suscrito exitosamente a: $topic");
      } else {
        print("[NotificationService] Ya estaba suscrito a: $topic");
      }
    } catch (e) {
      print("[NotificationService.subscribeToTopic] error: ${e.toString()}");
    }
  }

  /// Desuscribirse de un topic específico
  Future<void> unsubscribeFromTopic(String topic) async {
    print("[NotificationService.unsubscribeFromTopic] $topic");
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      if (topicsList.contains(topic)) {
        await messaging.unsubscribeFromTopic(topic);
        topicsList.remove(topic);
        print("[NotificationService] Desuscrito exitosamente de: $topic");
      }
    } catch (e) {
      print("[NotificationService.unsubscribeFromTopic] error: ${e.toString()}");
    }
  }

  /// Setup inicial de notificaciones al hacer login
  Future<void> setupNotifications() async {
    print("[NotificationService.setupNotifications] Iniciando setup");

    try {
      // 1. Obtener y suscribirse al topic personal con timeout
      // useSessionCheck: false para evitar bucle infinito durante el login
      final UserTopicModel? userTopicModel = await _httpService.getMyUserTopic(useSessionCheck: false)
        .timeout(Duration(seconds: 3), onTimeout: () => null);

      if (userTopicModel != null) {
        userTopic = userTopicModel.userTopic;
        await subscribeToTopic(userTopic!);
        await storage.setItem('user_topic', userTopic!);
        print("[NotificationService] Topic personal guardado: $userTopic");
      }

      // 2. Suscribirse al topic basado en el ID del usuario
      final dynamic userId = await storage.getItem('id_usu');
      if (userId != null) {
        String userIdTopic = 'user-${userId.toString()}';
        await subscribeToTopic(userIdTopic);
        print("[NotificationService] Suscrito a topic de user ID: $userIdTopic");
      }

      // 3. Suscribirse al topic basado en el email del usuario
      final String? userEmail = await storage.getItem('user_email');
      if (userEmail != null && userEmail.isNotEmpty) {
        // Convertir email a formato válido para topic FCM
        // Reemplazar @ con _at_ y . con _dot_ para crear un topic válido
        String emailTopic = 'email-${userEmail.replaceAll('@', '_at_').replaceAll('.', '_dot_')}';
        await subscribeToTopic(emailTopic);
        print("[NotificationService] Suscrito a topic de email: $emailTopic");
      }

      // 4. Obtener y suscribirse a los topics de grupos con timeout
      // useSessionCheck: false para evitar bucle infinito durante el login
      final List<RecipientGroupModel> groups = await _httpService.getMyRecipientGroups(useSessionCheck: false)
        .timeout(Duration(seconds: 3), onTimeout: () => <RecipientGroupModel>[]);
      recipientGroups = groups;

      // Suscribirse a todos los topics en paralelo para mejor rendimiento
      if (groups.isNotEmpty) {
        await Future.wait(
          groups.map((group) => subscribeToTopic(group.topic)),
        ).timeout(Duration(seconds: 3), onTimeout: () => []);
      }

      // Guardar grupos en storage para sincronización posterior
      await storage.setItem('recipient_groups', groups.map((g) => g.toJson()).toList());

      print("[NotificationService] Setup completado. Topics: ${topicsList.length}");
    } catch (e) {
      print("[NotificationService.setupNotifications] error: ${e.toString()}");
      // No lanzamos el error para evitar bloquear el login
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

  // Método para manejar los mensajes entrantes
  void _handleIncomingMessage(LastMessage message) {
    lastMessage = message;
    notifyListeners();
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
          // Anuncio normal → Mostrar notificación
          if (message.notification != null) {
            print('[FCM] Message also contained a notification: ${message.notification}');
            _handleIncomingMessage(LastMessage(message, 'foreground'));
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
        }
      });
    } catch (e) {
      print("[FCM] ${e.toString()}");
    }
  }

  /// Cerrar servicio y desuscribirse de todos los topics
  Future<void> close() async {
    print("[NotificationService.close] Desuscribiendo de todos los topics");
    try {
      final List<String> topicsToUnsubscribe = List.from(topicsList);

      for (var topic in topicsToUnsubscribe) {
        print("[NotificationService] Desuscribiendo de: $topic");
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }

      // Limpiar la lista y variables
      topicsList.clear();
      userTopic = null;
      recipientGroups.clear();

      // Limpiar storage
      await storage.deleteItem('user_topic');
      await storage.deleteItem('recipient_groups');

      print("[NotificationService.close] Todos los topics desuscritos");
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
