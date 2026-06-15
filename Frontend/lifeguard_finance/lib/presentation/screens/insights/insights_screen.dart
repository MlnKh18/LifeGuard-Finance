import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Makanan';
  bool _isRoutine = true;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppStyles.radiusMedium,
                side: const BorderSide(color: AppColors.surfaceCard, width: 1),
              ),
              title: const Text(
                'Catat Pengeluaran Baru',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.surface,
                    value: _selectedCategory,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(LucideIcons.tag, color: AppColors.accent),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Makanan', child: Text('Makanan & Minuman')),
                      DropdownMenuItem(value: 'Transportasi', child: Text('Transportasi')),
                      DropdownMenuItem(value: 'Pendidikan', child: Text('Pendidikan')),
                      DropdownMenuItem(value: 'Kesehatan', child: Text('Kesehatan')),
                      DropdownMenuItem(value: 'Hiburan', child: Text('Hiburan/Gaya Hidup')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppStyles.m),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Nominal Pengeluaran (Rp)',
                      prefixIcon: const Icon(LucideIcons.coins, color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: AppStyles.s),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.accent,
                        value: _isRoutine,
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              _isRoutine = val;
                            });
                          }
                        },
                      ),
                      const Text(
                        'Pengeluaran Rutin Bulanan',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusSmall),
                  ),
                  onPressed: () {
                    final amt = double.tryParse(_amountController.text) ?? 0.0;
                    if (amt > 0) {
                      ref.read(expensesProvider.notifier).addExpenseAndCheckAnomaly(
                            _selectedCategory,
                            amt,
                            _isRoutine,
                          );
                      _amountController.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pengeluaran berhasil dicatat!')),
                      );
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);
    final anomalies = expenses.where((e) => e['is_anomaly'] == 1).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Pengeluaran'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppColors.accent),
            onPressed: _showAddExpenseDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: anomalies.isNotEmpty
                      ? AppColors.critical.withOpacity(0.1)
                      : AppColors.accent.withOpacity(0.08),
                  borderRadius: AppStyles.radiusMedium,
                  border: Border.all(
                    color: anomalies.isNotEmpty
                        ? AppColors.critical.withOpacity(0.7)
                        : AppColors.accent.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(AppStyles.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          anomalies.isNotEmpty ? LucideIcons.alertTriangle : LucideIcons.checkCircle2,
                          color: anomalies.isNotEmpty ? AppColors.critical : AppColors.accent,
                          size: 28,
                        ),
                        const SizedBox(width: AppStyles.s),
                        Expanded(
                          child: Text(
                            anomalies.isNotEmpty
                                ? 'Deteksi Anomali: ${anomalies.length} Pengeluaran Tidak Wajar!'
                                : 'Deteksi Anomali: Pengeluaran Terkendali',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.s),
                    Text(
                      anomalies.isNotEmpty
                          ? 'Sistem mendeteksi lonjakan biaya signifikan dibanding rata-rata pengeluaran historis Anda. Segera periksa daftar di bawah.'
                          : 'Sistem menyimpulkan pengeluaran Anda masih dalam rentang wajar dan tidak terdeteksi anomali.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.l),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Transaksi Pengeluaran',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, color: AppColors.accent),
                    onPressed: _showAddExpenseDialog,
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.s),
              if (expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppStyles.xxl),
                    child: const Text(
                      'Belum ada riwayat transaksi.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final bool isAnomaly = expense['is_anomaly'] == 1;
                    final double amount = (expense['amount'] as num).toDouble();
                    final String category = expense['category'];
                    final String severity = expense['anomaly_severity'] ?? 'NONE';

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppStyles.s),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppStyles.radiusSmall,
                        border: Border.all(
                          color: isAnomaly
                              ? AppColors.critical.withOpacity(0.5)
                              : AppColors.surfaceCard,
                          width: isAnomaly ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAnomaly
                              ? AppColors.critical.withOpacity(0.1)
                              : AppColors.surfaceCard,
                          child: Icon(
                            isAnomaly ? LucideIcons.alertTriangle : LucideIcons.shoppingBag,
                            color: isAnomaly ? AppColors.critical : AppColors.textSecondary,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isAnomaly) ...[
                              const SizedBox(width: AppStyles.s),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.critical.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ANOMALI $severity',
                                  style: const TextStyle(
                                    color: AppColors.critical,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          expense['created_at'].toString().substring(0, 10),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                        trailing: Text(
                          _formatCurrency(amount),
                          style: TextStyle(
                            color: isAnomaly ? AppColors.critical : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
