import 'package:equatable/equatable.dart';

enum SavingFrequency { weekly, monthly, yearly }

enum SavingsVaultScope { family, personal }

enum VaultPriority { high, medium, low }

const List<String> vaultCategories = [
  'Dana Darurat',
  'Pendidikan Anak',
  'Kesehatan',
  'Pensiun',
  'Kebutuhan Keluarga Lain',
];

class SavingsVault extends Equatable {
  final String id;
  final String? familyId;
  final String? ownerUserId;
  final String? ownerEmail;
  final String? ownerName;
  final SavingsVaultScope scope;
  
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String? savingPurpose;
  final String? category;
  final SavingFrequency savingFrequency;
  final double? periodicTargetAmount;
  final DateTime? deadline;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VaultPriority priority;
  final String? iconName;

  const SavingsVault({
    required this.id,
    this.familyId,
    this.ownerUserId,
    this.ownerEmail,
    this.ownerName,
    this.scope = SavingsVaultScope.family,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.savingPurpose,
    this.category,
    this.savingFrequency = SavingFrequency.monthly,
    this.periodicTargetAmount,
    this.deadline,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.priority = VaultPriority.medium,
    this.iconName,
  });

  double get progress => targetAmount <= 0 ? 0.0 : (savedAmount / targetAmount).clamp(0.0, 1.0);
  double get progressPercentage => progress * 100;

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
    String? familyId,
    String? ownerUserId,
    String? ownerEmail,
    String? ownerName,
    SavingsVaultScope? scope,
    String? name,
    double? targetAmount,
    double? savedAmount,
    String? savingPurpose,
    String? category,
    SavingFrequency? savingFrequency,
    double? periodicTargetAmount,
    DateTime? deadline,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    VaultPriority? priority,
    String? iconName,
  }) {
    return SavingsVault(
      id: id,
      familyId: familyId ?? this.familyId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerName: ownerName ?? this.ownerName,
      scope: scope ?? this.scope,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      savingPurpose: savingPurpose ?? this.savingPurpose,
      category: category ?? this.category,
      savingFrequency: savingFrequency ?? this.savingFrequency,
      periodicTargetAmount: periodicTargetAmount ?? this.periodicTargetAmount,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      iconName: iconName ?? this.iconName,
    );
  }

  static SavingsVaultScope parseVaultScope(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == 'personal' || raw == 'tabungan_pribadi') return SavingsVaultScope.personal;
    return SavingsVaultScope.family;
  }

  static SavingFrequency parseSavingFrequency(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == 'weekly' || raw == 'mingguan') return SavingFrequency.weekly;
    if (raw == 'yearly' || raw == 'tahunan') return SavingFrequency.yearly;
    return SavingFrequency.monthly;
  }

  static VaultPriority parsePriority(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == 'high' || raw == 'tinggi') return VaultPriority.high;
    if (raw == 'low' || raw == 'rendah') return VaultPriority.low;
    return VaultPriority.medium;
  }

  factory SavingsVault.fromJson(Map<String, dynamic> json, {String? defaultOwnerId, String? defaultOwnerEmail, String? defaultFamilyId}) {
    final freq = parseSavingFrequency(json['savingFrequency']);
    final scopeEnum = parseVaultScope(json['scope']);

    return SavingsVault(
      id: json['id']?.toString() ?? json['vaultId']?.toString() ?? '',
      familyId: (json['familyId']?.toString().isEmpty ?? true) ? defaultFamilyId : json['familyId']?.toString(),
      ownerUserId: (json['ownerUserId']?.toString().isEmpty ?? true) ? defaultOwnerId : json['ownerUserId']?.toString(),
      ownerEmail: (json['ownerEmail']?.toString().isEmpty ?? true) ? defaultOwnerEmail : json['ownerEmail']?.toString(),
      ownerName: json['ownerName']?.toString(),
      scope: scopeEnum,
      name: json['name'] as String? ?? json['vaultName'] as String? ?? '',
      targetAmount: json['targetAmount'] != null ? (json['targetAmount'] as num).toDouble() : 0.0,
      savedAmount: json['savedAmount'] != null ? (json['savedAmount'] as num).toDouble() : 0.0,
      savingPurpose: json['savingPurpose'] as String? ?? json['notes'] as String? ?? 'Tujuan belum diisi',
      category: json['category'] as String?,
      savingFrequency: freq,
      periodicTargetAmount: json['periodicTargetAmount'] != null ? (json['periodicTargetAmount'] as num).toDouble() : (json['recommendedContribution'] != null ? (json['recommendedContribution'] as num).toDouble() : 0.0),
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      priority: parsePriority(json['priority']),
      iconName: json['iconName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'ownerUserId': ownerUserId,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
      'scope': scope.name,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'savingPurpose': savingPurpose,
      'category': category,
      'savingFrequency': savingFrequency.name,
      'periodicTargetAmount': periodicTargetAmount,
      'deadline': deadline?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'priority': priority.name,
      'iconName': iconName,
    };
  }

  @override
  List<Object?> get props => [
    id, familyId, ownerUserId, ownerEmail, ownerName, scope,
    name, targetAmount, savedAmount, savingPurpose, category,
    savingFrequency, periodicTargetAmount, deadline, notes,
    createdAt, updatedAt, priority, iconName,
  ];
}
