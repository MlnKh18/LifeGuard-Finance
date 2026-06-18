import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/literacy_repository.dart';

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
  final LiteracyRepository literacyRepository;

  LiteracyCubit({required this.literacyRepository}) : super(const LiteracyProgressState());

  Future<void> loadProgress() async {
    final ids = await literacyRepository.getReadModuleIds();
    emit(LiteracyProgressState(readModuleIds: ids));
  }

  Future<void> markAsRead(String moduleId) async {
    if (state.isRead(moduleId)) return;
    await literacyRepository.markAsRead(moduleId);
    emit(state.copyWith(readModuleIds: {...state.readModuleIds, moduleId}));
  }
}
