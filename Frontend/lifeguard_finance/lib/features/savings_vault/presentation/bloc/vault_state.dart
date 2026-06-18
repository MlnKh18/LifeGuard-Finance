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

class VaultActionSuccess extends VaultState {
  final String message;

  const VaultActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VaultTransactionsLoaded extends VaultState {
  final List<dynamic> transactions; // Later typed as VaultTransaction

  const VaultTransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}
