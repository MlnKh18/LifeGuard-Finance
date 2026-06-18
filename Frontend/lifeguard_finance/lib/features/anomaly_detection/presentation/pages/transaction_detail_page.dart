import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/expense_transaction.dart';
import '../bloc/anomaly_cubit.dart';
import '../bloc/anomaly_state.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
const _monthNames = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

String _formatFullDate(DateTime date) => '${date.day} ${_monthNames[date.month]} ${date.year}, ${DateFormat('HH:mm').format(date)}';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnomalyCubit>(
      create: (context) => getIt<AnomalyCubit>()..loadTransactions(),
      child: TransactionDetailView(transactionId: transactionId),
    );
  }
}

class TransactionDetailView extends StatelessWidget {
  final String transactionId;

  const TransactionDetailView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Transaksi', style: AppTextStyles.heading3)),
      body: BlocBuilder<AnomalyCubit, AnomalyState>(
        builder: (context, state) {
          if (state is! AnomalyLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final matches = state.transactions.where((t) => t.id == transactionId);
          final transaction = matches.isEmpty ? null : matches.first;
          if (transaction == null) {
            return Center(
              child: Text('Transaksi tidak ditemukan.', style: AppTextStyles.bodyMedium),
            );
          }

          final sameCategory = state.transactions.where((t) => t.category == transaction.category).toList();
          final categoryAverage = sameCategory.isEmpty
              ? transaction.amount
              : sameCategory.fold<double>(0, (sum, t) => sum + t.amount) / sameCategory.length;

          return _buildContent(context, transaction, categoryAverage);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExpenseTransaction t, double categoryAverage) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Center(
          child: Column(
            children: [
              Text(_rupiahFormat.format(t.amount), style: AppTextStyles.dataDisplay.copyWith(color: t.isAnomaly ? AppColors.error : AppColors.textPrimary)),
              const SizedBox(height: 8),
              if (t.isAnomaly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.onErrorContainer),
                      const SizedBox(width: 6),
                      Text('ANOMALI TERDETEKSI', style: AppTextStyles.label.copyWith(color: AppColors.onErrorContainer)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          borderRadius: 12.0,
          child: Column(
            children: [
              _detailRow('Kategori', t.category),
              const Divider(height: 20, color: AppColors.border),
              _detailRow('Waktu', _formatFullDate(t.date)),
              const Divider(height: 20, color: AppColors.border),
              _detailRow('Metode', 'Input Manual'),
              const Divider(height: 20, color: AppColors.border),
              _detailRow('Status', _reviewStatusLabel(t.reviewStatus), valueColor: _reviewStatusColor(t.reviewStatus)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Analisis Keamanan', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        AppCard(
          borderRadius: 12.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _comparisonBar('Transaksi Ini', t.amount, categoryAverage, t.isAnomaly ? AppColors.error : AppColors.primary),
              const SizedBox(height: 14),
              _comparisonBar('Rata-rata Kategori', categoryAverage, categoryAverage, AppColors.secondary),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.tertiaryContainer.withAlpha(80)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.tertiaryContainer, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.isAnomaly
                      ? 'Jika Anda tidak mengenali transaksi ini, segera amankan metode pembayaran terkait dan sanggah transaksi di bawah.'
                      : 'Transaksi ini berada dalam rentang wajar dibandingkan riwayat kategori yang sama.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (t.reviewStatus == TransactionReviewStatus.pending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _setStatus(context, t.id, TransactionReviewStatus.confirmed, 'Transaksi dikonfirmasi.'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Konfirmasi Transaksi'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _setStatus(context, t.id, TransactionReviewStatus.disputed, 'Transaksi disanggah.'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Bukan Saya (Sanggah)'),
            ),
          ),
        ],
      ],
    );
  }

  void _setStatus(BuildContext context, String id, TransactionReviewStatus status, String message) {
    context.read<AnomalyCubit>().setReviewStatus(id, status);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.riskSafe));
    context.pop();
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.dataLabel.copyWith(color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _comparisonBar(String label, double value, double maxValue, Color color) {
    final ratio = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text(_rupiahFormat.format(value), style: AppTextStyles.dataLabel.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

String _reviewStatusLabel(TransactionReviewStatus status) {
  switch (status) {
    case TransactionReviewStatus.confirmed:
      return 'Dikonfirmasi';
    case TransactionReviewStatus.disputed:
      return 'Disanggah';
    case TransactionReviewStatus.pending:
      return 'Menunggu Konfirmasi';
  }
}

Color _reviewStatusColor(TransactionReviewStatus status) {
  switch (status) {
    case TransactionReviewStatus.confirmed:
      return AppColors.riskSafe;
    case TransactionReviewStatus.disputed:
      return AppColors.error;
    case TransactionReviewStatus.pending:
      return AppColors.riskWarning;
  }
}
