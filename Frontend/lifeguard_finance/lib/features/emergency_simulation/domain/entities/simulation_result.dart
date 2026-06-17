import '../../../fvs_dashboard/domain/entities/fvs_score_entity.dart';

class SimulationResult {
  final FvsScore fvsBefore;
  final FvsScore fvsAfter;
  final double scoreDrop;
  final double monthsEmergencyFundLasts;
  final double potentialDeficit;
  final List<String> affectedIndicators;
  final String recommendation;

  const SimulationResult({
    required this.fvsBefore,
    required this.fvsAfter,
    required this.scoreDrop,
    required this.monthsEmergencyFundLasts,
    required this.potentialDeficit,
    required this.affectedIndicators,
    required this.recommendation,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      fvsBefore: FvsScore.fromJson(Map<String, dynamic>.from(json['fvsBefore'] as Map)),
      fvsAfter: FvsScore.fromJson(Map<String, dynamic>.from(json['fvsAfter'] as Map)),
      scoreDrop: (json['scoreDrop'] as num).toDouble(),
      monthsEmergencyFundLasts: (json['monthsEmergencyFundLasts'] as num).toDouble(),
      potentialDeficit: (json['potentialDeficit'] as num).toDouble(),
      affectedIndicators: List<String>.from(json['affectedIndicators'] as List),
      recommendation: json['recommendation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fvsBefore': fvsBefore.toJson(),
      'fvsAfter': fvsAfter.toJson(),
      'scoreDrop': scoreDrop,
      'monthsEmergencyFundLasts': monthsEmergencyFundLasts,
      'potentialDeficit': potentialDeficit,
      'affectedIndicators': affectedIndicators,
      'recommendation': recommendation,
    };
  }
}
