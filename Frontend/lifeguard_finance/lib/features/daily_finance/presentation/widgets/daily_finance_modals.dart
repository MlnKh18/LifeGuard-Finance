import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/finance_record_entity.dart';
import '../bloc/daily_finance_cubit.dart';

class AddFinanceRecordForm extends StatefulWidget {
  final FinanceRecordType type;
  final VoidCallback onSuccess;

  const AddFinanceRecordForm({
    super.key,
    required this.type,
    required this.onSuccess,
  });

  @override
  State<AddFinanceRecordForm> createState() => _AddFinanceRecordFormState();
}

class _AddFinanceRecordFormState extends State<AddFinanceRecordForm> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0'), backgroundColor: AppColors.riskCritical),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori wajib dipilih'), backgroundColor: AppColors.riskCritical),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    String familyId = '';
    String userId = '';
    String userEmail = '';

    if (authState is AuthAuthenticated) {
      familyId = authState.user.familyId;
      userId = authState.user.userId;
      userEmail = authState.user.email;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda belum login'), backgroundColor: AppColors.riskCritical),
      );
      return;
    }

    final record = FinanceRecord(
      recordId: const Uuid().v4(),
      familyId: familyId,
      userId: userId,
      userEmail: userEmail,
      type: widget.type,
      category: _selectedCategory!,
      amount: amount,
      recordDate: _selectedDate,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await context.read<DailyFinanceCubit>().addRecord(record);
    
    if (mounted) {
      widget.onSuccess();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == FinanceRecordType.income;
    final categories = isIncome 
        ? IncomeCategory.values.map((e) => e.name).toList() 
        : ExpenseCategory.values.map((e) => e.name).toList();

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isIncome ? 'Tambah Pendapatan' : 'Tambah Pengeluaran', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text('Masukkan detail transaksi Anda', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp ',
                hintText: 'Contoh: 50000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal Transaksi'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tambahkan keterangan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Simpan',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
