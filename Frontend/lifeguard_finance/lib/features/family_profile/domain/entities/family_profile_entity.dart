import 'package:equatable/equatable.dart';

class FamilyProfileEntity extends Equatable {
  final double monthlyIncome;
  final double monthlyExpenses;
  final int totalFamilyMembers;

  const FamilyProfileEntity({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.totalFamilyMembers,
  });

  @override
  List<Object?> get props => [
        monthlyIncome,
        monthlyExpenses,
        totalFamilyMembers,
      ];
}
