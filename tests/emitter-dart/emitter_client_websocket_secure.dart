

import 'package:eta_school_app/shared/emitterio/emitter_client.dart';

const chanelKey = "Us3JQzMD037hjc-pQsOHhCuD_VxFRTEV";

const testChannel = 'test';

final client = EmitterClient(
  host: 'wss://emitter.etalatam.com',
  port: 443,
  secure: true
);


Future<int> main() async {
    
    if (client.isConnected == false) {
      try {
        print("[EmitterService.connecting]...");
        client.onMessage = _onMessage;
        client.onError = _onError;
        client.onConnect = _onConnect;
        client.onDisconnect = _onDisconnect;
        await client.connect();
        print("\n########################################################\n");
      } on Exception catch (e) {
        print("[EmitterService.connect.error] ${e.toString()}");
        client.disconnect();
      }
    }

    return 0;
}

  void _onMessage(String message) {
    print("\n########################################################\n");
    print("[EmitterService.onMessage] $message");
  }

  void _onError(String error) {
    print("\n########################################################\n");
    print("[EmitterService.onError] $error");
  }

  void _onConnect() {
    print("\n########################################################\n");
    print("[EmitterService._onConnect]");

    client.subscribe(testChannel, key: chanelKey);
  }

  void _onDisconnect() {
    print("########################################################");
    print("[EmitterService._onDisconnect]");
  }