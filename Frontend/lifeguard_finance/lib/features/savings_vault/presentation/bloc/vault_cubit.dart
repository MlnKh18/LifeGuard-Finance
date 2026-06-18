import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../domain/entities/savings_vault_entity.dart';
import '../../domain/entities/vault_transaction.dart';
import 'vault_state.dart';

import '../../domain/repositories/vault_repository.dart';

class VaultCubit extends Cubit<VaultState> {
  final HiveService hiveService;
  final VaultRepository vaultRepository;

  VaultCubit({
    required this.hiveService,
    required this.vaultRepository,
  }) : super(VaultLoading());

  Future<void> loadVaults() async {
    emit(VaultLoading());
    try {
      final vaults = await vaultRepository.getVaults();
      emit(VaultLoaded(vaults));
    } catch (e) {
      emit(VaultError('Gagal memuat data pos dana: $e'));
    }
  }

  Future<void> addVault(SavingsVault vault) async {
    await vaultRepository.createVault(vault);
    await loadVaults();
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
    SavingsVaultScope scope = SavingsVaultScope.family,
    String? familyId,
    String? ownerUserId,
    String? ownerEmail,
    String? ownerName,
    VaultPriority priority = VaultPriority.medium,
    String? iconName,
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
      scope: scope,
      familyId: familyId,
      ownerUserId: ownerUserId,
      ownerEmail: ownerEmail,
      ownerName: ownerName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      priority: priority,
      iconName: iconName,
    );
    await addVault(newVault);
  }

  Future<void> addDeposit(String vaultId, double amount, {String? note}) async {
    if (amount <= 0) {
      emit(const VaultError('Nominal setoran harus lebih dari 0.'));
      loadVaults(); // restore state
      return;
    }

    final vaults = await vaultRepository.getVaults();
    int index = vaults.indexWhere((v) => v.id == vaultId);
    if (index == -1) return;

    final vault = vaults[index];
    final newAmount = vault.savedAmount + amount;
    
    // Create transaction
    await _saveTransaction(vaultId, VaultTransactionType.deposit, amount, note);

    final updatedVault = vault.copyWith(savedAmount: newAmount, updatedAt: DateTime.now());
    await vaultRepository.updateVault(updatedVault);
    
    emit(const VaultActionSuccess('Berhasil menambah setoran.'));
    loadVaults();
  }

  Future<void> subtractBalance(String vaultId, double amount, {String? note}) async {
    if (amount <= 0) {
      emit(const VaultError('Nominal penarikan harus lebih dari 0.'));
      loadVaults(); // restore state
      return;
    }

    final vaults = await vaultRepository.getVaults();
    int index = vaults.indexWhere((v) => v.id == vaultId);
    if (index == -1) return;

    final vault = vaults[index];
    if (vault.savedAmount < amount) {
      emit(const VaultError('Saldo tidak mencukupi untuk penarikan ini.'));
      loadVaults();
      return;
    }

    final newAmount = vault.savedAmount - amount;

    // Create transaction
    await _saveTransaction(vaultId, VaultTransactionType.withdraw, amount, note);

    final updatedVault = vault.copyWith(savedAmount: newAmount, updatedAt: DateTime.now());
    await vaultRepository.updateVault(updatedVault);

    emit(const VaultActionSuccess('Berhasil menarik dana.'));
    loadVaults();
  }

  Future<void> updateVault(SavingsVault vault) async {
    await vaultRepository.updateVault(vault);
    emit(const VaultActionSuccess('Berhasil memperbarui pos tabungan.'));
    loadVaults();
  }

  Future<void> deleteVault(String vaultId) async {
    final vaults = await vaultRepository.getVaults();
    final updatedVaults = vaults.where((v) => v.id != vaultId).toList();
    await vaultRepository.saveVaults(updatedVaults);
    emit(const VaultActionSuccess('Berhasil menghapus pos tabungan.'));
    loadVaults();
  }

  Future<void> _saveTransaction(String vaultId, VaultTransactionType type, double amount, String? note) async {
    final authSession = hiveService.getData<Map<dynamic, dynamic>>(LocalKeys.authSession);
    final String currentUserId = authSession?['userId'] as String? ?? 'unknown';
    final String currentUserEmail = authSession?['email'] as String? ?? 'unknown';

    final transaction = VaultTransaction(
      transactionId: const Uuid().v4(),
      vaultId: vaultId,
      userId: currentUserId,
      userEmail: currentUserEmail,
      type: type,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );

    final rawTx = hiveService.getData<List<dynamic>>('vaultTransactions') ?? [];
    rawTx.add(transaction.toJson());
    await hiveService.saveData('vaultTransactions', rawTx);
  }

  Future<void> loadTransactions(String vaultId) async {
    try {
      final rawTx = hiveService.getData<List<dynamic>>('vaultTransactions') ?? [];
      final transactions = rawTx
          .map((e) => VaultTransaction.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((t) => t.vaultId == vaultId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // We only emit the list. The UI can listen to it.
      // Alternatively, we just emit a specific state. Let's not interrupt VaultLoaded unless necessary.
      // But we will emit it!
      emit(VaultTransactionsLoaded(transactions));
      // Re-emit loaded so UI doesn't break
      loadVaults();
    } catch (e) {
      emit(VaultError('Gagal memuat riwayat transaksi: $e'));
      loadVaults();
    }
  }
}
