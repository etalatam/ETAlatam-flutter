import 'dart:convert';
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
  int? schoolId;
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
    this.schoolId,
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

    final dynamic rawUserId = json['id_usu'];
    final int parsedUserId =
        rawUserId is int ? rawUserId : int.tryParse('$rawUserId') ?? 0;

    final dynamic rawSchoolId = json['id_esc'] ?? json['school_id'] ?? json['id_school'];
    final int? parsedSchoolId = rawSchoolId is int
        ? rawSchoolId
        : int.tryParse('${rawSchoolId ?? ''}');

    final dynamic rawTs = json['ts'];
    final String? tsString = rawTs?.toString();
    String? parsedShortDate;
    String? parsedDate;
    if (tsString != null) {
      try {
        final DateTime utc = DateFormat('yyyy-MM-dd HH:mm').parseUtc(tsString);
        final DateTime local = utc.toLocal();
        final DateFormat out = DateFormat('yyyy-MM-dd hh:mm a');
        parsedShortDate = out.format(local);
        parsedDate = out.format(local);
      } catch (_) {
        parsedShortDate = tsString;
        parsedDate = tsString;
      }
    }

    try {
      Iterable commentsList = json['comments'];
      comments = json['comments'] != null
          ? List<CommentModel>.from(
              commentsList.map((model) => CommentModel.fromJson(model)))
          : [];
      comments.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    } catch (e) {
      print(e.toString());
    }

    return HelpMessageModel(
        message_id: json['id'] as int?,
        schoolId: parsedSchoolId,
        title: json['category_name'] as String?,
        message: json['content'] as String?,
        status: (json['status'] as String?) ?? 'Pending',
        priority: "${json['priority_id']}" as String?,
        user_id: parsedUserId,
        short_date: parsedShortDate,
        date: parsedDate,
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
    String? fixMojibake(String? input) {
      if (input == null) return null;
      if (!input.contains('Ã') && !input.contains('Â')) return input;
      try {
        return utf8.decode(latin1.encode(input));
      } catch (_) {
        return input;
      }
    }

    CommentUserModel? user;
    try {
      user = CommentUserModel.fromJson(json);
    } catch (e) {
      print("[CommentModel] ${e.toString()}");
    }

    final dynamic rawId = json['id'] ?? json['comment_id'];
    final int? parsedId = rawId is int ? rawId : int.tryParse('$rawId');

    final dynamic rawUserId = json['id_usu'];
    final int parsedUserId =
        rawUserId is int ? rawUserId : int.tryParse('$rawUserId') ?? 0;

    final DateFormat shortDateFormat = DateFormat("yyyy-MM-dd hh:mm a");
    final String? tsString = json['ts']?.toString();
    String? parsedShortDate;
    String? parsedDate;
    if (tsString != null) {
      try {
        String cleanTs = tsString;
        if (cleanTs.endsWith(' AM') || cleanTs.endsWith(' PM')) {
          cleanTs = cleanTs.substring(0, cleanTs.length - 3);
        }
        DateTime utc;
        if (cleanTs.endsWith('Z')) {
          utc = DateTime.parse(cleanTs);
        } else if (cleanTs.contains('T')) {
          utc = DateTime.parse('${cleanTs}Z');
        } else {
          utc = DateTime.parse(cleanTs.replaceFirst(' ', 'T') + 'Z');
        }
        final DateTime local = utc.toLocal();
        parsedShortDate = shortDateFormat.format(local);
        parsedDate = shortDateFormat.format(local);
      } catch (_) {
        parsedShortDate = tsString;
        parsedDate = tsString;
      }
    }

    return CommentModel(
      id: parsedId,
      comment: fixMojibake(json['txt'] as String?),
      user_id: parsedUserId,
      short_date: parsedShortDate,
      date: parsedDate,
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
    String? fixMojibake(String? input) {
      if (input == null) return null;
      if (!input.contains('Ã') && !input.contains('Â')) return input;
      try {
        return utf8.decode(latin1.encode(input));
      } catch (_) {
        return input;
      }
    }

    return CommentUserModel(
      name: fixMojibake(json['user_name'] as String?),
      email: fixMojibake(json['user_email'] as String?),
      photo: '/uploads/images/60x60.png',
    );
  }
}
