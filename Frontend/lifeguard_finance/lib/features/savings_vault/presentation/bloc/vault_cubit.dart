import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/savings_vault_entity.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final HiveService hiveService;

  VaultCubit({required this.hiveService}) : super(VaultLoading());

  Future<void> loadVaults() async {
    emit(VaultLoading());
    try {
      final rawVaults = hiveService.getData(LocalKeys.savingsVault);
      if (rawVaults != null) {
        final vaults = (rawVaults as List)
            .map((e) => SavingsVault.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        emit(VaultLoaded(vaults));
      } else {
        emit(const VaultLoaded([]));
      }
    } catch (e) {
      emit(VaultError('Gagal memuat data pos dana: $e'));
    }
  }

  Future<void> createVault({required String name, required double targetAmount}) async {
    final current = state;
    if (current is! VaultLoaded) return;

    final newVault = SavingsVault(
      id: const Uuid().v4(),
      name: name,
      targetAmount: targetAmount,
      savedAmount: 0,
    );
    final updated = [...current.vaults, newVault];
    emit(VaultLoaded(updated));
    await _persist(updated);
  }

  Future<void> addFunds(String id, double amount) async {
    final current = state;
    if (current is! VaultLoaded) return;

    final updated = current.vaults.map((vault) {
      if (vault.id != id) return vault;
      return vault.copyWith(savedAmount: vault.savedAmount + amount);
    }).toList();
    emit(VaultLoaded(updated));
    await _persist(updated);
  }

  Future<void> _persist(List<SavingsVault> vaults) async {
    await hiveService.saveData(LocalKeys.savingsVault, vaults.map((v) => v.toJson()).toList());
  }
}
