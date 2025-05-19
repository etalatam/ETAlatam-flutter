import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eta_school_app/shared/emitterio/emitter_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class EmitterService extends ChangeNotifier {
  static final EmitterService _instance = EmitterService._internal();

  bool _updatelastTime = false;

  factory EmitterService() => _instance;
  
  static EmitterService get instance => _instance;


  EmitterService._internal() {
    connect();
    // _startTimer();
  }

  static late EmitterClient _client;

  static String _lastMessage = "";

  static Timer? _timer;

  static DateTime? _lastEmitterDate = DateTime.now();

  List<EmitterTopic> _subscribedTopics = [];

  bool connectivityNone = false;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

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

  updateLastEmitterDate(date) {
    _lastEmitterDate = date;
  }

  void subscribe(EmitterTopic topic) {
    print("[EmitterService] subscribe ${topic.name}");
    _client.subscribe(topic.name, key: topic.key);
    _subscribedTopics.add(topic);
  }

  void unsubscribe(EmitterTopic topic) {
    _client.unsubscribe(topic.name, key: topic.key);
    for (var t in _subscribedTopics) {
      _subscribedTopics.remove(topic);
    }
  }

  bool isConnected() {
    return _client.isConnected;
  }

  disconnect() {
    try {
      _client.disconnect();
    } catch (e) {
      print(e);
    }
  }

  void _onMessage(String message) {
    print("[EmitterService.onMessage] $message");
    _lastMessage = message;
    if (_updatelastTime) {
      _lastEmitterDate = DateTime.now();
    }

    notifyListeners();
  }

  Map<String, dynamic> jsonMessage() {
    return jsonDecode(_lastMessage);
  }

  void _onError(String error) {
    print("[EmitterService.onError] $error");
    notifyListeners();
  }

  void _onConnect() {
    print("[EmitterService._onConnect]");
    // Re-subscribe to previously subscribed topics
    for (var topic in _subscribedTopics) {
      _client.subscribe(topic.name, key: topic.key);
    }
    notifyListeners();
  }

  void _onDisconnect() {
    print("[EmitterService._onDisconnect]");
    notifyListeners();
    // Intentar reconectar después de la desconexión
    connect();
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

  void stopTimer() {
    print("[EmitterService.stopTimer]");
    _timer?.cancel();
  }

  void startTimer(bool updatelastTime) {
    // si existe un timer activo se cancela
    if (_timer != null) {
      _timer?.cancel();
    }

    _updatelastTime = updatelastTime;

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (connectivityNone) {
        print("[TripaPage.ermittertimer] offline... ");
        return;
      }

      final now = DateTime.now();
      final difference = now.difference(_lastEmitterDate!);
      print("[TripPage.emittertimer.difference] ${difference.inSeconds}s.");

      if (difference.inSeconds >= 40) {
        print("[TripaPage.ermittertimer] restaring... ");
        _client.reconect();
        _lastEmitterDate = DateTime.now();
        for (var topic in _subscribedTopics) {
          _client.subscribe(topic.name, key: topic.key);
        }
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status ${e.toString()}');
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    connectivityNone =
        results.any((result) => result == ConnectivityResult.none);

    print('[EmitterService] connectivityNone: $connectivityNone');

    if (connectivityNone && _client.isConnected) {
      disconnect();
    }

    if (!connectivityNone && !_client.isConnected) {
      connect();
    }
  }
}

class EmitterTopic {
  String name;
  String key;

  EmitterTopic(this.name, this.key);
}
