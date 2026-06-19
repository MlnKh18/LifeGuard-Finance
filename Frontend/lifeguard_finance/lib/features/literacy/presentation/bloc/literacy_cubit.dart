import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/literacy_repository.dart';
import 'literacy_state.dart';

class LiteracyCubit extends Cubit<LiteracyState> {
  final LiteracyRepository repository;

  LiteracyCubit({required this.repository}) : super(LiteracyInitial());

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
      // Reload current state details or modules based on previous context if needed.
      // Typically, after markAsRead, the user navigates back and triggers loadModules,
      // or we can refresh the current detail.
      loadDetail(moduleId);
    } catch (e) {
      emit(LiteracyError(e.toString()));
    }
  }
}
