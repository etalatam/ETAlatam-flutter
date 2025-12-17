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
    DateTime _parseSupportTs(String tsString) {
      try {
        return DateTime.parse(tsString);
      } catch (_) {
        try {
          return DateTime.parse(tsString.replaceFirst(' ', 'T'));
        } catch (_) {
          if (tsString.contains('T') &&
              (tsString.endsWith(' AM') || tsString.endsWith(' PM'))) {
            return DateFormat("yyyy-MM-dd'T'hh:mm:ss.SSSSSS a").parse(tsString);
          }

          if (tsString.contains('T')) {
            try {
              return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS").parse(tsString);
            } catch (_) {
              return DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(tsString);
            }
          }

          try {
            return DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').parse(tsString);
          } catch (_) {
            return DateFormat('yyyy-MM-dd HH:mm:ss').parse(tsString);
          }
        }
      }
    }

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
        final DateTime parsed = _parseSupportTs(tsString);
        final DateFormat out = DateFormat('yyyy-MM-dd hh:mm a');
        parsedShortDate = out.format(parsed);
        parsedDate = out.format(parsed);
      } catch (_) {
        parsedShortDate = tsString;
        parsedDate = tsString;
      }
    }

    try {
      final dynamic rawComments = json['comments'];
      print('[HelpMessageModel.fromJson] rawComments type: ${rawComments.runtimeType}, value: $rawComments');
      if (rawComments != null && rawComments is Iterable) {
        comments = List<CommentModel>.from(
            rawComments.map((model) => CommentModel.fromJson(model)));
        comments.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        print('[HelpMessageModel.fromJson] Parsed ${comments.length} comments');
      } else {
        print('[HelpMessageModel.fromJson] No comments or invalid format');
      }
    } catch (e) {
      print('[HelpMessageModel.fromJson] Error parsing comments: $e');
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
        DateTime parsed;

        try {
          parsed = DateTime.parse(tsString);
        } catch (_) {
          if (tsString.contains('T') &&
              (tsString.endsWith(' AM') || tsString.endsWith(' PM'))) {
            parsed = DateFormat("yyyy-MM-dd'T'hh:mm:ss.SSSSSS a").parse(tsString);
          } else if (tsString.contains('T')) {
            try {
              parsed = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS").parse(tsString);
            } catch (_) {
              parsed = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(tsString);
            }
          } else {
            try {
              parsed = DateTime.parse(tsString.replaceFirst(' ', 'T'));
            } catch (_) {
              parsed = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').parse(tsString);
            }
          }
        }

        parsedShortDate = shortDateFormat.format(parsed);
        parsedDate = shortDateFormat.format(parsed);
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
