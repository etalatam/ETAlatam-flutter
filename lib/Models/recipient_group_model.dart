import 'dart:core';

/// Modelo para representar un grupo de destinatarios de notificaciones
class RecipientGroupModel {
  int idGroup;
  String name;
  String? description;
  String topic;
  int memberCount;
  DateTime? addedAt;

  RecipientGroupModel({
    required this.idGroup,
    required this.name,
    this.description,
    required this.topic,
    required this.memberCount,
    this.addedAt,
  });

  factory RecipientGroupModel.fromJson(Map<String, dynamic> json) {
    return RecipientGroupModel(
      idGroup: json['id_group'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      topic: json['topic'] as String,
      memberCount: json['member_count'] as int,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_group': idGroup,
      'name': name,
      'description': description,
      'topic': topic,
      'member_count': memberCount,
      'added_at': addedAt?.toIso8601String(),
    };
  }
}
