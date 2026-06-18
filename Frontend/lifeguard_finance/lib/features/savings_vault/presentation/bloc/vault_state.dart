import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_vault_entity.dart';

abstract class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object?> get props => [];
}

class VaultLoading extends VaultState {}

class VaultLoaded extends VaultState {
  final List<SavingsVault> vaults;

  const VaultLoaded(this.vaults);

  @override
  List<Object?> get props => [vaults];
}

class VaultError extends VaultState {
  final String message;

  const VaultError(this.message);

  @override
  List<Object?> get props => [message];
}
