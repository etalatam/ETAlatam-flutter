

import 'package:eta_school_app/shared/emitterio/emitter_client.dart';

const chanelKey = "XHC_E2nKAmuqYYaABBYZza6DFO6B1xBD";

const testChannel = 'school/24/trip/123/tracking/';

final client = EmitterClient(
  host: 'wss://emitter.etalatam.com',
  port: 443,
  secure: true
);


Future<int> main() async {
    
    if (client.isConnected == false) {
      try {
        print("\n>>>>>>>>>>>>>>>>>>>>> connecting... \n");
        client.onMessage = _onMessage;
        client.onSubscribed = _onSubscribed;
        client.onError = _onError;
        client.onConnect = _onConnect;
        client.onDisconnect = _onDisconnect;
        await client.connect();
      } on Exception catch (e) {
        print("\n>>>>>>>>>>>>>>>>>>>>> connection exception \n");
        print(e.toString());
        client.disconnect();
      }
    }

    return 0;
}

void _onConnect() {
  print("\n>>>>>>>>>>>>>>>>>>>>> Connected OK\n");
  client.subscribe(testChannel, key: chanelKey);
}

void _onMessage(String message) {
  print("\n>>>>>>>>>>>>>>>>>>>>> onMessage \n");
  print("$message \n");
}

void _onError(String error) {
  print("\n>>>>>>>>>>>>>>>>>>>>> onError \n");
  print("$error \n");
}

void _onDisconnect() {
  print("\n>>>>>>>>>>>>>>>>>>>>> onDisconnect \n");
}

void _onSubscribed(String topic) {
    print("\n>>>>>>>>>>>>>>>>>>>>> onSubscribed $topic\n");
}
