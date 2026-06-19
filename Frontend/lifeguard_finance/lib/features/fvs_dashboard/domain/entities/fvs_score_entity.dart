import 'package:equatable/equatable.dart';

class FvsScore extends Equatable {
  final double score;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;
  final double s7;
  final String category;
  final String description;
  final DateTime? calculatedAt;

  const FvsScore({
    required this.score,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.s6,
    required this.s7,
    required this.category,
    required this.description,
    this.calculatedAt,
  });

  factory FvsScore.fromJson(Map<String, dynamic> json) {
    return FvsScore(
      score: (json['score'] as num).toDouble(),
      s1: (json['s1'] as num).toDouble(),
      s2: (json['s2'] as num).toDouble(),
      s3: (json['s3'] as num).toDouble(),
      s4: (json['s4'] as num).toDouble(),
      s5: (json['s5'] as num).toDouble(),
      s6: (json['s6'] as num).toDouble(),
      s7: (json['s7'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      calculatedAt: json['calculatedAt'] != null ? DateTime.parse(json['calculatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      's1': s1,
      's2': s2,
      's3': s3,
      's4': s4,
      's5': s5,
      's6': s6,
      's7': s7,
      'category': category,
      'description': description,
      'calculatedAt': (calculatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  List<String> get weakestIndicators {
    final scores = {
      'S1': s1,
      'S2': s2,
      'S3': s3,
      'S4': s4,
      'S5': s5,
      'S6': s6,
      'S7': s7,
    };
    final List<String> weakest = [];
    final sortedKeys = scores.keys.toList()
      ..sort((a, b) => scores[a]!.compareTo(scores[b]!));
    for (var key in sortedKeys) {
      if (scores[key]! < 60) {
        weakest.add(key);
      }
    }
    if (weakest.isEmpty && sortedKeys.isNotEmpty) {
      weakest.add(sortedKeys.first);
    }
    return weakest;
  }

  @override
  List<Object?> get props => [
        score,
        s1,
        s2,
        s3,
        s4,
        s5,
        s6,
        s7,
        category,
        description,
        calculatedAt,
      ];
}
