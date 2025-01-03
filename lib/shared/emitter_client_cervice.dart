// mqtt_service.dart

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class EmitterClientService extends ChangeNotifier {

  static final EmitterClientService _instance = EmitterClientService._internal();

  late MqttServerClient client;

  String? lastMessage;
  
  factory EmitterClientService() {
    return _instance;
  }
  
  EmitterClientService._internal();

  Future<void> connect() async {
    print("[EmitterClientService.connect]");
    if (client == null || client.connectionStatus!.state != MqttConnectionState.connected) {
      client = MqttServerClient.withPort('emitter.etalatam.com', 'flutter_client', 443);
      client.logging(on: true);
      
      client.onDisconnected = _onDisconnected;
      client.onConnected = _onConnected;
      client.onSubscribed = _onSubscribed;
      client.updates!.listen(_onMessage);

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_client')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      client.connectionMessage = connMessage;
      print("[EmitterClientService.connectionMessage] $connMessage");
      try {
        await client.connect();
      } on Exception catch (e) {
        print("[EmitterClientService.connect.error] ${e.toString()}");
        client.disconnect();
      }
    }
  }
  
  void _onDisconnected() {
    print('[EmitterClientService.Disconnected]');
  }
  
  void _onConnected() {
    print('[EmitterClientService.Connected]');
  }
  
  void _onSubscribed(String topic) {
    print('[EmitterClientService.Subscribed] $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final MqttPublishMessage recMessage = event[0].payload as MqttPublishMessage;
    final String message = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

    lastMessage = message;
    notifyListeners();
  }
  
  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }
  
  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
