import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/entities/simulation_input.dart';
import '../../domain/entities/simulation_result.dart';
import '../../domain/entities/inflation_impact_result.dart';
import '../bloc/simulation_bloc.dart';
import '../bloc/simulation_event.dart';
import '../bloc/simulation_state.dart';

class SimulationPage extends StatelessWidget {
  const SimulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SimulationBloc>(
      create: (context) => getIt<SimulationBloc>()..add(LoadSavedSimulation()),
      child: const SimulationView(),
    );
  }
}

class SimulationView extends StatefulWidget {
  const SimulationView({super.key});

  @override
  State<SimulationView> createState() => _SimulationViewState();
}

/// Min/max/step configuration for the scenario's primary parameter slider.
class _SliderConfig {
  final double min;
  final double max;
  final int divisions;
  final double initial;

  const _SliderConfig({
    required this.min,
    required this.max,
    required this.divisions,
    required this.initial,
  });
}

class _SimulationViewState extends State<SimulationView> {
  final _formKey = GlobalKey<FormState>();
  final _secondaryParamController = TextEditingController();

  ScenarioType _selectedScenario = ScenarioType.lossOfIncome;
  late double _primaryParamValue = _getSliderConfig(_selectedScenario).initial;

  @override
  void dispose() {
    _secondaryParamController.dispose();
    super.dispose();
  }

  void _onScenarioChanged(ScenarioType scenario) {
    if (scenario == _selectedScenario) return;
    setState(() {
      _selectedScenario = scenario;
      _primaryParamValue = _getSliderConfig(scenario).initial;
      _secondaryParamController.clear();
    });
  }

  static IconData _getScenarioIcon(ScenarioType type) {
    switch (type) {
      case ScenarioType.lossOfIncome:
        return Icons.work_off_rounded;
      case ScenarioType.medicalEmergency:
        return Icons.local_hospital_rounded;
      case ScenarioType.interestRateIncrease:
        return Icons.credit_card_rounded;
      case ScenarioType.inflationNeeds:
        return Icons.trending_up_rounded;
      case ScenarioType.educationEmergency:
        return Icons.school_rounded;
      case ScenarioType.increasedDependents:
        return Icons.family_restroom_rounded;
    }
  }

  static String _getScenarioChipLabel(ScenarioType type) {
    switch (type) {
      case ScenarioType.lossOfIncome:
        return 'PHK';
      case ScenarioType.medicalEmergency:
        return 'Medis';
      case ScenarioType.interestRateIncrease:
        return 'Cicilan';
      case ScenarioType.inflationNeeds:
        return 'Inflasi';
      case ScenarioType.educationEmergency:
        return 'Pendidikan';
      case ScenarioType.increasedDependents:
        return 'Tanggungan';
    }
  }

  static _SliderConfig _getSliderConfig(ScenarioType type) {
    switch (type) {
      case ScenarioType.lossOfIncome:
        return const _SliderConfig(min: 1, max: 12, divisions: 11, initial: 6);
      case ScenarioType.medicalEmergency:
        return const _SliderConfig(min: 1000000, max: 50000000, divisions: 49, initial: 15000000);
      case ScenarioType.interestRateIncrease:
        return const _SliderConfig(min: 100000, max: 5000000, divisions: 49, initial: 500000);
      case ScenarioType.inflationNeeds:
        return const _SliderConfig(min: 1, max: 50, divisions: 49, initial: 10);
      case ScenarioType.educationEmergency:
        return const _SliderConfig(min: 1000000, max: 50000000, divisions: 49, initial: 8000000);
      case ScenarioType.increasedDependents:
        return const _SliderConfig(min: 1, max: 5, divisions: 4, initial: 1);
    }
  }

