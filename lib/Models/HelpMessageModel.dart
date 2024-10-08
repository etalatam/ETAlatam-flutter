import 'dart:core';

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
  
  factory HelpMessageModel.fromJson( json) {

    Iterable commentsList = json['comments'];
    List<CommentModel>? comments = json['comments'] != null ?  List<CommentModel>.from(commentsList.map((model)=>  CommentModel.fromJson(model))) : [];
   

    return HelpMessageModel(
      message_id: json['message_id'] as int?,
      title: json['subject'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String?,
      priority: json['priority'] as String?,
      user_id: json['user_id'] as int,
      short_date: json['short_date'] as String?,
      date: json['date'] as String?,
      comments: comments
    );
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
  
  factory CommentModel.fromJson( json) {

    CommentUserModel user = json['user'] != null ? CommentUserModel.fromJson(json['user']) : CommentUserModel();

    return CommentModel(
      id: json['id'] as int?,
      comment: json['comment'] as String?,
      user_id: json['user_id'] as int,
      short_date: json['short_date'] as String?,
      date: json['date'] as String?,
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
  
  factory CommentUserModel.fromJson( json) {
    return CommentUserModel(
      name: json['first_name'] as String?,
      email: json['email'] as String?,
      photo: '/uploads/images/60x60.png',
    );
  }

}


