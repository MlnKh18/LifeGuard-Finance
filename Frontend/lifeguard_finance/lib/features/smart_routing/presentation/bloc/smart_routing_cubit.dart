import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../family_profile/domain/repositories/family_profile_repository.dart';
import '../../../fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../data/datasources/smart_routing_calculator.dart';
import 'smart_routing_state.dart';

class SmartRoutingCubit extends Cubit<SmartRoutingState> {
  final FamilyProfileRepository familyProfileRepository;
  final FvsCalculator fvsCalculator;
  final SmartRoutingCalculator smartRoutingCalculator;
  final HiveService hiveService;

  SmartRoutingCubit({
    required this.familyProfileRepository,
    required this.fvsCalculator,
    required this.smartRoutingCalculator,
    required this.hiveService,
  }) : super(SmartRoutingLoading());

  Future<void> loadPlan() async {
    emit(SmartRoutingLoading());
    final failureOrProfile = await familyProfileRepository.getFamilyProfile();
    await failureOrProfile.fold(
      (failure) async => emit(SmartRoutingError(failure.message)),
      (profile) async {
        if (profile == null) {
          emit(SmartRoutingNoProfile());
          return;
        }
        try {
          final fvsCategory = fvsCalculator.calculate(profile).category;
          final plan = smartRoutingCalculator.calculate(
            profile: profile,
            fvsCategory: fvsCategory,
          );
          await hiveService.saveData(LocalKeys.smartRoutingPlan, plan.toJson());
          emit(SmartRoutingLoaded(plan));
        } catch (e) {
          emit(SmartRoutingError('Gagal menghitung rencana alokasi: $e'));
        }
      },
    );
  }
}
