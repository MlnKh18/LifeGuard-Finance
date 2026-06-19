import 'package:get_it/get_it.dart';

// Import Core Services
import '../network/api_client.dart';
import '../data/local/hive_service.dart';

// Import Services
import '../../features/fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../features/emergency_simulation/data/datasources/inflation_impact_calculator.dart';
import '../../features/emergency_simulation/data/datasources/simulation_calculator.dart';
import '../../features/recommendation/data/datasources/recommendation_generator.dart';
import '../../features/smart_routing/data/datasources/smart_routing_calculator.dart';
import '../../features/anomaly_detection/data/datasources/anomaly_detection_service.dart';
import '../../features/early_warning/data/datasources/early_warning_rule_checker.dart';
import '../../features/early_warning/data/datasources/notification_service.dart';

// Import Repositories
import '../../features/family_profile/domain/repositories/family_profile_repository.dart';
import '../../features/family_profile/data/repositories/family_profile_repository_impl.dart';
import '../../features/settings/data/datasources/profile_local_datasource.dart';
import '../../features/settings/domain/repositories/profile_repository.dart';
import '../../features/settings/data/repositories/profile_repository_impl.dart';
import '../../features/savings_vault/domain/repositories/vault_repository.dart';
import '../../features/savings_vault/data/repositories/vault_repository_impl.dart';
import '../../features/literacy/domain/repositories/literacy_repository.dart';
import '../../features/literacy/data/repositories/literacy_repository_impl.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/rewards/domain/repositories/reward_repository.dart';
import '../../features/rewards/data/repositories/reward_repository_impl.dart';
import '../../features/daily_finance/domain/repositories/finance_record_repository.dart';
import '../../features/daily_finance/data/repositories/finance_record_repository_impl.dart';
import '../../features/anomaly_detection/domain/repositories/anomaly_repository.dart';
import '../../features/anomaly_detection/data/repositories/anomaly_repository_impl.dart';
import '../../features/early_warning/domain/repositories/early_warning_repository.dart';
import '../../features/early_warning/data/repositories/early_warning_repository_impl.dart';
import '../../features/daily_finance/presentation/bloc/daily_finance_cubit.dart';

// Import Use Cases
import '../../features/family_profile/domain/usecases/get_family_profile.dart';
import '../../features/family_profile/domain/usecases/save_family_profile.dart';

