import 'dart:async';
import 'dart:convert';

import 'package:eta_school_app/shared/emitterio/emitter_client.dart';
import 'package:flutter/foundation.dart';

class EmitterService extends ChangeNotifier {
  static final EmitterService _instance = EmitterService._internal();
  
  // DateTime? _lastMessageDate;
  
  // Timer? _timer;
  
  factory EmitterService() => _instance;

  EmitterService._internal() {
    connect();
  }

  EmitterClient? client;

  String? lastMessage;

  Future<void> connect() async {
    client ??= EmitterClient(
        host: 'wss://emitter.etalatam.com', port: 443, secure: true);

    print("[EmitterService.connect] isConnected ${client?.isConnected}");

    if (client?.isConnected == false) {
      try {
        print("[EmitterService.connecting]...");
        client?.onMessage = _onMessage;
        client?.onSubscribed = _onSubscribed;
        client?.onUnsubscribed = _onUnsubscribed;
        client?.onError = _onError;
        client?.onConnect = _onConnect;
        client?.onDisconnect = _onDisconnect;
        client?.onAutoReconnect = _onAutoReconnect;
        client?.onAutoReconnected = _onAutoReconnected;
        await client?.connect();
      } on Exception catch (e) {
        print("[EmitterService.connect.error] ${e.toString()}");
        client?.disconnect();
      }
    }
  }

  close(){
    try {
      client?.disconnect();
    } catch (e) {
      print(e);
    }
  }

  void _onMessage(String message) {
    print("[EmitterService.onMessage] $message");
    lastMessage = message;
    // _lastMessageDate = DateTime.now();    
    notifyListeners();
  }

  Map<String, dynamic> jsonMessage(){
    return jsonDecode(lastMessage!);
  }

  // void _startTimer() {
  //     print("[EmitterService._startTimer]");
  //   _timer = Timer.periodic(Duration(seconds: 10), (timer) {
  //     if (_lastMessageDate != null) {
  //       final now = DateTime.now();
  //       final difference = now.difference(_lastMessageDate!);
  //       print("[EmitterService.timer] ${difference.inMinutes}min");
  //       if (difference.inSeconds >= 2) {
  //         print("[EmitterService] restarting...");
  //         client?.disconnect();
  //         client?.connect();
  //       }
  //     }
  //   });
  // }

  // void _stopTimer() {
  //   print("[EmitterService._stopTimer]");
  //   _timer?.cancel();
  // }

  void _onError(String error) {
    print("[EmitterService.onError] $error");
  }

  void _onConnect() {
    print("[EmitterService._onConnect]");
    // _startTimer();
  }

  void _onDisconnect() {
    print("[EmitterService._onDisconnect]");
    // _stopTimer();
  }

  void _onSubscribed(String topic) {
    print("[EmitterService.onSubscribed] $topic");
  }

  void _onUnsubscribed(String topic) {
    print("[EmitterService.onUnsubscribed] $topic");
  }

  void _onAutoReconnect() {
    print("[EmitterService.onAutoReconnect]");
  }

  void _onAutoReconnected() {
    print("[EmitterService.onAutoReconnected]");
  }
}
