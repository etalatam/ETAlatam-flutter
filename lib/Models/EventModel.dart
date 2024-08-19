import 'dart:core';


class EventModel {
  int? event_id;
  String? title;
  String? description;
  String? picture;
  String? status;

  EventModel({
    required this.event_id,
    this.title,
    this.description,
    this.picture,
    this.status,

  });

  factory EventModel.fromJson(Map<String, dynamic> json) {

    return EventModel(
      event_id: json['event_id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      picture: json['picture'] as String?,
      status: json['status'] as String?,
    );
  }

}
