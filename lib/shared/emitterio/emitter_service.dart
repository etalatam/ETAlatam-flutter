import 'dart:async';
import 'dart:convert';

import 'package:eta_school_app/shared/emitterio/emitter_client.dart';
import 'package:flutter/foundation.dart';

class EmitterService extends ChangeNotifier {
  static final EmitterService _instance = EmitterService._internal();

  factory EmitterService() => _instance;

  EmitterService._internal() {
    connect();
    _startTimer();
  }

  static late EmitterClient _client;

  static String _lastMessage = "";

  static Timer? _timer;

  static DateTime? _lastEmitterDate = DateTime.now();

  Future<void> connect() async {
    _client = EmitterClient(
        host: 'wss://emitter.etalatam.com', port: 443, secure: true);

    print("[EmitterService.connect] isConnected ${_client.isConnected}");

    if (_client.isConnected == false) {
      try {
        print("[EmitterService.connecting]...");
        _client.onMessage = _onMessage;
        _client.onSubscribed = _onSubscribed;
        _client.onUnsubscribed = _onUnsubscribed;
        _client.onError = _onError;
        _client.onConnect = _onConnect;
        _client.onDisconnect = _onDisconnect;
        _client.onAutoReconnect = _onAutoReconnect;
        _client.onAutoReconnected = _onAutoReconnected;
        await _client.connect();
      } on Exception catch (e) {
        print("[EmitterService.connect.error] ${e.toString()}");
        _client.disconnect();
      }
    }
  }

  String lastMessage() {
    return _lastMessage;
  }

  EmitterClient client() {
    return _client;
  }

  close() {
    try {
      _client.disconnect();
    } catch (e) {
      print(e);
    }
  }

  void _onMessage(String message) {
    print("[EmitterService.onMessage] $message");
    _lastMessage = message;
    _lastEmitterDate = DateTime.now();
    notifyListeners();
  }

  Map<String, dynamic> jsonMessage() {
    return jsonDecode(_lastMessage);
  }

  void stopTimer() {
    print("[EmitterService.stopTimer]");
    _timer?.cancel();
  }

  void _onError(String error) {
    print("[EmitterService.onError] $error");
    notifyListeners();
  }

  void _onConnect() {
    print("[EmitterService._onConnect]");
    notifyListeners();
  }

  void _onDisconnect() {
    print("[EmitterService._onDisconnect]");
    // _stopTimer();
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    print("[EmitterService.onSubscribed] $topic");
    notifyListeners();
  }

  void _onUnsubscribed(String topic) {
    print("[EmitterService.onUnsubscribed] $topic");
    notifyListeners();
  }

  void _onAutoReconnect() {
    print("[EmitterService.onAutoReconnect]");
    notifyListeners();
  }

  void _onAutoReconnected() {
    print("[EmitterService.onAutoReconnected]");
    notifyListeners();
  }

  void _startTimer() {
    if (_timer != null) {
      _timer?.cancel();
    }

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      final now = DateTime.now();
      final difference = now.difference(_lastEmitterDate!);
      print("[TripPage.emittertimer.difference] ${difference.inSeconds}s.");

      if (difference.inSeconds >= 60) {
        print("[TripaPage.ermittertimer] restaring... ");
        close();
        connect();
        _lastEmitterDate = DateTime.now();
      }
    });
  }
}
