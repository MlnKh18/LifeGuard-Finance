import 'package:equatable/equatable.dart';

enum SavingFrequency { weekly, monthly, yearly }

class SavingsVault extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String? savingPurpose;
  final SavingFrequency savingFrequency;
  final double? periodicTargetAmount;
  final DateTime? deadline;
  final String? notes;

  const SavingsVault({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.savingPurpose,
    this.savingFrequency = SavingFrequency.monthly,
    this.periodicTargetAmount,
    this.deadline,
    this.notes,
  });

  double get progress => targetAmount <= 0 ? 0.0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  bool get isCompleted => targetAmount > 0 && savedAmount >= targetAmount;

  double get remainingAmount => targetAmount > savedAmount ? targetAmount - savedAmount : 0.0;

  double get recommendedContribution {
    if (periodicTargetAmount != null && periodicTargetAmount! > 0) {
      return periodicTargetAmount!;
    }
    if (deadline != null) {
      final now = DateTime.now();
      if (deadline!.isAfter(now)) {
        final days = deadline!.difference(now).inDays;
        if (days <= 0) return remainingAmount;
        
        double periods = 1.0;
        if (savingFrequency == SavingFrequency.weekly) {
          periods = days / 7.0;
        } else if (savingFrequency == SavingFrequency.monthly) {
          periods = days / 30.0;
        } else if (savingFrequency == SavingFrequency.yearly) {
          periods = days / 365.0;
        }
        
        if (periods < 1.0) periods = 1.0;
        return remainingAmount / periods;
      }
    }
    return 0.0;
  }

  SavingsVault copyWith({
    double? savedAmount,
    String? savingPurpose,
    SavingFrequency? savingFrequency,
    double? periodicTargetAmount,
    DateTime? deadline,
    String? notes,
  }) {
    return SavingsVault(
      id: id,
      name: name,
      targetAmount: targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      savingPurpose: savingPurpose ?? this.savingPurpose,
      savingFrequency: savingFrequency ?? this.savingFrequency,
      periodicTargetAmount: periodicTargetAmount ?? this.periodicTargetAmount,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
    );
  }

  factory SavingsVault.fromJson(Map<String, dynamic> json) {
    SavingFrequency freq = SavingFrequency.monthly;
    if (json['savingFrequency'] != null) {
      freq = SavingFrequency.values.firstWhere(
        (e) => e.name == json['savingFrequency'],
        orElse: () => SavingFrequency.monthly,
      );
    }

    return SavingsVault(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num).toDouble(),
      savingPurpose: json['savingPurpose'] as String?,
      savingFrequency: freq,
      periodicTargetAmount: json['periodicTargetAmount'] != null ? (json['periodicTargetAmount'] as num).toDouble() : null,
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'savingPurpose': savingPurpose,
      'savingFrequency': savingFrequency.name,
      'periodicTargetAmount': periodicTargetAmount,
      'deadline': deadline?.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
    id, name, targetAmount, savedAmount, savingPurpose, 
    savingFrequency, periodicTargetAmount, deadline, notes
  ];
}
