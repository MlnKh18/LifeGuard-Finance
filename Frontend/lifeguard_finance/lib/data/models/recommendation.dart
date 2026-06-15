class Recommendation {
  final String? recommendationId;
  final String? scoreId;
  final String title;
  final String recommendationText;
  final String priorityLevel; // 'Tinggi', 'Sedang', 'Rendah'
  final String actionPeriod; // '30 Hari', '60 Hari', '90 Hari'
  final bool isChecked;
  final String category; // 'Dana Darurat', 'Utang', 'Proteksi', 'Pengeluaran'

  Recommendation({
    this.recommendationId,
    this.scoreId,
    required this.title,
    required this.recommendationText,
    required this.priorityLevel,
    required this.actionPeriod,
    this.isChecked = false,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'recommendation_id': recommendationId,
      'score_id': scoreId,
      'title': title,
      'recommendation_text': recommendationText,
      'priority_level': priorityLevel,
      'action_period': actionPeriod,
      'is_checked': isChecked ? 1 : 0,
      'category': category,
    };
  }

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      recommendationId: map['recommendation_id'] as String?,
      scoreId: map['score_id'] as String?,
      title: map['title'] as String,
      recommendationText: map['recommendation_text'] as String,
      priorityLevel: map['priority_level'] as String,
      actionPeriod: map['action_period'] as String,
      isChecked: map['is_checked'] == 1,
      category: map['category'] as String,
    );
  }

  Recommendation copyWith({
    String? recommendationId,
    String? scoreId,
    String? title,
    String? recommendationText,
    String? priorityLevel,
    String? actionPeriod,
    bool? isChecked,
    String? category,
  }) {
    return Recommendation(
      recommendationId: recommendationId ?? this.recommendationId,
      scoreId: scoreId ?? this.scoreId,
      title: title ?? this.title,
      recommendationText: recommendationText ?? this.recommendationText,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      actionPeriod: actionPeriod ?? this.actionPeriod,
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
    );
  }
}
