import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Makanan';
  bool _isRoutine = true;

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
              title: Text(
                'Catat Pengeluaran Baru',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.surface,
                    value: _selectedCategory,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(Icons.category, color: AppColors.accent),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Nominal Pengeluaran (Rp)',
                      prefixIcon: const Icon(Icons.monetization_on, color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      Text(
                        'Pengeluaran Rutin Bulanan',
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppStyles.radiusSmall,
                    ),
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
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Expense Insights',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: _showAddExpenseDialog,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: anomalies.isNotEmpty ? AppColors.critical.withOpacity(0.1) : AppColors.accent.withOpacity(0.08),
                  borderRadius: AppStyles.radiusMedium,
                  border: Border.all(
                    color: anomalies.isNotEmpty ? AppColors.critical.withOpacity(0.7) : AppColors.accent.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          anomalies.isNotEmpty ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: anomalies.isNotEmpty ? AppColors.critical : AppColors.accent,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            anomalies.isNotEmpty
                                ? 'Expense Anomaly Detection: ${anomalies.length} Pengeluaran Tidak Wajar Terdeteksi!'
                                : 'Expense Anomaly Detection: Pengeluaran Terkendali',
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      anomalies.isNotEmpty
                          ? 'Algoritma mendeteksi lonjakan biaya yang signifikan dibanding rata-rata pengeluaran historis Anda. Segera periksa daftar di bawah.'
                          : 'Sistem kecerdasan buatan menyimpulkan pengeluaran Anda masih dalam rentang wajar dan tidak terdeteksi anomali.',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Transaksi Pengeluaran',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.post_add, color: AppColors.accent),
                    onPressed: _showAddExpenseDialog,
                  )
                ],
              ),
              const SizedBox(height: 8),
              if (expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Belum ada riwayat transaksi.',
                      style: GoogleFonts.outfit(color: AppColors.textSecondary),
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
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppStyles.radiusSmall,
                        border: Border.all(
                          color: isAnomaly ? AppColors.critical.withOpacity(0.5) : AppColors.surfaceCard,
                          width: isAnomaly ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAnomaly ? AppColors.critical.withOpacity(0.1) : AppColors.surfaceCard,
                          child: Icon(
                            isAnomaly ? Icons.warning : Icons.shopping_bag,
                            color: isAnomaly ? AppColors.critical : AppColors.textSecondary,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              category,
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isAnomaly) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, py: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.critical.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ANOMALI ${severity}',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.critical,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                        subtitle: Text(
                          expense['created_at'].toString().substring(0, 10),
                          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                        ),
                        trailing: Text(
                          'Rp ${amount.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
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
