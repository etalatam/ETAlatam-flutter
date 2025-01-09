import 'dart:core';

class EmitterKeyGenModel {
  int? id;
  String? ts;
  String? key;
  String? channel;

  EmitterKeyGenModel({
    required this.id,
    required this.ts,
    this.key,
    this.channel
  });
  
  factory EmitterKeyGenModel.fromJson( json) {
    return EmitterKeyGenModel(
      id: json['id'] as int?,
      ts: json['ts'] as String?,
      key: json['key'] as String?,
      channel: json['channel'] as String?
    );
  }
}