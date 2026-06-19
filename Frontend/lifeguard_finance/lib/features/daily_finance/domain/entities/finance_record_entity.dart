import 'package:equatable/equatable.dart';

enum FinanceRecordType {
  income,
  expense,
}

String financeRecordTypeLabel(FinanceRecordType type) {
  switch (type) {
    case FinanceRecordType.income:
      return 'Pendapatan';
    case FinanceRecordType.expense:
      return 'Pengeluaran';
  }
}

enum ExpenseCategory {
  food,
  transportation,
  debt,
  education,
  health,
  household,
  entertainment,
  utilities,
  other,
}

enum IncomeCategory {
  salary,
  business,
  freelance,
  gift,
  investment,
  other,
}

class FinanceRecord extends Equatable {
  final String recordId;
  final String familyId;
  final String userId;
  final String userEmail;
  final FinanceRecordType type;
  final String category; // Stored as string to support both Income/Expense
  final double amount;
  final DateTime recordDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinanceRecord({
    required this.recordId,
    required this.familyId,
    required this.userId,
    required this.userEmail,
    required this.type,
    required this.category,
    required this.amount,
    required this.recordDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  FinanceRecord copyWith({
    String? recordId,
    String? familyId,
    String? userId,
    String? userEmail,
    FinanceRecordType? type,
    String? category,
    double? amount,
    DateTime? recordDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinanceRecord(
      recordId: recordId ?? this.recordId,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      recordDate: recordDate ?? this.recordDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FinanceRecord.fromJson(Map<String, dynamic> json) {
    return FinanceRecord(
      recordId: json['recordId'] as String,
      familyId: json['familyId'] as String,
      userId: json['userId'] as String,
      userEmail: json['userEmail'] as String,
      type: FinanceRecordType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FinanceRecordType.expense,
      ),
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      recordDate: DateTime.parse(json['recordDate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordId': recordId,
      'familyId': familyId,
      'userId': userId,
      'userEmail': userEmail,
      'type': type.name,
      'category': category,
      'amount': amount,
      'recordDate': recordDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        recordId,
        familyId,
        userId,
        userEmail,
        type,
        category,
        amount,
        recordDate,
        notes,
        createdAt,
        updatedAt,
      ];
}
