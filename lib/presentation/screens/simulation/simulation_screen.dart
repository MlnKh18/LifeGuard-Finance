import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';
import '../../../data/models/simulation.dart';
import '../../../data/models/finance_profile.dart';
import '../../../logic/simulation/simulation_engine.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  String _selectedScenario = 'PHK'; // 'PHK', 'MEDICAL', 'CICILAN', 'INFLASI', 'PENDIDIKAN', 'DEPENDENT'
  
  // Input values
  double _durationMonths = 3.0;
  double _amountValue = 10000000.0;
  double _cicilanIncrease = 1000000.0;
  double _inflationPercent = 0.15;
  double _educationFee = 15000000.0;
  double _dependentCost = 1500000.0;

  ScenarioSimulation? _latestResult;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  void _runSimulation() {
    final profile = ref.read(profileStateProvider);
    if (profile == null) return;

    double amount = 0.0;
    int duration = _durationMonths.round();

    if (_selectedScenario == 'PHK') {
      amount = profile.monthlyIncome;
    } else if (_selectedScenario == 'MEDICAL') {
      amount = _amountValue;
      duration = 1;
    } else if (_selectedScenario == 'CICILAN') {
      amount = _cicilanIncrease;
    } else if (_selectedScenario == 'INFLASI') {
      amount = _inflationPercent;
    } else if (_selectedScenario == 'PENDIDIKAN') {
      amount = _educationFee;
      duration = 1;
    } else if (_selectedScenario == 'DEPENDENT') {
      amount = _dependentCost;
    }

    final result = SimulationEngine.run(
      profile: profile,
      scenarioType: _selectedScenario,
      durationMonths: duration,
      amount: amount,
    );

    setState(() {
      _latestResult = result;
    });

    ref.read(simulationHistoryProvider.notifier).addSimulation(result);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileStateProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Harap lengkapi profil keuangan Anda terlebih dahulu.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulasi Skenario Darurat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Skenario Krisis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppStyles.s),
            _buildScenarioChips(),
            const SizedBox(height: AppStyles.l),

            // Parameters card
            Text(
              'Parameter Simulasi ${_selectedScenario == 'PHK' ? 'Kehilangan Pekerjaan' : _selectedScenario == 'MEDICAL' ? 'Biaya Medis Mendadak' : _selectedScenario == 'CICILAN' ? 'Kenaikan Cicilan' : _selectedScenario == 'PENDIDIKAN' ? 'Biaya Sekolah' : _selectedScenario == 'DEPENDENT' ? 'Tanggungan Baru' : 'Inflasi Pokok'}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.s),
            _buildParameterControls(profile),
            const SizedBox(height: AppStyles.l),

            // Action Button
            ElevatedButton(
              onPressed: _runSimulation,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.play, size: 18),
                  SizedBox(width: AppStyles.s),
                  Text('Simulasikan Dampak Keuangan'),
                ],
              ),
            ),
            const SizedBox(height: AppStyles.xl),

            // Outputs
            if (_latestResult != null) ...[
              const Text(
                'Hasil Proyeksi Dampak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppStyles.s),
              _buildResultCard(profile),
              const SizedBox(height: AppStyles.l),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioChips() {
    final list = [
      {'id': 'PHK', 'label': 'Kehilangan Kerja', 'icon': LucideIcons.briefcase},
      {'id': 'MEDICAL', 'label': 'Biaya Medis', 'icon': LucideIcons.heartPulse},
      {'id': 'CICILAN', 'label': 'Kenaikan Cicilan', 'icon': LucideIcons.trendingUp},
      {'id': 'INFLASI', 'label': 'Inflasi Kebutuhan', 'icon': LucideIcons.shoppingBag},
      {'id': 'PENDIDIKAN', 'label': 'Biaya Sekolah', 'icon': LucideIcons.book},
      {'id': 'DEPENDENT', 'label': 'Tanggungan Baru', 'icon': LucideIcons.users},
    ];

    return Wrap(
      spacing: AppStyles.s,
      runSpacing: AppStyles.s,
      children: list.map((item) {
        final isSelected = _selectedScenario == item['id'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                item['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          selected: isSelected,
          selectedColor: AppColors.primaryLight,
          backgroundColor: AppColors.surface,
          checkmarkColor: Colors.white,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedScenario = item['id'] as String;
                _latestResult = null;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildParameterControls(FamilyFinanceProfile profile) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.m),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedScenario == 'PHK') ...[
            const Text('Estimasi Masa Menganggur:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _durationMonths,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _durationMonths = val),
                  ),
                ),
                Text('${_durationMonths.round()} Bulan', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            Text(
              'Selama periode ini, pendapatan diasumsikan Rp 0 dan pengeluaran rutin ditarik dari tabungan darurat.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ] else if (_selectedScenario == 'MEDICAL') ...[
            const Text('Biaya Medis Darurat:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _amountValue,
                    min: 1000000,
                    max: 100000000,
                    divisions: 99,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _amountValue = val),
                  ),
                ),
                Text('${(_amountValue / 1000000).toStringAsFixed(0)} Jt', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            Text(
              'Biaya medis sebesar ${_formatCurrency(_amountValue)} akan dibayar langsung menggunakan tabungan likuid saat ini.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ] else if (_selectedScenario == 'CICILAN') ...[
            const Text('Tambahan Cicilan Bulanan:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _cicilanIncrease,
                    min: 100000,
                    max: 10000000,
                    divisions: 99,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _cicilanIncrease = val),
                  ),
                ),
                Text('${(_cicilanIncrease / 1000000).toStringAsFixed(1)} Jt', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: AppStyles.s),
            const Text('Berapa Bulan Kenaikan Terjadi:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _durationMonths,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _durationMonths = val),
                  ),
                ),
                Text('${_durationMonths.round()} Bulan', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ] else if (_selectedScenario == 'INFLASI') ...[
            const Text('Tingkat Inflasi Kebutuhan Pokok:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _inflationPercent,
                    min: 0.05,
                    max: 0.50,
                    divisions: 9,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _inflationPercent = val),
                  ),
                ),
                Text('${(_inflationPercent * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            Text(
              'Biaya esensial pokok Anda saat ini (${_formatCurrency(profile.essentialExpense)}) disimulasikan melonjak sebesar ${(_inflationPercent * 100).toStringAsFixed(0)}%.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppStyles.s),
            const Text('Berapa Bulan Tekanan Inflasi:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _durationMonths,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _durationMonths = val),
                  ),
                ),
                Text('${_durationMonths.round()} Bulan', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.surfaceCard),
            const SizedBox(height: 10),
            // Standalone Inflation Impact Calculator Card
            Row(
              children: [
                const Icon(Icons.calculate, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Inflation Impact Calculator',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dengan inflasi ${(_inflationPercent * 100).toStringAsFixed(0)}% per tahun, nilai riil daya beli tabungan Anda (${_formatCurrency(profile.liquidSavings)}) akan menurun menjadi:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            _buildInflationRow('1 Tahun Ke Depan', profile.liquidSavings / (1 + _inflationPercent)),
            _buildInflationRow('3 Tahun Ke Depan', profile.liquidSavings / (1 + _inflationPercent * 3)),
            _buildInflationRow('5 Tahun Ke Depan', profile.liquidSavings / (1 + _inflationPercent * 5)),
          ] else if (_selectedScenario == 'PENDIDIKAN') ...[
            const Text('Biaya Masuk Sekolah (Lump Sum):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _educationFee,
                    min: 1000000,
                    max: 50000000,
                    divisions: 49,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _educationFee = val),
                  ),
                ),
                Text('${(_educationFee / 1000000).toStringAsFixed(0)} Jt', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            Text(
              'Biaya sekolah sebesar ${_formatCurrency(_educationFee)} akan ditarik langsung dari tabungan likuid saat ini.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ] else if (_selectedScenario == 'DEPENDENT') ...[
            const Text('Estimasi Biaya Bulanan Tanggungan Baru:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _dependentCost,
                    min: 500000,
                    max: 5000000,
                    divisions: 45,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _dependentCost = val),
                  ),
                ),
                Text('${(_dependentCost / 1000000).toStringAsFixed(1)} Jt', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: AppStyles.s),
            const Text('Berapa Bulan Periode Simulasi Tanggungan:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _durationMonths,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _durationMonths = val),
                  ),
                ),
                Text('${_durationMonths.round()} Bulan', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInflationRow(String time, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          Text(_formatCurrency(value), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultCard(FamilyFinanceProfile profile) {
    final currentScore = ref.read(fvsStateProvider)?.totalScore ?? 100;
    final projectedScore = _latestResult!.projectedScore;
    final scoreDiff = projectedScore - currentScore;

    final beforeColor = AppColors.getScoreColor(currentScore);
    final afterColor = AppColors.getScoreColor(projectedScore);

    return Container(
      padding: const EdgeInsets.all(AppStyles.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppStyles.radiusMedium,
        border: Border.all(color: afterColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: afterColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Skor Awal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(
                    '$currentScore',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: beforeColor),
                  ),
                  Text(
                    AppColors.getScoreCategory(currentScore).toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: beforeColor),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward, color: AppColors.textSecondary, size: 28),
              Column(
                children: [
                  const Text('Skor Proyeksi', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(
                    '$projectedScore',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: afterColor),
                  ),
                  Text(
                    AppColors.getScoreCategory(projectedScore).toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: afterColor),
                  ),
                ],
              ),
            ],
          ),
          
          if (scoreDiff != 0) ...[
            const SizedBox(height: AppStyles.m),
            Center(
              child: Text(
                'Kapasitas Ketahanan Finansial Turun ${scoreDiff.abs()} Poin',
                style: const TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
          
          const Divider(color: AppColors.surfaceCard, height: AppStyles.l),

          _buildResultRow(
            icon: LucideIcons.hourglass,
            label: 'Survival Month (Bulan Bertahan)',
            value: _latestResult!.survivalMonths <= 0 
                ? '0 Bulan (Uang habis!)'
                : '${_latestResult!.survivalMonths} Bulan',
            valueColor: _latestResult!.survivalMonths >= 6.0 ? AppColors.safe : _latestResult!.survivalMonths >= 3.0 ? AppColors.warning : AppColors.critical,
          ),
          const SizedBox(height: AppStyles.s),

          _buildResultRow(
            icon: LucideIcons.trendingDown,
            label: 'Defisit Bulanan Skenario',
            value: _formatCurrency(_latestResult!.monthlyDeficit),
            valueColor: AppColors.critical,
          ),
          const SizedBox(height: AppStyles.s),

          _buildResultRow(
            icon: LucideIcons.piggyBank,
            label: 'Estimasi Tabungan Tersisa',
            value: _formatCurrency((profile.liquidSavings - (_latestResult!.monthlyDeficit * _latestResult!.scenarioDurationMonths)).clamp(0, double.infinity)),
            valueColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: AppStyles.s),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor, fontSize: 14),
        ),
      ],
    );
  }
}
