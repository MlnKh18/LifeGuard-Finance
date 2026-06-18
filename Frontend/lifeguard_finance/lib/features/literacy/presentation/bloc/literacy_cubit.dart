import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';

class LiteracyProgressState extends Equatable {
  final Set<String> readModuleIds;

  const LiteracyProgressState({this.readModuleIds = const {}});

  int get readCount => readModuleIds.length;

  bool isRead(String moduleId) => readModuleIds.contains(moduleId);

  LiteracyProgressState copyWith({Set<String>? readModuleIds}) {
    return LiteracyProgressState(readModuleIds: readModuleIds ?? this.readModuleIds);
  }

  @override
  List<Object?> get props => [readModuleIds];
}

class LiteracyCubit extends Cubit<LiteracyProgressState> {
  final HiveService hiveService;

  LiteracyCubit({required this.hiveService}) : super(const LiteracyProgressState());

  void loadProgress() {
    final raw = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.literacyProgress);
    final ids = (raw?['readModuleIds'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? <String>{};
    emit(LiteracyProgressState(readModuleIds: ids));
  }

  Future<void> markAsRead(String moduleId) async {
    if (state.isRead(moduleId)) return;
    final updated = state.copyWith(readModuleIds: {...state.readModuleIds, moduleId});
    emit(updated);
    await hiveService.saveData(LocalKeys.literacyProgress, {
      'readCount': updated.readCount,
      'readModuleIds': updated.readModuleIds.toList(),
    });
  }
}
