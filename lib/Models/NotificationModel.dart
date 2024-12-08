import 'dart:core';

class NotificationModel {
  
  int? id;
  String? title;
  String? status;
  String? body;
  String? picture;
  String? short_date;
  String? date;
  String? notification_model;
  String? model_type;
  double? model_id;

  NotificationModel({
    required this.id,
    required this.title,
    this.status,
    this.body,
    this.picture,
    this.short_date,
    this.date,
    this.notification_model,
    this.model_type,
    this.model_id,
  });
  
  factory NotificationModel.fromJson( json) {
    return NotificationModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      status: json['status'] as String?,
      picture: json['picture'] as String?,
      body: json['body'] as String?,
      short_date: json['ts'] as String?,
      model_type: json['model_type'] as String?,
      model_id: json['model_id'] as double?,
      date: json['ts'] as String?,
      notification_model: json['notification_model'] as String?,
    );
  }

}