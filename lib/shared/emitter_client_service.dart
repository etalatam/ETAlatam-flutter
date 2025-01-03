

import 'package:eta_school_app/shared/emitter_client.dart';
import 'package:flutter/foundation.dart';


class EmitterClientService extends ChangeNotifier {

  static final EmitterClientService _instance = EmitterClientService._internal();

  final EmitterClient client = EmitterClient(
    key: 'your-key-here',
    host: 'api.emitter.io',
    secure: true
  );

  String? lastMessage;
  
  factory EmitterClientService() {
    return _instance;
  }
  
  EmitterClientService._internal();

  Future<void> connect() async {
    print("[EmitterClientService.connect]");
    
    if (client.isConnected == false) {
      try {
        // Connect to the server
        await client.connect();

        client.onMessage = this._onMessage;
      } on Exception catch (e) {
        print("[EmitterClientService.connect.error] ${e.toString()}");
        client.disconnect();
      }
    }
  }
  
  void _onMessage(String message) {
    lastMessage = message;
    notifyListeners();
  }
}
