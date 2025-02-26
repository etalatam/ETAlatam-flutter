import 'package:eta_school_app/components/animated_snackbar_content.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService with ChangeNotifier {

  LastMessage? lastMessage;

  // Declaración del singleton
  static final NotificationService _instance = NotificationService._internal();
  
  List<String> topicsList = [];

  // Constructor privado
  NotificationService._internal() {
    configureFirebaseMessaging();
  }

  // Método factory para retornar la misma instancia del singleton
  factory NotificationService() {
    return _instance;    
  }

  subscribeToTopic(String topic) {
    print("notificationService.subscribeToTopic: $topic");
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      if(!topicsList.contains(topic)){
        topicsList.add(topic);
        messaging.subscribeToTopic(topic);
      }
    } catch (e) {
      print("notificationService.notificationSubcribe.error: ${e.toString()}");
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
      messaging.requestPermission();

      // Obtener el token de FCM
      messaging.getToken().then((token) {
        print("[FCM] Token: $token");
      });

      // Manejar mensajes en segundo plano
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler
      );

      // Manejar mensajes cuando la app está en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('[FCM] Got a message whilst in the foreground!');
        print('[FCM] Message data: ${message.data}');
        if (message.notification != null) {
          print(
              '[FCM] Message also contained a notification: ${message.notification}');
          _handleIncomingMessage(LastMessage(message, 'foreground'));
        }
      });

        final userId = await storage.getItem('id_usu');
        messaging.subscribeToTopic("user-$userId");
    } catch (e) {
      print("[FCM] ${e.toString()}");
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    try {
      print('[FCM] Handling a background message: ${message.messageId}');

      _handleIncomingMessage(LastMessage(message, 'background'));
    } catch (e) {
      print("[FCM] ${e.toString()}");
    }
  }

  Future<void> close() async {
    try {
      for (var topic in topicsList) {
        print("unsubscribeFromTopic: $topic");
        FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      print(e);
    }
  }

  void showTooltip(BuildContext context, RemoteMessage? message) {
    final title = message?.notification!.body ?? "Nuevo mensaje";
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
}

class LastMessage {

  final RemoteMessage lastMessage;

  final String status;

  LastMessage(this.lastMessage, this.status);
}
