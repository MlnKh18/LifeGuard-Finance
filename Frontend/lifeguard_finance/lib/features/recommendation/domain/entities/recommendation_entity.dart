import 'package:equatable/equatable.dart';

enum RecommendationPriority { high, medium, low }

class Recommendation extends Equatable {
  final String id;
  final String title;
  final String description;
  final String timeline; // '30 Hari', '60 Hari', '90 Hari'
  final RecommendationPriority priority;
  final bool isCompleted;
  final String? actionRoute; // Optional deep link, e.g. to a literacy module or Savings Vault

  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.timeline,
    required this.priority,
    this.isCompleted = false,
    this.actionRoute,
  });

  Recommendation copyWith({bool? isCompleted}) {
    return Recommendation(
      id: id,
      title: title,
      description: description,
      timeline: timeline,
      priority: priority,
      isCompleted: isCompleted ?? this.isCompleted,
      actionRoute: actionRoute,
    );
  }

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timeline: json['timeline'] as String,
      priority: RecommendationPriority.values[json['priority'] as int],
      isCompleted: json['isCompleted'] as bool? ?? false,
      actionRoute: json['actionRoute'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timeline': timeline,
      'priority': priority.index,
      'isCompleted': isCompleted,
      if (actionRoute != null) 'actionRoute': actionRoute,
    };
  }

  @override
  List<Object?> get props => [id, title, description, timeline, priority, isCompleted, actionRoute];
}
