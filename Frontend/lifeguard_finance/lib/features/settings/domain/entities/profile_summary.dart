import 'package:equatable/equatable.dart';

class ProfileSummary extends Equatable {
  final String userName;
  final String email;
  final int totalRewardPoints;
  final String activeBadge;
  
  final double fixedIncome;
  final double variableIncome;
  final double totalIncome;
  final double monthlyExpense;
  final double monthlyDebtPayment;
  final double liquidSavings;
  final int dependentsCount;
  final bool hasBpjs;
  final bool hasInsurance;
  
  final double latestFvsScore;
  final String latestFvsCategory;
  
  final int vaultCount;
  final double totalVaultTarget;
  final double totalVaultSaved;
  final double averageVaultProgress;
  
  final int literacyReadCount;
  final int literacyTotalCount;
  
  final int communityPostCount;
  final int communityCommentCount;

  const ProfileSummary({
    this.userName = 'Pengguna LifeGuard',
    this.email = 'Belum diatur',
    this.totalRewardPoints = 0,
    this.activeBadge = 'Starter Saver',
    
    this.fixedIncome = 0.0,
    this.variableIncome = 0.0,
    this.totalIncome = 0.0,
    this.monthlyExpense = 0.0,
    this.monthlyDebtPayment = 0.0,
    this.liquidSavings = 0.0,
    this.dependentsCount = 0,
    this.hasBpjs = false,
    this.hasInsurance = false,
    
    this.latestFvsScore = -1.0,
    this.latestFvsCategory = 'Belum Tersedia',
    
    this.vaultCount = 0,
    this.totalVaultTarget = 0.0,
    this.totalVaultSaved = 0.0,
    this.averageVaultProgress = 0.0,
    
    this.literacyReadCount = 0,
    this.literacyTotalCount = 0,
    
    this.communityPostCount = 0,
    this.communityCommentCount = 0,
  });

  @override
  List<Object?> get props => [
    userName, email, totalRewardPoints, activeBadge,
    fixedIncome, variableIncome, totalIncome, monthlyExpense, monthlyDebtPayment,
    liquidSavings, dependentsCount, hasBpjs, hasInsurance,
    latestFvsScore, latestFvsCategory,
    vaultCount, totalVaultTarget, totalVaultSaved, averageVaultProgress,
    literacyReadCount, literacyTotalCount,
    communityPostCount, communityCommentCount,
  ];
}
