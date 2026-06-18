import 'package:equatable/equatable.dart';

enum VaultTransactionType {
  deposit,
  withdraw,
}

class VaultTransaction extends Equatable {
  final String transactionId;
  final String vaultId;
  final String userId;
  final String userEmail;
  final VaultTransactionType type;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const VaultTransaction({
    required this.transactionId,
    required this.vaultId,
    required this.userId,
    required this.userEmail,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  factory VaultTransaction.fromJson(Map<String, dynamic> json) {
    VaultTransactionType typeEnum = VaultTransactionType.deposit;
    if (json['type'] != null) {
      typeEnum = VaultTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VaultTransactionType.deposit,
      );
    }

    return VaultTransaction(
      transactionId: json['transactionId'] as String,
      vaultId: json['vaultId'] as String,
      userId: json['userId'] as String,
      userEmail: json['userEmail'] as String,
      type: typeEnum,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'vaultId': vaultId,
      'userId': userId,
      'userEmail': userEmail,
      'type': type.name,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        transactionId,
        vaultId,
        userId,
        userEmail,
        type,
        amount,
        note,
        createdAt,
      ];
}
