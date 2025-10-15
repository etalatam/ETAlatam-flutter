import 'dart:core';

/// Modelo para representar el topic personal del usuario
class UserTopicModel {
  String userTopic;
  String recipientType;
  int recipientId;

  UserTopicModel({
    required this.userTopic,
    required this.recipientType,
    required this.recipientId,
  });

  factory UserTopicModel.fromJson(Map<String, dynamic> json) {
    return UserTopicModel(
      userTopic: json['user_topic'] as String,
      recipientType: json['recipient_type'] as String,
      recipientId: json['recipient_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_topic': userTopic,
      'recipient_type': recipientType,
      'recipient_id': recipientId,
    };
  }
}
