import 'package:equatable/equatable.dart';

enum TransactionReviewStatus { pending, confirmed, disputed }

enum AnomalySeverity { normal, ringan, tinggi }

const List<String> expenseCategories = [
  'Makanan',
  'Transportasi',
  'Cicilan',
  'Pendidikan',
  'Kesehatan',
  'Belanja Rumah Tangga',
  'Hiburan',
  'Lainnya',
];

class ExpenseTransaction extends Equatable {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? note;
  final AnomalySeverity severity;
  final double percentageIncrease; // vs. historical average for the same category
  final TransactionReviewStatus reviewStatus;

  const ExpenseTransaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    this.severity = AnomalySeverity.normal,
    this.percentageIncrease = 0.0,
    this.reviewStatus = TransactionReviewStatus.pending,
  });

  bool get isAnomaly => severity != AnomalySeverity.normal;

  ExpenseTransaction copyWith({
    AnomalySeverity? severity,
    double? percentageIncrease,
    TransactionReviewStatus? reviewStatus,
  }) {
    return ExpenseTransaction(
      id: id,
      category: category,
      amount: amount,
      date: date,
      note: note,
      severity: severity ?? this.severity,
      percentageIncrease: percentageIncrease ?? this.percentageIncrease,
      reviewStatus: reviewStatus ?? this.reviewStatus,
    );
  }

  factory ExpenseTransaction.fromJson(Map<String, dynamic> json) {
    return ExpenseTransaction(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
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
      if (note != null) 'note': note,
      'reviewStatus': reviewStatus.name,
    };
  }

  @override
  List<Object?> get props => [id, category, amount, date, note, severity, percentageIncrease, reviewStatus];
}
