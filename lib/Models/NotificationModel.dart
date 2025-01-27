import 'dart:core';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

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
  
  String? formatDate;

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
  }){
    prettyDate();
  }

    prettyDate (){
    try {
      initializeDateFormatting('es_ES', null).then((_) {
        var dt = DateTime.parse(date!);
        DateFormat nuevoFormato = DateFormat("EEEE d 'de' MMMM HH:mm", 'es_ES');
        formatDate  = nuevoFormato.format(dt);
      });
    } catch (e) {
      print("pretty date error ${e.toString()}");
    }
  }
  
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