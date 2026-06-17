import '../../domain/entities/family_profile_entity.dart';

class FamilyProfileModel extends FamilyProfileEntity {
  const FamilyProfileModel({
    required super.monthlyIncome,
    required super.monthlyExpenses,
    required super.totalFamilyMembers,
  });

  factory FamilyProfileModel.fromJson(Map<String, dynamic> json) {
    return FamilyProfileModel(
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] as num).toDouble(),
      totalFamilyMembers: json['totalFamilyMembers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'totalFamilyMembers': totalFamilyMembers,
    };
  }

  factory FamilyProfileModel.fromEntity(FamilyProfileEntity entity) {
    return FamilyProfileModel(
      monthlyIncome: entity.monthlyIncome,
      monthlyExpenses: entity.monthlyExpenses,
      totalFamilyMembers: entity.totalFamilyMembers,
    );
  }
}
