

import 'package:eta_school_app/shared/emitterio/emitter_client.dart';
import 'package:flutter/foundation.dart';

class EmitterService extends ChangeNotifier {
  
  static final EmitterService _instance = EmitterService._internal();
  
  factory EmitterService() => _instance;
  
  EmitterService._internal();

  EmitterClient? client;

  String? lastMessage;

  Future<void> connect() async {

    client ??= EmitterClient(
      // key: 'KAys6f2KhxK2aCnaCRGNUiCBB0Tbqa3m',
      host: 'emitter.etalatam.com',
      port: 443,
      secure: true
    );
    
    print("[EmitterService.connect] isConnected ${client?.isConnected}");

    if (client?.isConnected == false) {
      try {
        print("[EmitterService.connecting]...");
        client?.onMessage = _onMessage;
        client?.onError = _onError;
        client?.onConnect = _onConnect;
        client?.onDisconnect = _onDisconnect;
        await client?.connect();
      } on Exception catch (e) {
        print("[EmitterService.connect.error] ${e.toString()}");
        client?.disconnect();
      }
    }
  }
  
  void _onMessage(String message) {
    print("[EmitterService.onMessage] $message");
    lastMessage = message;
    notifyListeners();
  }

  void _onError(String error) {
    print("[EmitterService.onError] $error");
  }

  void _onConnect() {
    print("[EmitterService._onConnect]");
  }

  void _onDisconnect() {
    print("[EmitterService._onDisconnect]");
  }
}
