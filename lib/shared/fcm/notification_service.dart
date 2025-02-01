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
    print("notificationService.notificationSubcribe: $topic");
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

      try {
        final userId = await storage.getItem('id_usu');
        messaging.subscribeToTopic("user-$userId");
      } catch (e) {
        print(e.toString());
      }
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
      String? topics = await storage.getItem('route-topics');
      if(topics != null){
        topics =
          topics.replaceAll("[", "").replaceAll("]", "").replaceAll(" ", "");
      }
      List<String> topicsList = topics!.split(",");

      for (var topic in topicsList) {
        print("unsubscribeFromTopic: $topic");
        FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      print(e);
    }
  }
}

class LastMessage {

  final RemoteMessage lastMessage;

  final String status;

  LastMessage(this.lastMessage, this.status);
}
