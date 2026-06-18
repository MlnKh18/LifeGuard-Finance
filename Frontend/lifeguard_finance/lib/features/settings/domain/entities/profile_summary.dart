import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/entities/family_account.dart';
import '../../../auth/domain/entities/family_invitation.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../savings_vault/domain/entities/savings_vault_entity.dart';
import '../../../community/domain/entities/community_post.dart';
import '../../../fvs_dashboard/domain/entities/fvs_score_entity.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../literacy/domain/entities/literacy_module.dart';

class ProfileSummary extends Equatable {
  final AppUser? currentUser;
  final FamilyAccount? family;
  final FamilyFinanceProfile? familyProfile;
  final FvsScore? latestFvs;
  
  final String userName;
  final String email;
  final UserRole role;
  final String familyName;
  final String familyCode;
  
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
  final DateTime? latestFvsCalculatedAt;
  final List<String> weakestIndicators;
  
  final List<SavingsVault> allVaults;
  final List<SavingsVault> familyVaults;
  final List<SavingsVault> personalVaults;
  final List<SavingsVault> visibleVaults;
  
  final double totalFamilyVaultTarget;
  final double totalFamilyVaultSaved;
  final double totalPersonalVaultTarget;
  final double totalPersonalVaultSaved;
  
  final int familyVaultCount;
  final int personalVaultCount;

  final List<dynamic> literacyProgress;
  final List<LiteracyModule> recommendedLiteracyModules;
  final List<CommunityPost> communityPosts;
  final List<dynamic> communityComments;
  final List<AppUser> familyMembers;
  final List<FamilyInvitation> familyInvitations;
  final List<dynamic> rewardTransactions;
  
  final bool canAccessCommunity;
  final bool canManageFamilyMembers;
  final bool canEditFamilyProfile;
  final bool canDeleteFamilyData;

  const ProfileSummary({
    this.currentUser,
    this.family,
    this.familyProfile,
    this.latestFvs,
    required this.userName,
    required this.email,
    required this.role,
    required this.familyName,
    required this.familyCode,
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
    this.latestFvsCalculatedAt,
    this.weakestIndicators = const [],
    this.allVaults = const [],
    this.familyVaults = const [],
    this.personalVaults = const [],
    this.visibleVaults = const [],
    this.totalFamilyVaultTarget = 0.0,
    this.totalFamilyVaultSaved = 0.0,
    this.totalPersonalVaultTarget = 0.0,
    this.totalPersonalVaultSaved = 0.0,
    this.familyVaultCount = 0,
    this.personalVaultCount = 0,
    this.literacyProgress = const [],
    this.recommendedLiteracyModules = const [],
    this.communityPosts = const [],
    this.communityComments = const [],
    this.familyMembers = const [],
    this.familyInvitations = const [],
    this.rewardTransactions = const [],
    this.canAccessCommunity = false,
    this.canManageFamilyMembers = false,
    this.canEditFamilyProfile = false,
    this.canDeleteFamilyData = false,
  });

  @override
  List<Object?> get props => [
        currentUser,
        family,
        familyProfile,
        latestFvs,
        userName,
        email,
        role,
        familyName,
        familyCode,
        totalRewardPoints,
        activeBadge,
        fixedIncome,
        variableIncome,
        totalIncome,
        monthlyExpense,
        monthlyDebtPayment,
        liquidSavings,
        dependentsCount,
        hasBpjs,
        hasInsurance,
        latestFvsScore,
        latestFvsCategory,
        latestFvsCalculatedAt,
        weakestIndicators,
        allVaults,
        familyVaults,
        personalVaults,
        visibleVaults,
        totalFamilyVaultTarget,
        totalFamilyVaultSaved,
        totalPersonalVaultTarget,
        totalPersonalVaultSaved,
        familyVaultCount,
        personalVaultCount,
        literacyProgress,
        recommendedLiteracyModules,
        communityPosts,
        communityComments,
        familyMembers,
        familyInvitations,
        rewardTransactions,
        canAccessCommunity,
        canManageFamilyMembers,
        canEditFamilyProfile,
        canDeleteFamilyData,
      ];
}
