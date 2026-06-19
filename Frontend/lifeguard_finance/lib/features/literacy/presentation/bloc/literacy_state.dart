import 'package:equatable/equatable.dart';
import '../../domain/entities/literacy_module.dart';
import '../../domain/entities/literacy_summary.dart';

abstract class LiteracyState extends Equatable {
  const LiteracyState();

  @override
  List<Object?> get props => [];
}

class LiteracyInitial extends LiteracyState {}

class LiteracyLoading extends LiteracyState {}

class LiteracyLoaded extends LiteracyState {
  final List<LiteracyModule> modules;
  final LiteracySummary summary;

  const LiteracyLoaded(this.modules, this.summary);

  @override
  List<Object?> get props => [modules, summary];
}

class LiteracyDetailLoaded extends LiteracyState {
  final LiteracyModule module;
  final bool isRead;

  const LiteracyDetailLoaded(this.module, this.isRead);

  @override
  List<Object?> get props => [module, isRead];
}

class LiteracyError extends LiteracyState {
  final String message;

  const LiteracyError(this.message);

  @override
  List<Object?> get props => [message];
}
