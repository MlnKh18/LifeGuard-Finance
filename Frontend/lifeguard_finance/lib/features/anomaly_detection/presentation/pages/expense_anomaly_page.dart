import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/entities/anomaly_result.dart';
import '../../domain/entities/expense_transaction.dart';
import '../bloc/anomaly_cubit.dart';
import '../bloc/anomaly_state.dart';
import '../widgets/expense_trend_chart.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

const _monthAbbr = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];

String _formatDate(DateTime date) => '${date.day} ${_monthAbbr[date.month]} ${date.year}';

Color _severityColor(AnomalySeverity severity) {
  switch (severity) {
    case AnomalySeverity.tinggi:
      return AppColors.error;
    case AnomalySeverity.ringan:
      return AppColors.riskWarning;
    case AnomalySeverity.normal:
      return AppColors.riskSafe;
  }
}

String _severityLabel(AnomalySeverity severity) {
  switch (severity) {
    case AnomalySeverity.tinggi:
      return 'Anomali Tinggi';
    case AnomalySeverity.ringan:
      return 'Anomali Ringan';
    case AnomalySeverity.normal:
      return 'Normal';
  }
}

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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: AppColors.textSecondary),
            tooltip: 'Peringatan Dini',
            onPressed: () => context.push('/early-warning'),
          ),
        ],
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
                  if (state.anomalyCount > 0)
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
                            '${state.anomalyCount} Kategori Anomali',
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
        if (state.spikingCategories.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Kategori yang Mengalami Lonjakan', style: AppTextStyles.heading2),
          const SizedBox(height: 12),
          ...state.spikingCategories.map((r) => _buildSpikeCard(r)),
        ],
        const SizedBox(height: 24),
        Text('Transaksi Terbaru', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        ...state.transactions.map((t) => _buildTransactionTile(context, t)),
      ],
    );
  }

  Widget _buildSpikeCard(AnomalyResult result) {
    final color = _severityColor(result.severity);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: 12.0,
      border: Border.all(color: color.withAlpha(100)),
      color: color.withAlpha(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(result.category, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  _severityLabel(result.severity),
                  style: AppTextStyles.label.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rata-rata historis: ${_rupiahFormat.format(result.historicalAverage)}', style: AppTextStyles.bodySmall),
              Text(
                '+${result.percentageIncrease.toStringAsFixed(0)}%',
                style: AppTextStyles.dataLabel.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Bulan ini: ${_rupiahFormat.format(result.currentAmount)}', style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Text(result.warningMessage, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(
            'Estimasi dampak ke Skor FVS: ${result.estimatedFvsImpact.toStringAsFixed(0)} poin',
            style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, ExpenseTransaction t) {
    if (!t.isAnomaly) {
      return AppCard(
        margin: const EdgeInsets.only(bottom: 10),
        borderRadius: 8.0,
        onTap: () => context.push('/expense-anomaly/${t.id}'),
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
                  Text(
                    t.note != null && t.note!.isNotEmpty ? '${_formatDate(t.date)} • ${t.note}' : _formatDate(t.date),
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(_rupiahFormat.format(t.amount), style: AppTextStyles.dataLabel),
          ],
        ),
      );
    }

    final color = _severityColor(t.severity);
    return InkWell(
      onTap: () => context.push('/expense-anomaly/${t.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 36, color: color),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(_categoryIcon(t.category), color: color, size: 20),
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
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          _severityLabel(t.severity).toUpperCase(),
                          style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  Text('${_formatDate(t.date)} • +${t.percentageIncrease.toStringAsFixed(0)}%', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _rupiahFormat.format(t.amount),
              style: AppTextStyles.dataLabel.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final cubit = context.read<AnomalyCubit>();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String category = expenseCategories.first;
    DateTime selectedDate = DateTime.now();
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setDialogState(() => selectedDate = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Tanggal'),
                          child: Text(_formatDate(selectedDate)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                        maxLines: 2,
                      ),
                    ],
                  ),
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
                      date: selectedDate,
                      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
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
    case 'Makanan':
      return Icons.restaurant_rounded;
    case 'Transportasi':
      return Icons.directions_car_rounded;
    case 'Cicilan':
      return Icons.credit_card_rounded;
    case 'Pendidikan':
      return Icons.school_rounded;
    case 'Kesehatan':
      return Icons.local_hospital_rounded;
    case 'Belanja Rumah Tangga':
      return Icons.shopping_cart_rounded;
    case 'Hiburan':
      return Icons.movie_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}
