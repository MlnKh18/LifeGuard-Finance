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

  Future<void> addVault(SavingsVault vault) async {
    final current = state;
    if (current is! VaultLoaded) return;
    final updated = List<SavingsVault>.from(current.vaults)..add(vault);
    emit(VaultLoaded(updated));
    await _persist(updated);
  }

  Future<void> createVault({
    required String name,
    required double targetAmount,
    double initialAmount = 0.0,
    String? savingPurpose,
    SavingFrequency savingFrequency = SavingFrequency.monthly,
    double? periodicTargetAmount,
    DateTime? deadline,
    String? notes,
  }) async {
    final newVault = SavingsVault(
      id: const Uuid().v4(),
      name: name,
      targetAmount: targetAmount,
      savedAmount: initialAmount,
      savingPurpose: savingPurpose,
      savingFrequency: savingFrequency,
      periodicTargetAmount: periodicTargetAmount,
      deadline: deadline,
      notes: notes,
    );
    await addVault(newVault);
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
