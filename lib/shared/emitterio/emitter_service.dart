

import 'package:eta_school_app/shared/emitterio/emitter_client.dart';
import 'package:flutter/foundation.dart';


class EmitterService extends ChangeNotifier {

  static final EmitterService _instance = EmitterService._internal();

  final EmitterClient client = EmitterClient(
    key: 'KAys6f2KhxK2aCnaCRGNUiCBB0Tbqa3m',
    host: 'emitter.etalatam.com',
    secure: true
  );

  String? lastMessage;
  
  factory EmitterService() {
    return _instance;
  }
  
  EmitterService._internal();

  Future<void> connect() async {
    print("[EmitterService.connect] isConnected ${client.isConnected}");
    
    if (client.isConnected == false) {
      try {
        // Connect to the server
        await client.connect();

        client.onMessage = _onMessage;
      } on Exception catch (e) {
        print("[EmitterService.connect.error] ${e.toString()}");
        client.disconnect();
      }
    }else{

    }
  }
  
  void _onMessage(String message) {
    lastMessage = message;
    notifyListeners();
  }
}
