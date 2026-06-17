import 'package:get_it/get_it.dart';

// Import Core Services
import '../data/local/hive_service.dart';

// Import Services
import '../../features/fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../features/emergency_simulation/data/datasources/simulation_calculator.dart';
import '../../features/recommendation/data/datasources/recommendation_generator.dart';
import '../../features/smart_routing/data/datasources/smart_routing_calculator.dart';
import '../../features/anomaly_detection/data/datasources/anomaly_detection_service.dart';

// Import Repositories
import '../../features/family_profile/domain/repositories/family_profile_repository.dart';
import '../../features/family_profile/data/repositories/family_profile_repository_impl.dart';

// Import Use Cases
import '../../features/family_profile/domain/usecases/get_family_profile.dart';
import '../../features/family_profile/domain/usecases/save_family_profile.dart';

// Import Cubits & Blocs
import '../../features/family_profile/presentation/bloc/family_profile_bloc.dart';
import '../../features/fvs_dashboard/presentation/bloc/fvs_cubit.dart';
import '../../features/emergency_simulation/presentation/bloc/simulation_cubit.dart';
import '../../features/recommendation/presentation/bloc/recommendation_cubit.dart';
import '../../features/smart_routing/presentation/bloc/smart_routing_cubit.dart';
import '../../features/anomaly_detection/presentation/bloc/expense_cubit.dart';
import '../../features/anomaly_detection/presentation/bloc/anomaly_cubit.dart';
import '../../features/early_warning/presentation/bloc/notification_cubit.dart';
import '../../features/literacy/presentation/bloc/literacy_cubit.dart';
import '../../features/savings_vault/presentation/bloc/vault_cubit.dart';
import '../../features/community/presentation/bloc/community_cubit.dart';
import '../../features/rewards/presentation/bloc/reward_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // =========================================================================
  // REPOSITORIES
  // =========================================================================
  getIt.registerLazySingleton<FamilyProfileRepository>(
    () => FamilyProfileRepositoryImpl(getIt<HiveService>()),
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
  getIt.registerLazySingleton<SimulationCalculator>(
    () => const SimulationCalculator(),
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
  getIt.registerFactory<FamilyProfileBloc>(
    () => FamilyProfileBloc(
      getFamilyProfile: getIt<GetFamilyProfile>(),
      saveFamilyProfile: getIt<SaveFamilyProfile>(),
    ),
  );
  getIt.registerFactory<FvsCubit>(
    () => FvsCubit(),
  );
  getIt.registerFactory<SimulationCubit>(
    () => SimulationCubit(),
  );
  getIt.registerFactory<RecommendationCubit>(
    () => RecommendationCubit(),
  );
  getIt.registerFactory<SmartRoutingCubit>(
    () => SmartRoutingCubit(),
  );
  getIt.registerFactory<ExpenseCubit>(
    () => ExpenseCubit(),
  );
  getIt.registerFactory<AnomalyCubit>(
    () => AnomalyCubit(),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(),
  );
  getIt.registerFactory<LiteracyCubit>(
    () => LiteracyCubit(),
  );
  getIt.registerFactory<VaultCubit>(
    () => VaultCubit(),
  );
  getIt.registerFactory<CommunityCubit>(
    () => CommunityCubit(),
  );
  getIt.registerFactory<RewardCubit>(
    () => RewardCubit(),
  );
}
