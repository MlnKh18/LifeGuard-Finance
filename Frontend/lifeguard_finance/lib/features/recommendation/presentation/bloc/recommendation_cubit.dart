import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../family_profile/domain/repositories/family_profile_repository.dart';
import '../../../fvs_dashboard/data/datasources/fvs_calculator.dart';
import '../../data/datasources/recommendation_generator.dart';
import '../../domain/entities/recommendation_entity.dart';
import 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final FamilyProfileRepository familyProfileRepository;
  final FvsCalculator fvsCalculator;
  final RecommendationGenerator recommendationGenerator;
  final HiveService hiveService;
  StreamSubscription? _profileSubscription;

  RecommendationCubit({
    required this.familyProfileRepository,
    required this.fvsCalculator,
    required this.recommendationGenerator,
    required this.hiveService,
  }) : super(RecommendationLoading()) {
    _profileSubscription = hiveService.watchKey(LocalKeys.familyProfile).listen((event) {
      loadRecommendations(showLoading: false);
    });
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }

  Future<void> loadRecommendations({bool showLoading = true}) async {
    if (showLoading) {
      emit(RecommendationLoading());
    }
    try {
      final failureOrProfile = await familyProfileRepository.getFamilyProfile();
      await failureOrProfile.fold(
        (failure) async => emit(RecommendationError(failure.message)),
        (profile) async {
          if (profile == null) {
            emit(RecommendationNoProfile());
            return;
          }

          final rawTasks = hiveService.getData(LocalKeys.recommendations);
          if (rawTasks != null) {
            final tasks = (rawTasks as List)
                .map((e) => Recommendation.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
            emit(RecommendationLoaded(tasks));
          } else {
            final score = fvsCalculator.calculate(profile);
            final tasks = recommendationGenerator.generate(score);
            await _persist(tasks);
            emit(RecommendationLoaded(tasks));
          }
        },
      );
    } catch (e) {
      emit(RecommendationError('Gagal memuat rencana mitigasi: $e'));
    }
  }

  Future<void> toggleTask(String id) async {
    final current = state;
    if (current is! RecommendationLoaded) return;

    final updated = current.tasks
        .map((task) => task.id == id ? task.copyWith(isCompleted: !task.isCompleted) : task)
        .toList();
    emit(RecommendationLoaded(updated));
    await _persist(updated);
  }

  Future<void> addCustomTask({
    required String title,
    required String description,
    required String timeline,
    required RecommendationPriority priority,
  }) async {
    final current = state;
    if (current is! RecommendationLoaded) return;

    final newTask = Recommendation(
      id: const Uuid().v4(),
      title: title,
      description: description,
      timeline: timeline,
      priority: priority,
    );
    final updated = [...current.tasks, newTask];
    emit(RecommendationLoaded(updated));
    await _persist(updated);
  }

  Future<void> _persist(List<Recommendation> tasks) async {
    await hiveService.saveData(LocalKeys.recommendations, tasks.map((t) => t.toJson()).toList());
  }
}
