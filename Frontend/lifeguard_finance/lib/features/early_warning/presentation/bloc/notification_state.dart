import 'package:equatable/equatable.dart';
import '../../domain/entities/early_warning.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationLoading extends NotificationState {}

class NotificationNoProfile extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<EarlyWarning> warnings;

  const NotificationLoaded(this.warnings);

  @override
  List<Object?> get props => [warnings];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
