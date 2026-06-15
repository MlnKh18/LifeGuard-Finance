import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../data/models/finance_profile.dart';
import '../../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Form controllers & values
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Step 1: Profile & Income
  String _householdType = 'Lajang';
  String _incomeType = 'Tetap';
  int _dependentsCount = 0;
  final TextEditingController _incomeController = TextEditingController();

  // Step 2: Expenses & Savings
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _essentialExpenseController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();

  // Step 3: Debt & Protection
  final TextEditingController _debtController = TextEditingController(text: '0');
  final TextEditingController _debtPaymentController = TextEditingController(text: '0');
  bool _hasHealthProtection = false;
  bool _hasLifeProtection = false;

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    _expenseController.dispose();
    _essentialExpenseController.dispose();
    _savingsController.dispose();
    _debtController.dispose();
    _debtPaymentController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey1.currentState!.validate()) return;
    if (_currentStep == 1 && !_formKey2.currentState!.validate()) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey3.currentState!.validate()) return;

    // Parse values
    final income = double.tryParse(_incomeController.text.replaceAll('.', '')) ?? 0.0;
    final expense = double.tryParse(_expenseController.text.replaceAll('.', '')) ?? 0.0;
    final essential = double.tryParse(_essentialExpenseController.text.replaceAll('.', '')) ?? 0.0;
    final savings = double.tryParse(_savingsController.text.replaceAll('.', '')) ?? 0.0;
    final debt = double.tryParse(_debtController.text.replaceAll('.', '')) ?? 0.0;
    final debtPayment = double.tryParse(_debtPaymentController.text.replaceAll('.', '')) ?? 0.0;

    // Build profile
    final newProfile = FamilyFinanceProfile(
      profileId: DateTime.now().millisecondsSinceEpoch.toString(),
      monthlyIncome: income,
      monthlyExpense: expense,
      essentialExpense: essential,
      nonEssentialExpense: (expense - essential).clamp(0.0, double.infinity),
      liquidSavings: savings,
      totalDebt: debt,
      monthlyDebtPayment: debtPayment,
      dependentsCount: _dependentsCount,
      hasHealthProtection: _hasHealthProtection,
      hasLifeProtection: _hasLifeProtection,
      incomeType: _incomeType,
      householdType: _householdType,
      ageRange: '30-40',
      createdAt: DateTime.now(),
    );

    // Save using provider (which triggers automatic routing & FVS computation)
    await ref.read(profileStateProvider.notifier).saveProfile(newProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Keuangan Keluarga'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper indicator
            _buildStepIndicator(),
            
            // Viewport Form Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1ProfileIncome(),
                  _buildStep2ExpensesSavings(),
                  _buildStep3DebtProtection(),
                ],
              ),
            ),
            
            // Stepper Buttons
            Padding(
              padding: const EdgeInsets.all(AppStyles.m),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        child: const Text('Kembali'),
                      ),
                    ),
                    const SizedBox(width: AppStyles.m),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(_currentStep == _totalSteps - 1 ? 'Hitung Skor FVS' : 'Lanjut'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.m, vertical: AppStyles.s),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryLight : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- WIDGETS STEP 1: Profile & Income ---
  Widget _buildStep1ProfileIncome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.m),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Langkah 1: Profil & Pendapatan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppStyles.s),
            const Text(
              'Masukkan profil rumah tangga dan jenis kestabilan pendapatan bulanan keluarga.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.l),

            // Household type dropdown
            _buildDropdown(
              label: 'Kategori Rumah Tangga',
              value: _householdType,
              items: ['Lajang', 'Menikah Tanpa Anak', 'Menikah Dengan Anak', 'Generasi Sandwich'],
              onChanged: (val) => setState(() => _householdType = val!),
            ),
            const SizedBox(height: AppStyles.m),

            // Income stability type
            _buildDropdown(
              label: 'Jenis Kestabilan Pendapatan',
              value: _incomeType,
              items: ['Tetap', 'Tidak Tetap'],
              onChanged: (val) => setState(() => _incomeType = val!),
            ),
            const SizedBox(height: AppStyles.m),

            // Dependents Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jumlah Tanggungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Orang tua/anak/saudara', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.minusCircle, color: AppColors.textSecondary),
                      onPressed: _dependentsCount > 0 ? () => setState(() => _dependentsCount--) : null,
                    ),
                    Text('$_dependentsCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    IconButton(
                      icon: const Icon(LucideIcons.plusCircle, color: AppColors.primaryLight),
                      onPressed: () => setState(() => _dependentsCount++),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppStyles.m),

            // Monthly Net Income input
            TextFormField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: AppStyles.inputDecoration(
                labelText: 'Pendapatan Bersih Bulanan',
                hintText: 'Masukkan pendapatan',
                prefixIcon: const Icon(LucideIcons.wallet, color: AppColors.textSecondary),
                suffixText: 'IDR',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Pendapatan wajib diisi';
                if (double.tryParse(value.replaceAll('.', '')) == null) return 'Format angka salah';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS STEP 2: Expenses & Savings ---
  Widget _buildStep2ExpensesSavings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.m),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Langkah 2: Pengeluaran & Tabungan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppStyles.s),
            const Text(
              'Pastikan mencatat nilai pengeluaran bulanan esensial (seperti makanan, sewa, sekolah) dan tabungan darurat.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.l),

            // Total Monthly Expense
            TextFormField(
              controller: _expenseController,
              keyboardType: TextInputType.number,
              decoration: AppStyles.inputDecoration(
                labelText: 'Total Pengeluaran Bulanan',
                hintText: 'Total biaya rutin keluarga',
                prefixIcon: const Icon(LucideIcons.receipt, color: AppColors.textSecondary),
                suffixText: 'IDR',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Pengeluaran wajib diisi';
                final expense = double.tryParse(value.replaceAll('.', ''));
                if (expense == null) return 'Format angka salah';
                final income = double.tryParse(_incomeController.text.replaceAll('.', '')) ?? 0.0;
                if (expense > income * 2) return 'Pengeluaran melebihi batas wajar';
                return null;
              },
            ),
            const SizedBox(height: AppStyles.m),

            // Essential Expense
            TextFormField(
              controller: _essentialExpenseController,
              keyboardType: TextInputType.number,
              decoration: AppStyles.inputDecoration(
                labelText: 'Pengeluaran Pokok/Esensial',
                hintText: 'Biaya makan, tagihan listrik, cicilan rumah',
                prefixIcon: const Icon(LucideIcons.shoppingBag, color: AppColors.textSecondary),
                suffixText: 'IDR',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Pengeluaran esensial wajib diisi';
                final essential = double.tryParse(value.replaceAll('.', ''));
                if (essential == null) return 'Format angka salah';
                final expense = double.tryParse(_expenseController.text.replaceAll('.', '')) ?? 0.0;
                if (essential > expense) return 'Pengeluaran pokok tidak boleh lebih besar dari total pengeluaran';
                return null;
              },
            ),
            const SizedBox(height: AppStyles.m),

            // Liquid Savings / Emergency Fund
            TextFormField(
              controller: _savingsController,
              keyboardType: TextInputType.number,
              decoration: AppStyles.inputDecoration(
                labelText: 'Tabungan Likuid / Dana Darurat',
                hintText: 'Tabungan bank yang mudah dicairkan',
                prefixIcon: const Icon(LucideIcons.banknote, color: AppColors.textSecondary),
                suffixText: 'IDR',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Nilai tabungan wajib diisi (isi 0 jika tidak ada)';
                if (double.tryParse(value.replaceAll('.', '')) == null) return 'Format angka salah';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS STEP 3: Debt & Protection ---
  Widget _buildStep3DebtProtection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.m),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Langkah 3: Utang & Proteksi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppStyles.s),
            const Text(
              'Informasikan total utang yang ada dan status asuransi kesehatan/jiwa.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.l),

            // Total outstanding debt
            TextFormField(
              controller: _debtController,
              keyboardType: TextInputType.number,
              decoration: AppStyles.inputDecoration(
                labelText: 'Total Sisa Utang',
                hintText: 'Sisa KPR/KTA/Kartu Kredit (Isi 0 jika tidak ada)',
                prefixIcon: const Icon(LucideIcons.coins, color: AppColors.textSecondary),
                suffixText: 'IDR',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Total sisa utang wajib diisi';
                if (double.tryParse(value.replaceAll('.', '')) == null) return 'Format angka salah';
                return null;
              },
            ),
            const SizedBox(height: AppStyles.m),

            // Monthly Debt Payment
            TextFormField(
              controller: _debtPaymentController,
              keyboardType: TextInputType.number,
              decoration: AppStyles.inputDecoration(
                labelText: 'Cicilan Bulanan Aktif',
                hintText: 'Jumlah cicilan yang dibayar per bulan',
                prefixIcon: const Icon(LucideIcons.calendarClock, color: AppColors.textSecondary),
                suffixText: 'IDR',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Cicilan bulanan wajib diisi';
                final payment = double.tryParse(value.replaceAll('.', ''));
                if (payment == null) return 'Format angka salah';
                final totalDebt = double.tryParse(_debtController.text.replaceAll('.', '')) ?? 0.0;
                if (payment > 0 && totalDebt == 0) return 'Cicilan tidak valid jika total utang 0';
                return null;
              },
            ),
            const SizedBox(height: AppStyles.l),

            // Protection switch cards
            const Text('Status Proteksi Dasar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: AppStyles.s),
            
            _buildSwitchCard(
              title: 'Proteksi Kesehatan Aktif',
              subtitle: 'Memiliki BPJS Kesehatan atau asuransi kesehatan swasta aktif.',
              value: _hasHealthProtection,
              onChanged: (val) => setState(() => _hasHealthProtection = val),
            ),
            const SizedBox(height: AppStyles.s),
            
            _buildSwitchCard(
              title: 'Proteksi Asuransi Jiwa Aktif',
              subtitle: 'Memiliki asuransi jiwa aktif (terutama jika pencari nafkah utama).',
              value: _hasLifeProtection,
              onChanged: (val) => setState(() => _hasLifeProtection = val),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: AppStyles.xs),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: AppColors.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppStyles.m),
            border: OutlineInputBorder(
              borderRadius: AppStyles.radiusMedium,
              borderSide: BorderSide(color: AppColors.surfaceCard.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppStyles.radiusMedium,
              borderSide: BorderSide(color: AppColors.surfaceCard.withOpacity(0.5)),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: AppColors.textPrimary)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppStyles.radiusMedium,
        border: Border.all(color: AppColors.surfaceCard.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
