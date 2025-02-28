import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class EmitterClient {
  static const String defaultHost = 'api.emitter.io';
  static const int defaultPort = 8080;
  static const int defaultKeepAlive = 30;
  static const String defaultSecure = 'true';

  late MqttServerClient _client;
  String? _host;
  int? _port;
  bool _secure;
  String? _key;

  // Connection status
  bool _connected = false;
  bool get isConnected => _connected;

  // Handlers
  void Function(String)? onMessage;
  void Function()? onConnect;
  void Function()? onDisconnect;
  void Function(String)? onError;
  void Function(String)? onSubscribed;
  void Function(String)? onUnsubscribed;
  void Function()? onAutoReconnect;
  void Function()? onAutoReconnected;

  EmitterClient({
    String? host,
    int? port,
    bool secure = true,
    String? key,
  })  : _host = host ?? defaultHost,
        _port = port ?? defaultPort,
        _secure = secure,
        _key = key {
    _initializeClient();
  }

  void _initializeClient() {
    final clientId = 'emitter_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(_host!, clientId, maxConnectionAttempts: 1);
    // _client = MqttServerClient(_host!, '');
    _client.useWebSocket = true;
    _client.port = _port!;
    _client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    _client.setProtocolV311();
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;
    _client.keepAlivePeriod = 20;
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnected = _onAutoReconnected;
    _client.onBadCertificate = (cert) => true;
    _client.logging(on: true);
    //_client.connectionMessage = MqttConnectMessage()
        // .withWillQos(MqttQos.atLeastOnce)
        //.withWillQos(MqttQos.exactlyOnce)
      //  .startClean();
  }

  Future<void> connect() async {
    try {
      await _client.connect();
      _client.published!.listen((MqttPublishMessage message) {
        print("Message receiver");
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        if (onMessage != null) {
          onMessage!(payload);
        }
      });
    } catch (e) {
      _connected = false;
      if (onError != null) {
        onError!(e.toString());
      }
    }
  }

  void reconect() {
    _client.disconnect();
    _client.connect();
  }

  void disconnect() {
    _client.disconnect();
  }

  void subscribe(String channel, {String? key, Map<String, dynamic>? options}) {
    if (!_connected) {
      throw Exception('Client is not connected');
    }

    final subscriberKey = key ?? _key;
    if (subscriberKey == null) {
      throw Exception('Key is required for subscription');
    }

    final formattedChannel = _formatChannel(channel, subscriberKey);
    _client.subscribe(formattedChannel, MqttQos.atLeastOnce);
  }

  void publish(String channel, dynamic message,
      {String? key, Map<String, dynamic>? options}) {
    if (!_connected) {
      throw Exception('Client is not connected');
    }

    final publisherKey = key ?? _key;
    if (publisherKey == null) {
      throw Exception('Key is required for publishing');
    }

    final formattedChannel = _formatChannel(channel, publisherKey);
    final builder = MqttClientPayloadBuilder()..addString(message);

    _client.publishMessage(
      formattedChannel,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: options?['retain'] ?? false,
    );
  }

  void unsubscribe(String channel, {String? key}) {
    if (!_connected) {
      throw Exception('Client is not connected');
    }

    final unsubscriberKey = key ?? _key;
    if (unsubscriberKey == null) {
      throw Exception('Key is required for unsubscription');
    }

    final formattedChannel = _formatChannel(channel, unsubscriberKey);
    _client.unsubscribe(formattedChannel);
  }

  String _formatChannel(String channel, String key) {
    // Prefix with the key if any
    var formatted = channel;
    if (key.isNotEmpty) {
      formatted = "$key/$channel";
    }

    // Add trailing slash
    if (!channel.endsWith("/")) {
      formatted += "/";
    }

    // We're done compiling the channel name
    return formatted;
  }

  void _onConnected() {
    _connected = true;
    if (onConnect != null) {
      onConnect!();
    }
  }

  void _onDisconnected() {
    _connected = false;
    if (onDisconnect != null) {
      onDisconnect!();
    }
  }

  void _onSubscribed(String topic) {
    if (onSubscribed != null) {
      onSubscribed!(topic);
    }
  }

  void _onUnsubscribed(String? topic) {
    if (onUnsubscribed != null) {
      onUnsubscribed!(topic!);
    }
  }

  // Presence-related methods
  void presence(String channel, {String? key}) {
    final presenceKey = key ?? _key;
    if (presenceKey == null) {
      throw Exception('Key is required for presence');
    }

    publish('presence', {'key': presenceKey, 'channel': channel});
  }

  // Link-related methods
  String link(String channel, {String? key, Map<String, dynamic>? options}) {
    final linkKey = key ?? _key;
    if (linkKey == null) {
      throw Exception('Key is required for link generation');
    }

    final queryParams = {
      'key': linkKey,
      'channel': channel,
      ...?options,
    };

    final uri = Uri(
      scheme: _secure ? 'wss://' : 'ws://',
      host: _host,
      port: _port,
      queryParameters: queryParams,
    );

    return uri.toString();
  }

  void _onAutoReconnect() {
    if (onAutoReconnect != null) {
      onAutoReconnect!();
    }
  }

  void _onAutoReconnected() {
    if (onAutoReconnected != null) {
      onAutoReconnected!();
    }
  }
}
