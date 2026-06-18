import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/entities/expense_transaction.dart';
import '../bloc/anomaly_cubit.dart';
import '../bloc/anomaly_state.dart';
import '../widgets/expense_trend_chart.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

const _categories = ['Belanja Bulanan', 'Transportasi', 'Hiburan & Makan', 'Elektronik', 'Lainnya'];
const _monthAbbr = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];

String _formatDate(DateTime date) => '${date.day} ${_monthAbbr[date.month]} ${date.year}';

class ExpenseAnomalyPage extends StatelessWidget {
  const ExpenseAnomalyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnomalyCubit>(
      create: (context) => getIt<AnomalyCubit>()..loadTransactions(),
      child: const ExpenseAnomalyView(),
    );
  }
}

class ExpenseAnomalyView extends StatelessWidget {
  const ExpenseAnomalyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deteksi Anomali', style: AppTextStyles.heading3),
      ),
      body: BlocBuilder<AnomalyCubit, AnomalyState>(
        builder: (context, state) {
          if (state is AnomalyLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is AnomalyError) {
            return _buildErrorView(context, state.message);
          }

          if (state is AnomalyLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnomalyLoaded state) {
    final monthlyAnomalies = state.monthlyTrend.where((m) => m.isAnomaly).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        const SectionTitle(
          title: 'Deteksi Anomali',
          subtitle: 'Tren & anomali pengeluaran bulanan keluarga.',
        ),
        const SizedBox(height: 8),
        AppCard(
          borderRadius: 12.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Volatilitas Pengeluaran', style: AppTextStyles.heading3),
                        const SizedBox(height: 2),
                        Text('6 Bulan Terakhir', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  if (monthlyAnomalies > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.onErrorContainer),
                          const SizedBox(width: 4),
                          Text(
                            '$monthlyAnomalies Anomali Terdeteksi',
                            style: AppTextStyles.label.copyWith(color: AppColors.onErrorContainer),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ExpenseTrendChart(trend: state.monthlyTrend),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Transaksi Terbaru', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        ...state.transactions.map((t) => _buildTransactionTile(t)),
      ],
    );
  }

  Widget _buildTransactionTile(ExpenseTransaction t) {
    if (!t.isAnomaly) {
      return AppCard(
        margin: const EdgeInsets.only(bottom: 10),
        borderRadius: 8.0,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: Icon(_categoryIcon(t.category), color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.category, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  Text(_formatDate(t.date), style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Text(_rupiahFormat.format(t.amount), style: AppTextStyles.dataLabel),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 36, color: AppColors.error),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(_categoryIcon(t.category), color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(t.category, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        'ANOMALI',
                        style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                Text(_formatDate(t.date), style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _rupiahFormat.format(t.amount),
            style: AppTextStyles.dataLabel.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final cubit = context.read<AnomalyCubit>();
    final amountController = TextEditingController();
    String category = _categories.first;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Transaksi'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setDialogState(() => category = val ?? category),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final amount = double.tryParse(val ?? '');
                        if (amount == null || amount <= 0) return 'Masukkan jumlah yang valid';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    cubit.addTransaction(
                      category: category,
                      amount: double.parse(amountController.text),
                      date: DateTime.now(),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.riskCritical),
          const SizedBox(height: 16),
          Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Belanja Bulanan':
      return Icons.shopping_cart_rounded;
    case 'Transportasi':
      return Icons.directions_car_rounded;
    case 'Hiburan & Makan':
      return Icons.restaurant_rounded;
    case 'Elektronik':
      return Icons.devices_other_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}
