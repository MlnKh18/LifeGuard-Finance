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
    };
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
      ];
}
