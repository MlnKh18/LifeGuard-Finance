import 'package:get_it/get_it.dart';

// Import Core Services
import '../data/local/hive_service.dart';

// Import Services
import '../../features/fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../features/emergency_simulation/data/datasources/inflation_impact_calculator.dart';
import '../../features/emergency_simulation/data/datasources/simulation_calculator.dart';
import '../../features/recommendation/data/datasources/recommendation_generator.dart';
import '../../features/smart_routing/data/datasources/smart_routing_calculator.dart';
import '../../features/anomaly_detection/data/datasources/anomaly_detection_service.dart';

// Import Repositories
import '../../features/family_profile/domain/repositories/family_profile_repository.dart';
import '../../features/family_profile/data/repositories/family_profile_repository_impl.dart';
import '../../features/settings/data/datasources/profile_local_datasource.dart';
import '../../features/settings/domain/repositories/profile_repository.dart';
import '../../features/settings/data/repositories/profile_repository_impl.dart';
import '../../features/savings_vault/domain/repositories/vault_repository.dart';
import '../../features/savings_vault/data/repositories/vault_repository_impl.dart';

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
  // REPOSITORIES
  // =========================================================================
  getIt.registerLazySingleton<FamilyProfileRepository>(
    () => FamilyProfileRepositoryImpl(getIt<HiveService>()),
  );
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(hiveService: getIt<HiveService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      localDataSource: getIt<ProfileLocalDataSource>(),
      vaultRepository: getIt<VaultRepository>(),
    ),
  );
  getIt.registerLazySingleton<VaultRepository>(
    () => VaultRepositoryImpl(
      hiveService: getIt<HiveService>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(hiveService: getIt<HiveService>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: getIt<AuthLocalDataSource>()),
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
    () => SmartRoutingCubit(),
  );
  getIt.registerFactory<AnomalyCubit>(
    () => AnomalyCubit(
      hiveService: getIt<HiveService>(),
      anomalyDetectionService: getIt<AnomalyDetectionService>(),
    ),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(),
  );
  getIt.registerFactory<LiteracyCubit>(
    () => LiteracyCubit(),
  );
  getIt.registerFactory<VaultCubit>(
    () => VaultCubit(
      hiveService: getIt<HiveService>(),
      vaultRepository: getIt<VaultRepository>(),
    ),
  );
  getIt.registerFactory<CommunityCubit>(
    () => CommunityCubit(hiveService: getIt<HiveService>()),
  );
  getIt.registerFactory<RewardCubit>(
    () => RewardCubit(),
  );
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(repository: getIt<ProfileRepository>()),
  );
}
