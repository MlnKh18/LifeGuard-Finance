import 'package:equatable/equatable.dart';

class SmartRoutingAllocation extends Equatable {
  final String category;
  final double percentage;
  final double amount;

  const SmartRoutingAllocation({
    required this.category,
    required this.percentage,
    required this.amount,
  });

  factory SmartRoutingAllocation.fromJson(Map<String, dynamic> json) {
    return SmartRoutingAllocation(
      category: json['category'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'percentage': percentage,
      'amount': amount,
    };
  }

  @override
  List<Object?> get props => [category, percentage, amount];
}

class SmartRoutingPlan extends Equatable {
  final String fvsCategory;
  final double totalIncome;
  final List<SmartRoutingAllocation> allocations;
  final DateTime generatedAt;

  const SmartRoutingPlan({
    required this.fvsCategory,
    required this.totalIncome,
    required this.allocations,
    required this.generatedAt,
  });

  factory SmartRoutingPlan.fromJson(Map<String, dynamic> json) {
    return SmartRoutingPlan(
      fvsCategory: json['fvsCategory'] as String,
      totalIncome: (json['totalIncome'] as num).toDouble(),
      allocations: (json['allocations'] as List)
          .map((e) => SmartRoutingAllocation.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fvsCategory': fvsCategory,
      'totalIncome': totalIncome,
      'allocations': allocations.map((a) => a.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [fvsCategory, totalIncome, allocations, generatedAt];
}
