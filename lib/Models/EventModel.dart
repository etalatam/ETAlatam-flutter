import 'dart:core';

import 'package:eta_school_app/controllers/helpers.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';


class EventModel {
  int id;
  String ts;
  String type;
  String? latlon;
  int? tripId;
  String? description;
  int? senderId;
  String? relationName;
  String? metadata;

  EventModel({
    required this.id,
    required this.ts,
    required this.type,
    this.latlon,
    this.tripId,
    this.description,
    this.senderId,
    this.relationName,
    this.metadata

  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id_event'] as int,
      ts: json['event_ts'] as String,
      type: json['event_type'] as String,
      latlon: json['latlon'] as String?,
      tripId: json['id_trip'] as int?,
      description: json['event_description'],
      senderId: json['sender_id'],
      relationName: json['relation_name'],
      metadata: json['event_metadata']
    );
  }

  // Solicita al api el resto de la informacion del evento usandio el id
  requestData() async {
      EventModel? wrapper = await httpService.getEvent(id);
      ts = wrapper!.ts;
      type = wrapper.type;
      latlon = wrapper.latlon;
      tripId = wrapper.tripId;
      description = wrapper.description;
      senderId = wrapper.senderId;
      relationName = wrapper.relationName;
      metadata = wrapper.metadata;
  }

}
