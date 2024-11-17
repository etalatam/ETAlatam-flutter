import 'dart:core';

import 'package:intl/intl.dart';

class SupportHelpCategory {
  int? id;
  String? name;

  SupportHelpCategory({this.id, this.name});

  factory SupportHelpCategory.fromJson(json) {
    return SupportHelpCategory(id: json['id'], name: json['name']);
  }
}

class HelpMessageModel {
  int? message_id;
  String? title;
  String? message;
  String? status;
  String? priority;
  String? picture;
  int? user_id;
  String? short_date;
  String? date;
  List<CommentModel>? comments;

  HelpMessageModel({
    this.message_id,
    required this.title,
    this.message,
    this.status,
    this.priority,
    this.picture,
    this.user_id,
    this.short_date,
    this.date,
    this.comments,
  });

  factory HelpMessageModel.fromJson(json) {
    List<CommentModel>? comments = [];

    try {
      Iterable commentsList = json['comments'];
      comments = json['comments'] != null
          ? List<CommentModel>.from(
              commentsList.map((model) => CommentModel.fromJson(model)))
          : [];
    } catch (e) {
      print(e.toString());
    }

    return HelpMessageModel(
        message_id: json['id'] as int?,
        // title: json['subject'] as String?,
        title: json['category_name'] as String?,
        message: json['content'] as String?,
        status: "status", //json['status'] as String?,
        priority: "${json['priority_id']}" as String?,
        user_id: json['id_driver'] as int,
        short_date: json['ts'],
        date: json['ts'] as String?,
        comments: comments);
  }
}

class CommentModel {
  int? id;
  String? comment;
  String? message_id;
  int? user_id;
  String? short_date;
  String? date;
  CommentUserModel? user;

  CommentModel({
    required this.id,
    this.comment,
    this.user_id,
    this.message_id,
    this.short_date,
    this.date,
    this.user,
  });

  factory CommentModel.fromJson(json) {
    CommentUserModel? user;
    try {
      user = json['user'] != null
          ? CommentUserModel.fromJson(json)
          : CommentUserModel();
    } catch (e) {
      print(e.toString());
    }

    DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
    DateFormat shortDateFormat = DateFormat("yyyy-MM-dd HH:mm");
    DateTime dateTime = dateFormat.parse(json['ts']);

    return CommentModel(
      id: json['id'] as int?,
      comment: json['txt'] as String?,
      user_id: json['id_usu'] as int,
      short_date: shortDateFormat.format(dateTime),
      date: json['ts'] as String?,
      user: user,
    );
  }
}

class CommentUserModel {
  String? name;
  String? email;
  String? photo;

  CommentUserModel({
    this.name,
    this.email,
    this.photo,
  });

  factory CommentUserModel.fromJson(json) {
    return CommentUserModel(
      name: json['user_name'] as String?,
      email: json['user_email'] as String?,
      photo: '/uploads/images/60x60.png',
    );
  }
}
