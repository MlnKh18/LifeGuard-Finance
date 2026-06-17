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

class _SimulationViewState extends State<SimulationView> {
  final _formKey = GlobalKey<FormState>();
  final _paramController = TextEditingController();
  final _secondaryParamController = TextEditingController();

  ScenarioType _selectedScenario = ScenarioType.lossOfIncome;

  @override
  void dispose() {
    _paramController.dispose();
    _secondaryParamController.dispose();
    super.dispose();
  }

  void _onScenarioChanged(ScenarioType? scenario) {
    if (scenario == null) return;
    setState(() {
      _selectedScenario = scenario;
      _paramController.clear();
      _secondaryParamController.clear();
    });
  }

  String _getParamLabel() {
    switch (_selectedScenario) {
      case ScenarioType.lossOfIncome:
        return 'Durasi Kehilangan Pendapatan (Bulan)';
      case ScenarioType.medicalEmergency:
        return 'Estimasi Biaya Medis Darurat (Rp)';
      case ScenarioType.interestRateIncrease:
        return 'Kenaikan Cicilan Per Bulan (Rp)';
      case ScenarioType.inflationNeeds:
        return 'Laju Inflasi Pokok (%)';
      case ScenarioType.educationEmergency:
        return 'Biaya Pendidikan Mendadak (Rp)';
      case ScenarioType.increasedDependents:
        return 'Jumlah Tanggungan yang Bertambah';
    }
  }

  String _getParamHint() {
    switch (_selectedScenario) {
      case ScenarioType.lossOfIncome:
        return 'Contoh: 6 (bulan)';
      case ScenarioType.medicalEmergency:
        return 'Contoh: 15000000';
      case ScenarioType.interestRateIncrease:
        return 'Contoh: 500000';
      case ScenarioType.inflationNeeds:
        return 'Contoh: 10 (%)';
      case ScenarioType.educationEmergency:
        return 'Contoh: 8000000';
      case ScenarioType.increasedDependents:
        return 'Contoh: 1 (jiwa)';
    }
  }

  void _runSimulation() {
    if (!_formKey.currentState!.validate()) return;

    final value = double.parse(_paramController.text);
    double? secondaryValue;
    if (_selectedScenario == ScenarioType.inflationNeeds) {
      secondaryValue = double.tryParse(_secondaryParamController.text);
    }

    final input = SimulationInput(
      scenarioType: _selectedScenario,
      parameterValue: value,
      secondaryParameterValue: secondaryValue,
    );

    context.read<SimulationBloc>().add(RunSimulation(input));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulasi Skenario Darurat'),
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

                // Form Simulation Selector
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pilih Skenario Darurat', style: AppTextStyles.heading3),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<ScenarioType>(
                          initialValue: _selectedScenario,
                          items: _buildDropdownItems(),
                          onChanged: _onScenarioChanged,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _paramController,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            labelText: _getParamLabel(),
                            hintText: _getParamHint(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Parameter wajib diisi';
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
                        if (_selectedScenario == ScenarioType.inflationNeeds) ...[
                          const SizedBox(height: 16),
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
                                return 'Pengeluaran kebutuhan pokok wajib diisi';
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
                        children: const [
                          Icon(Icons.query_stats_rounded, size: 48, color: AppColors.border),
                          SizedBox(height: 12),
                          Text(
                            'Belum Ada Hasil Simulasi',
                            style: AppTextStyles.heading3,
                          ),
                          SizedBox(height: 4),
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

  List<DropdownMenuItem<ScenarioType>> _buildDropdownItems() {
    return const [
      DropdownMenuItem(
        value: ScenarioType.lossOfIncome,
        child: Text('Kehilangan Pendapatan / PHK'),
      ),
      DropdownMenuItem(
        value: ScenarioType.medicalEmergency,
        child: Text('Biaya Medis Mendadak'),
      ),
      DropdownMenuItem(
        value: ScenarioType.interestRateIncrease,
        child: Text('Kenaikan Cicilan/Hutang'),
      ),
      DropdownMenuItem(
        value: ScenarioType.inflationNeeds,
        child: Text('Inflasi Kebutuhan Pokok'),
      ),
      DropdownMenuItem(
        value: ScenarioType.educationEmergency,
        child: Text('Biaya Pendidikan Mendadak'),
      ),
      DropdownMenuItem(
        value: ScenarioType.increasedDependents,
        child: Text('Bertambah Tanggungan Keluarga'),
      ),
    ];
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

        // Score Comparison Card
        AppCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('FVS Sebelum', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        result.fvsBefore.score.toStringAsFixed(0),
                        style: AppTextStyles.heading1.copyWith(fontSize: 32, color: beforeColor),
                      ),
                      Text(result.fvsBefore.category, style: TextStyle(color: beforeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 28),
                  Column(
                    children: [
                      const Text('FVS Setelah', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        result.fvsAfter.score.toStringAsFixed(0),
                        style: AppTextStyles.heading1.copyWith(fontSize: 32, color: afterColor),
                      ),
                      Text(result.fvsAfter.category, style: TextStyle(color: afterColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_down_rounded, color: AppColors.riskCritical, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Skor Menurun Sebesar: -${result.scoreDrop.toStringAsFixed(1)} Poin',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.riskCritical),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (result.inflationResult != null) ...[
          _buildInflationResultSection(result.inflationResult!),
        ] else ...[
          // Financial Metrics Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daya Tahan & Kerugian', style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                const Divider(height: 20, color: AppColors.border),
                _buildMetricRow(
                  icon: Icons.timer_outlined,
                  title: 'Daya Tahan Dana Darurat',
                  value: result.monthsEmergencyFundLasts >= 99.0
                      ? 'Aman / Tidak Terpengaruh'
                      : '${result.monthsEmergencyFundLasts.toStringAsFixed(1)} Bulan',
                  color: result.monthsEmergencyFundLasts < 3.0 ? AppColors.riskCritical : AppColors.riskSafe,
                ),
                const SizedBox(height: 12),
                _buildMetricRow(
                  icon: Icons.money_off_rounded,
                  title: 'Proyeksi Defisit Skenario',
                  value: result.potentialDeficit == 0
                      ? 'Tidak Ada Defisit'
                      : 'Rp ${_formatRupiah(result.potentialDeficit)}',
                  color: result.potentialDeficit > 0 ? AppColors.riskCritical : AppColors.riskSafe,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Affected Indicators Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Indikator FVS yang Terdampak', style: AppTextStyles.heading3),
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
        ],
        const SizedBox(height: 16),

        // Recommendation Box
        AppCard(
          color: AppColors.riskWarningBg.withAlpha(76),
          border: Border.all(color: AppColors.riskWarning),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.lightbulb_outline_rounded, color: AppColors.riskWarning),
                  SizedBox(width: 8),
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
                children: const [
                  Icon(Icons.trending_up_rounded, color: AppColors.riskCritical),
                  SizedBox(width: 8),
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

  Widget _buildMetricRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: AppTextStyles.bodyMedium),
        ),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: color, fontSize: 14),
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
          const Text(
            'Profil Keuangan Belum Lengkap',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
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
          const Text('Terjadi Kesalahan', style: AppTextStyles.heading2),
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
