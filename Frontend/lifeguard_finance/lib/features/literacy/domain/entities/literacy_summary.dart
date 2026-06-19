import 'package:equatable/equatable.dart';
import 'literacy_module.dart';

class LiteracySummary extends Equatable {
  final int totalModules;
  final int readModules;
  final int unreadModules;
  final double progressPercentage;
  final LiteracyModule? recommendedModule;
  final List<LiteracyModule> latestReadModules;
  final List<LiteracyModule> recommendedModules;

  const LiteracySummary({
    this.totalModules = 0,
    this.readModules = 0,
    this.unreadModules = 0,
    this.progressPercentage = 0.0,
    this.recommendedModule,
    this.latestReadModules = const [],
    this.recommendedModules = const [],
  });

  @override
  List<Object?> get props => [
        totalModules,
        readModules,
        unreadModules,
        progressPercentage,
        recommendedModule,
        latestReadModules,
        recommendedModules,
      ];
}