// Import Cubits & Blocs
import '../../features/family_profile/presentation/bloc/family_profile_bloc.dart';
import '../../features/fvs_dashboard/presentation/bloc/fvs_bloc.dart';
import '../../features/emergency_simulation/presentation/bloc/simulation_bloc.dart';
import '../../features/recommendation/presentation/bloc/recommendation_cubit.dart';
import '../../features/smart_routing/presentation/bloc/smart_routing_cubit.dart';
import '../../features/anomaly_detection/presentation/bloc/anomaly_cubit.dart';
import '../../features/early_warning/presentation/bloc/notification_cubit.dart';
import '../../features/literacy/presentation/bloc/literacy_cubit.dart';
import '../../features/savings_vault/presentation/bloc/vault_cubit.dart';
import '../../features/community/presentation/bloc/community_cubit.dart';
import '../../features/rewards/presentation/bloc/reward_cubit.dart';
import '../../features/settings/presentation/bloc/profile_bloc.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // =========================================================================
  // CORE SERVICES
  // =========================================================================
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // =========================================================================
  // REPOSITORIES
  // =========================================================================
  getIt.registerLazySingleton<FamilyProfileRepository>(
    () => FamilyProfileRepositoryImpl(
      hiveService: getIt<HiveService>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(hiveService: getIt<HiveService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      localDataSource: getIt<ProfileLocalDataSource>(),
      vaultRepository: getIt<VaultRepository>(),
      rewardRepository: getIt<RewardRepository>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<VaultRepository>(
    () => VaultRepositoryImpl(
      hiveService: getIt<HiveService>(),
      authRepository: getIt<AuthRepository>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(hiveService: getIt<HiveService>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: getIt<AuthLocalDataSource>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<LiteracyRepository>(
    () => LiteracyRepositoryImpl(
      hiveService: getIt<HiveService>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(
      hiveService: getIt<HiveService>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<FinanceRecordRepository>(
    () => FinanceRecordRepositoryImpl(
      hiveService: getIt<HiveService>(),
      authRepository: getIt<AuthRepository>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<AnomalyRepository>(
    () => AnomalyRepositoryImpl(
      hiveService: getIt<HiveService>(),
      financeRecordRepository: getIt<FinanceRecordRepository>(),
      authRepository: getIt<AuthRepository>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<EarlyWarningRepository>(
    () => EarlyWarningRepositoryImpl(
      hiveService: getIt<HiveService>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<RewardRepository>(
    () => RewardRepositoryImpl(
      hiveService: getIt<HiveService>(),
      authRepository: getIt<AuthRepository>(),
      apiClient: getIt<ApiClient>(),
    ),
  );

  // =========================================================================
  // USE CASES
  // =========================================================================
  getIt.registerLazySingleton<GetFamilyProfile>(
    () => GetFamilyProfile(getIt<FamilyProfileRepository>()),
  );
  getIt.registerLazySingleton<SaveFamilyProfile>(
    () => SaveFamilyProfile(getIt<FamilyProfileRepository>()),
  );

  // =========================================================================
  // SERVICES (Lazy Singletons)
  // =========================================================================
  getIt.registerLazySingleton<FvsCalculator>(
    () => const FvsCalculator(),
  );
  getIt.registerLazySingleton<InflationImpactCalculator>(
    () => InflationImpactCalculator(getIt<FvsCalculator>()),
  );
  getIt.registerLazySingleton<SimulationCalculator>(
    () => SimulationCalculator(getIt<FvsCalculator>(), getIt<InflationImpactCalculator>()),
  );
  getIt.registerLazySingleton<RecommendationGenerator>(
    () => const RecommendationGenerator(),
  );
  getIt.registerLazySingleton<SmartRoutingCalculator>(
    () => const SmartRoutingCalculator(),
  );
  getIt.registerLazySingleton<AnomalyDetectionService>(
    () => const AnomalyDetectionService(),
  );
  getIt.registerLazySingleton<EarlyWarningRuleChecker>(
    () => const EarlyWarningRuleChecker(),
  );

  // =========================================================================
  // BLOCS / CUBITS (Factory)
  // =========================================================================
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(repository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<FamilyProfileBloc>(
    () => FamilyProfileBloc(
      getFamilyProfile: getIt<GetFamilyProfile>(),
      saveFamilyProfile: getIt<SaveFamilyProfile>(),
    ),
  );
  getIt.registerFactory<FvsBloc>(
    () => FvsBloc(
      familyProfileRepository: getIt<FamilyProfileRepository>(),
      fvsCalculator: getIt<FvsCalculator>(),
      hiveService: getIt<HiveService>(),
    ),
  );
  getIt.registerFactory<SimulationBloc>(
    () => SimulationBloc(
      familyProfileRepository: getIt<FamilyProfileRepository>(),
      simulationCalculator: getIt<SimulationCalculator>(),
      hiveService: getIt<HiveService>(),
    ),
  );
  getIt.registerFactory<RecommendationCubit>(
    () => RecommendationCubit(
      familyProfileRepository: getIt<FamilyProfileRepository>(),
      fvsCalculator: getIt<FvsCalculator>(),
      recommendationGenerator: getIt<RecommendationGenerator>(),
      hiveService: getIt<HiveService>(),
    ),
  );
  getIt.registerFactory<SmartRoutingCubit>(
    () => SmartRoutingCubit(
      familyProfileRepository: getIt<FamilyProfileRepository>(),
      fvsCalculator: getIt<FvsCalculator>(),
      smartRoutingCalculator: getIt<SmartRoutingCalculator>(),
      hiveService: getIt<HiveService>(),
    ),
  );
  getIt.registerFactory<AnomalyCubit>(
    () => AnomalyCubit(
      hiveService: getIt<HiveService>(),
      anomalyDetectionService: getIt<AnomalyDetectionService>(),
      financeRecordRepository: getIt<FinanceRecordRepository>(),
      anomalyRepository: getIt<AnomalyRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(
      familyProfileRepository: getIt<FamilyProfileRepository>(),
      fvsCalculator: getIt<FvsCalculator>(),
      anomalyDetectionService: getIt<AnomalyDetectionService>(),
      ruleChecker: getIt<EarlyWarningRuleChecker>(),
      notificationService: getIt<NotificationService>(),
      hiveService: getIt<HiveService>(),
    ),
  );
  getIt.registerFactory<LiteracyCubit>(
    () => LiteracyCubit(
      repository: getIt<LiteracyRepository>(),
      rewardRepository: getIt<RewardRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<DailyFinanceCubit>(
    () => DailyFinanceCubit(
      repository: getIt<FinanceRecordRepository>(),
      anomalyRepository: getIt<AnomalyRepository>(),
      earlyWarningRepository: getIt<EarlyWarningRepository>(),
      authRepository: getIt<AuthRepository>(),
      hiveService: getIt<HiveService>(),
    ),
  );
  getIt.registerLazySingleton<VaultCubit>(
    () => VaultCubit(
      hiveService: getIt<HiveService>(),
      vaultRepository: getIt<VaultRepository>(),
      rewardRepository: getIt<RewardRepository>(),
    ),
  );
  getIt.registerFactory<CommunityCubit>(
    () => CommunityCubit(
      communityRepository: getIt<CommunityRepository>(),
      rewardRepository: getIt<RewardRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<RewardCubit>(
    () => RewardCubit(rewardRepository: getIt<RewardRepository>()),
  );
  getIt.registerLazySingleton<ProfileBloc>(
    () => ProfileBloc(repository: getIt<ProfileRepository>()),
  );
}
