import 'package:equatable/equatable.dart';

enum TransactionReviewStatus { pending, confirmed, disputed }

class ExpenseTransaction extends Equatable {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final bool isAnomaly;
  final double? zScore;
  final TransactionReviewStatus reviewStatus;

  const ExpenseTransaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.isAnomaly = false,
    this.zScore,
    this.reviewStatus = TransactionReviewStatus.pending,
  });

  ExpenseTransaction copyWith({bool? isAnomaly, double? zScore, TransactionReviewStatus? reviewStatus}) {
    return ExpenseTransaction(
      id: id,
      category: category,
      amount: amount,
      date: date,
      isAnomaly: isAnomaly ?? this.isAnomaly,
      zScore: zScore ?? this.zScore,
      reviewStatus: reviewStatus ?? this.reviewStatus,
    );
  }

  factory ExpenseTransaction.fromJson(Map<String, dynamic> json) {
    return ExpenseTransaction(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      reviewStatus: TransactionReviewStatus.values.firstWhere(
        (s) => s.name == json['reviewStatus'],
        orElse: () => TransactionReviewStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'reviewStatus': reviewStatus.name,
    };
  }

  @override
  List<Object?> get props => [id, category, amount, date, isAnomaly, zScore, reviewStatus];
}