  String _getParamLabel() {
    switch (_selectedScenario) {
      case ScenarioType.lossOfIncome:
        return 'Estimasi Lama Kehilangan Pendapatan';
      case ScenarioType.medicalEmergency:
        return 'Estimasi Biaya Medis Darurat';
      case ScenarioType.interestRateIncrease:
        return 'Kenaikan Cicilan Per Bulan';
      case ScenarioType.inflationNeeds:
        return 'Laju Inflasi Pokok';
      case ScenarioType.educationEmergency:
        return 'Biaya Pendidikan Mendadak';
      case ScenarioType.increasedDependents:
        return 'Jumlah Tanggungan Bertambah';
    }
  }

  String _formatSliderValue(ScenarioType type, double value) {
    switch (type) {
      case ScenarioType.lossOfIncome:
        return '${value.toStringAsFixed(0)} Bulan';
      case ScenarioType.medicalEmergency:
      case ScenarioType.interestRateIncrease:
      case ScenarioType.educationEmergency:
        return 'Rp ${_formatRupiah(value)}';
      case ScenarioType.inflationNeeds:
        return '${value.toStringAsFixed(0)}%';
      case ScenarioType.increasedDependents:
        return '${value.toStringAsFixed(0)} Orang';
    }
  }

  void _runSimulation() {
    if (!_formKey.currentState!.validate()) return;

    double? secondaryValue;
    if (_selectedScenario == ScenarioType.inflationNeeds) {
      secondaryValue = double.tryParse(_secondaryParamController.text);
    }

    final input = SimulationInput(
      scenarioType: _selectedScenario,
      parameterValue: _primaryParamValue,
      secondaryParameterValue: secondaryValue,
    );

    context.read<SimulationBloc>().add(RunSimulation(input));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simulasi Sandbox', style: AppTextStyles.heading3),
      ),
      body: BlocBuilder<SimulationBloc, SimulationState>(
        builder: (context, state) {
          if (state is SimulationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is SimulationNoProfile) {
            return _buildNoProfileView();
          }

          if (state is SimulationError) {
            return _buildErrorView(state.message);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Uji Ketahanan Finansial',
                  subtitle: 'Simulasikan berbagai skenario krisis dan lihat dampaknya terhadap skor kerentanan finansial keluarga Anda secara instan.',
                ),
                const SizedBox(height: 12),

                // Scenario Selector (Chips)
                Text('Skenario Bencana', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ScenarioType.values.map((type) {
                    final isSelected = type == _selectedScenario;
                    return ChoiceChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: Icon(
                        _getScenarioIcon(type),
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      label: Text(_getScenarioChipLabel(type)),
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (_) => _onScenarioChanged(type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Parameter Slider Card
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(_getParamLabel(), style: AppTextStyles.heading3.copyWith(fontSize: 14)),
                            ),
                            Text(
                              _formatSliderValue(_selectedScenario, _primaryParamValue),
                              style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        Slider(
                          value: _primaryParamValue,
                          min: _getSliderConfig(_selectedScenario).min,
                          max: _getSliderConfig(_selectedScenario).max,
                          divisions: _getSliderConfig(_selectedScenario).divisions,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.border,
                          onChanged: (val) => setState(() => _primaryParamValue = val),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatSliderValue(_selectedScenario, _getSliderConfig(_selectedScenario).min),
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                _formatSliderValue(_selectedScenario, _getSliderConfig(_selectedScenario).max),
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (_selectedScenario == ScenarioType.inflationNeeds) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _secondaryParamController,
                            keyboardType: TextInputType.number,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              labelText: 'Pengeluaran Kebutuhan Pokok Bulanan (Rp)',
                              hintText: 'Contoh: 4000000',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return null; // Optional - calculator falls back to a default
                              }
                              final parsed = double.tryParse(val);
                              if (parsed == null) {
                                return 'Harus berupa angka';
                              }
                              if (parsed <= 0) {
                                return 'Harus lebih besar dari 0';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Jalankan Simulasi Krisis',
                          icon: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 18),
                          onPressed: _runSimulation,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Output Result Area
                if (state is SimulationSuccess) ...[
                  _buildSimulationResultContent(state.result),
                ] else ...[
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.query_stats_rounded, size: 48, color: AppColors.border),
                          const SizedBox(height: 12),
                          Text(
                            'Belum Ada Hasil Simulasi',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Silakan pilih skenario di atas dan klik tombol Jalankan Simulasi.',
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimulationResultContent(SimulationResult result) {
    Color beforeColor = _getScoreColor(result.fvsBefore.score);
    Color afterColor = _getScoreColor(result.fvsAfter.score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Hasil Dampak Simulasi',
          subtitle: 'Kondisi proyeksi keuangan keluarga Anda pasca guncangan finansial.',
        ),
        const SizedBox(height: 8),

        // Financial Vitality Score Impact (rings)
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Dampak Skor Vitalitas Finansial',
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScoreRing(score: result.fvsBefore.score, color: beforeColor, label: 'SAAT INI'),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          '-${result.scoreDrop.toStringAsFixed(0)} Pts',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.riskCritical, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  _ScoreRing(score: result.fvsAfter.score, color: afterColor, label: 'PROYEKSI'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats (Runway, Defisit, Sisa Dana Darurat)
        _buildStatTile(
          icon: Icons.flight_takeoff_rounded,
          label: 'Daya Tahan Dana Darurat (Runway)',
          value: result.monthsEmergencyFundLasts >= 99.0
              ? 'Aman / Tidak Terpengaruh'
              : '${result.monthsEmergencyFundLasts.toStringAsFixed(1)} Bulan',
          accentColor: result.monthsEmergencyFundLasts < 3.0 ? AppColors.riskCritical : AppColors.riskSafe,
        ),
        const SizedBox(height: 10),
        _buildStatTile(
          icon: Icons.money_off_rounded,
          label: 'Proyeksi Defisit Skenario',
          value: result.potentialDeficit == 0
              ? 'Tidak Ada Defisit'
              : 'Rp ${_formatRupiah(result.potentialDeficit)}',
          accentColor: result.potentialDeficit > 0 ? AppColors.riskCritical : AppColors.riskSafe,
        ),
        const SizedBox(height: 10),
        _buildStatTile(
          icon: Icons.savings_rounded,
          label: 'Sisa Dana Darurat',
          value: 'Rp ${_formatRupiah(result.remainingLiquidSavings)}',
          accentColor: AppColors.primary,
        ),
        const SizedBox(height: 16),

        if (result.inflationResult != null) ...[
          _buildInflationResultSection(result.inflationResult!),
          const SizedBox(height: 16),
        ],

        // Affected Indicators Card
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Indikator FVS yang Terdampak', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              ...result.affectedIndicators.map((ind) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded, color: AppColors.riskCritical),
                        Expanded(
                          child: Text(ind, style: AppTextStyles.bodyMedium),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Recommendation Box
        AppCard(
          color: AppColors.riskWarningBg.withAlpha(76),
          border: Border.all(color: AppColors.riskWarning),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppColors.riskWarning),
                  const SizedBox(width: 8),
                  Text('Rekomendasi Awal Lifeguard', style: AppTextStyles.heading3),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result.recommendation,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recommendation CTA Button
        PrimaryButton(
          text: 'Lihat Rencana Mitigasi Lengkap',
          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          onPressed: () => context.push('/recommendation'),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(value, style: AppTextStyles.heading3.copyWith(color: accentColor)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInflationResultSection(InflationImpactResult inflation) {
    final isCritical = inflation.monthsEmergencyFundLastsAfter < 3.0;
    final isWarning = inflation.monthsEmergencyFundLastsAfter < 6.0 && inflation.monthsEmergencyFundLastsAfter >= 3.0;

    final warningColor = isCritical
        ? AppColors.riskCritical
        : isWarning
            ? AppColors.riskWarning
            : AppColors.riskSafe;

    final warningBg = isCritical
        ? AppColors.riskCritical.withAlpha(26)
        : isWarning
            ? AppColors.riskWarning.withAlpha(26)
            : AppColors.riskSafe.withAlpha(26);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: AppColors.riskCritical),
                  const SizedBox(width: 8),
                  Text('Kalkulasi Dampak Inflasi', style: AppTextStyles.heading3),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),

              // 1. Pengeluaran
              _buildInflationMetricRow(
                title: 'Pengeluaran Pokok Baru',
                valueBefore: 'Rp ${_formatRupiah(inflation.routineExpensesAfter - inflation.expenseIncrease)}',
                valueAfter: 'Rp ${_formatRupiah(inflation.routineExpensesAfter)}',
                badgeText: '+Rp ${_formatRupiah(inflation.expenseIncrease)}',
                badgeColor: AppColors.riskCritical,
              ),
              const Divider(height: 20, color: AppColors.border),

              // 2. Daya Tahan
              _buildInflationMetricRow(
                title: 'Daya Tahan Dana Darurat',
                valueBefore: '${inflation.monthsEmergencyFundLastsBefore.toStringAsFixed(1)} Bulan',
                valueAfter: '${inflation.monthsEmergencyFundLastsAfter.toStringAsFixed(1)} Bulan',
                badgeText: '-${(inflation.monthsEmergencyFundLastsBefore - inflation.monthsEmergencyFundLastsAfter).abs().toStringAsFixed(1)} Bulan',
                badgeColor: warningColor,
              ),
              const Divider(height: 20, color: AppColors.border),

              // 3. Skor FVS
              _buildInflationMetricRow(
                title: 'Estimasi Perubahan FVS',
                valueBefore: inflation.fvsScoreBefore.toStringAsFixed(0),
                valueAfter: inflation.fvsScoreAfter.toStringAsFixed(0),
                badgeText: '${inflation.fvsScoreChange.toStringAsFixed(0)} Poin',
                badgeColor: inflation.fvsScoreChange < 0 ? AppColors.riskCritical : AppColors.riskSafe,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Warning Message Box
        AppCard(
          color: warningBg,
          border: Border.all(color: warningColor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCritical
                    ? Icons.gavel_rounded
                    : isWarning
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                color: warningColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCritical
                          ? '🚨 BAHAYA DANA DARURAT KRITIS'
                          : isWarning
                              ? '⚠️ PERINGATAN WASPADA'
                              : '✅ KONDISI DANA DARURAT AMAN',
                      style: AppTextStyles.heading3.copyWith(color: warningColor, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      inflation.warningMessage,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInflationMetricRow({
    required String title,
    required String valueBefore,
    required String valueAfter,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sebelum', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(valueBefore, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Setelah', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Row(
                  children: [
                    Text(valueAfter, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: badgeColor)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.riskSafe;
    if (score >= 60) return AppColors.riskWarning;
    if (score >= 40) return AppColors.riskVulnerable;
    return AppColors.riskCritical;
  }

  String _formatRupiah(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  Widget _buildNoProfileView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.family_restroom_rounded,
            size: 100,
            color: AppColors.border,
          ),
          const SizedBox(height: 24),
          Text(
            'Profil Keuangan Belum Lengkap',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Lengkapi data profil keuangan keluarga terlebih dahulu sebelum memulai simulasi skenario darurat.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Lengkapi Profil Sekarang',
            onPressed: () => context.go('/family-profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.riskCritical),
          const SizedBox(height: 16),
          Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(errorMessage, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Coba Lagi',
            onPressed: () => context.read<SimulationBloc>().add(LoadSavedSimulation()),
          ),
        ],
      ),
    );
  }
}

/// A circular score badge used in the before/after comparison, matching the
/// Stitch "Financial Vitality Score Impact" ring pattern.
class _ScoreRing extends StatelessWidget {
  final double score;
  final Color color;
  final String label;

  const _ScoreRing({required this.score, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: color, width: 4),
            boxShadow: [
              BoxShadow(color: color.withAlpha(60), blurRadius: 12),
            ],
          ),
          child: Text(
            score.toStringAsFixed(0),
            style: AppTextStyles.dataDisplay.copyWith(fontSize: 28, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(letterSpacing: 1, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
