import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/literacy_repository.dart';
import '../../../rewards/domain/repositories/reward_repository.dart';
import '../../../rewards/domain/entities/reward_point.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'literacy_state.dart';

class LiteracyCubit extends Cubit<LiteracyState> {
  final LiteracyRepository repository;
  final RewardRepository rewardRepository;
  final AuthRepository authRepository;

  LiteracyCubit({
    required this.repository,
    required this.rewardRepository,
    required this.authRepository,
  }) : super(LiteracyInitial());

  Future<void> loadModules(List<String> weakestIndicators) async {
    emit(LiteracyLoading());
    try {
      final modules = await repository.getModules();
      final summary = await repository.getLiteracySummary(weakestIndicators);
      emit(LiteracyLoaded(modules, summary));
    } catch (e) {
      emit(LiteracyError(e.toString()));
    }
  }

  Future<void> loadDetail(String moduleId) async {
    emit(LiteracyLoading());
    try {
      final module = await repository.getModuleById(moduleId);
      if (module == null) {
        emit(const LiteracyError('Modul tidak ditemukan'));
        return;
      }
      
      final progress = await repository.getUserProgress();
      final isRead = progress.any((p) => p.moduleId == moduleId && p.isRead);

      emit(LiteracyDetailLoaded(module, isRead));
    } catch (e) {
      emit(LiteracyError(e.toString()));
    }
  }

  Future<void> markAsRead(String moduleId, List<String> weakestIndicators) async {
    try {
      await repository.markModuleAsRead(moduleId);
      
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        await rewardRepository.grantRewardIfNotExists(
          userId: user.userId,
          userEmail: user.email,
          userName: user.fullName,
          activityType: RewardActivityType.readLiteracy,
          sourceId: moduleId,
          points: 3,
          description: 'Menyelesaikan modul edukasi keuangan.',
        );
      }
      
      loadDetail(moduleId);
    } catch (e) {
      emit(LiteracyError(e.toString()));
    }
  }
}
