import 'package:equatable/equatable.dart';

class SavingsVault extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;

  const SavingsVault({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
  });

  double get progress => targetAmount <= 0 ? 0.0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  bool get isCompleted => targetAmount > 0 && savedAmount >= targetAmount;

  SavingsVault copyWith({double? savedAmount}) {
    return SavingsVault(
      id: id,
      name: name,
      targetAmount: targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
    );
  }

  factory SavingsVault.fromJson(Map<String, dynamic> json) {
    return SavingsVault(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
    };
  }

  @override
  List<Object?> get props => [id, name, targetAmount, savedAmount];
}
