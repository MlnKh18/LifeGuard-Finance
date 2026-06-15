import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/app_providers.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Sandwich';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showAddPostDialog() {
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
                'Buat Diskusi Baru',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.surface,
                      value: _selectedCategory,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppStyles.inputDecoration(
                        labelText: 'Kategori Topik',
                        prefixIcon: const Icon(LucideIcons.tag, color: AppColors.accent),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Sandwich', child: Text('Generasi Sandwich')),
                        DropdownMenuItem(value: 'Emergency', child: Text('Dana Darurat')),
                        DropdownMenuItem(value: 'Debt', child: Text('Beban Cicilan/Utang')),
                        DropdownMenuItem(value: 'General', child: Text('Umum/Investasi')),
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
                      controller: _titleController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppStyles.inputDecoration(
                        labelText: 'Judul Pertanyaan/Cerita',
                      ),
                    ),
                    const SizedBox(height: AppStyles.m),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppStyles.inputDecoration(
                        labelText: 'Tulis isi postingan Anda...',
                      ),
                    ),
                  ],
                ),
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
                    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                      ref.read(communityProvider.notifier).addPost(
                            _titleController.text,
                            _selectedCategory,
                            _contentController.text,
                          );
                      ref.read(rewardPointsProvider.notifier).addPoints(15);
                      _titleController.clear();
                      _contentController.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diskusi berhasil dikirim! +15 Poin Kontribusi didapatkan.')),
                      );
                    }
                  },
                  child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final score = ref.watch(fvsStateProvider);
    final posts = ref.watch(communityProvider);
    final rewards = ref.watch(rewardPointsProvider);

    String literacyTitle = 'Modul: Pentingnya Diversifikasi Finansial';
    String literacyDesc = 'Memiliki lebih dari satu sumber pendapatan membantu keluarga menyerap guncangan PHK mendadak dengan lebih baik. Mulailah membangun side-gig atau skill digital baru.';
    if (score != null) {
      final emergency = score.emergencyFundScore;
      final debt = score.debtBurdenScore;
      final protection = score.protectionReadinessScore;

      if (emergency <= debt && emergency <= protection) {
        literacyTitle = 'Modul: Membangun Dana Darurat Taktis';
        literacyDesc = 'Dana darurat harus disimpan pada instrumen likuid (misal RDPU atau tabungan terpisah). Targetkan menyisihkan 10% pendapatan per bulan hingga mencapai 3-6 bulan kebutuhan pokok keluarga.';
      } else if (debt <= emergency && debt <= protection) {
        literacyTitle = 'Modul: Strategi Debt Snowball vs Debt Avalanche';
        literacyDesc = 'Metode Snowball menyarankan pelunasan utang nominal terkecil dahulu untuk efek psikologis positif. Avalanche memprioritaskan utang dengan suku bunga tertinggi untuk meminimalkan beban biaya bunga.';
      } else if (protection <= emergency && protection <= debt) {
        literacyTitle = 'Modul: Memahami Proteksi BPJS dan Asuransi';
        literacyDesc = 'Proteksi asuransi kesehatan dasar (BPJS) wajib dimiliki setiap keluarga Indonesia. Asuransi jiwa dibutuhkan khusus bagi pencari nafkah utama untuk menjamin biaya hidup anak jika terjadi musibah.';
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edukasi & Komunitas'),
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(icon: Icon(LucideIcons.graduationCap), text: 'Literasi Finansial'),
              Tab(icon: Icon(LucideIcons.messageSquare), text: 'Forum Diskusi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Literasi Finansial
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppStyles.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppStyles.radiusMedium,
                        border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 1),
                      ),
                      padding: const EdgeInsets.all(AppStyles.m),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.accent.withOpacity(0.2),
                            child: const Icon(LucideIcons.award, color: AppColors.accent, size: 32),
                          ),
                          const SizedBox(width: AppStyles.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rewards.badgeLevel,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Poin Kontribusi: ${rewards.points} Poin',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppStyles.l),
                    const Text(
                      'Modul Edukasi Kontekstual',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppStyles.s),
                    Container(
                      width: double.infinity,
                      decoration: AppStyles.cardDecoration,
                      padding: const EdgeInsets.all(AppStyles.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppStyles.s, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'REKOMENDASI PERSONAL',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppStyles.s),
                          Text(
                            literacyTitle,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppStyles.s),
                          Text(
                            literacyDesc,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppStyles.l),
                    const Text(
                      'Glosarium Finansial Cepat',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppStyles.s),
                    _buildGlossaryItem('Financial Vulnerability Score (FVS)', 'Skor indeks 0-100 untuk menilai kesiapan dan ketahanan finansial keluarga menghadapi krisis.'),
                    _buildGlossaryItem('Generasi Sandwich', 'Kondisi individu yang menanggung beban finansial tiga generasi sekaligus: orang tua, diri sendiri, dan anak.'),
                    _buildGlossaryItem('Emergency Fund Runway', 'Jumlah bulan tabungan likuid yang mampu menutupi pengeluaran rutin keluarga jika pendapatan berhenti total.'),
                  ],
                ),
              ),
            ),

            // Tab 2: Forum Diskusi
            Padding(
              padding: const EdgeInsets.all(AppStyles.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Forum Dukungan Keluarga',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusSmall),
                          padding: const EdgeInsets.symmetric(horizontal: AppStyles.s, vertical: AppStyles.xs),
                        ),
                        onPressed: _showAddPostDialog,
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Tanya', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.s),
                  Expanded(
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppStyles.s),
                          decoration: AppStyles.cardDecoration,
                          padding: const EdgeInsets.all(AppStyles.m),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.surfaceCard,
                                    child: Text(
                                      post.author.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: AppStyles.s),
                                  Text(
                                    post.author,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      post.category.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primaryLight,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppStyles.s),
                              Text(
                                post.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: AppStyles.xs),
                              Text(
                                post.content,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const Divider(height: AppStyles.l, color: AppColors.surfaceCard),
                              Row(
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                    onPressed: () {
                                      ref.read(communityProvider.notifier).supportPost(post.postId);
                                      ref.read(rewardPointsProvider.notifier).addPoints(5);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Anda mendukung diskusi ini. +5 Poin Kontribusi diberikan!')),
                                      );
                                    },
                                    icon: const Icon(LucideIcons.thumbsUp, size: 16, color: AppColors.accent),
                                    label: Text(
                                      'Bantu (${post.supportCount})',
                                      style: const TextStyle(color: AppColors.accent, fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: AppStyles.m),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                    onPressed: () {
                                      ref.read(communityProvider.notifier).addComment(post.postId);
                                      ref.read(rewardPointsProvider.notifier).addPoints(10);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Komentar berhasil ditambahkan! +10 Poin.')),
                                      );
                                    },
                                    icon: const Icon(LucideIcons.messageCircle, size: 16, color: AppColors.textSecondary),
                                    label: Text(
                                      'Jawab (${post.commentsCount})',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _buildGlossaryItem(String term, String definition) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppStyles.s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppStyles.radiusSmall,
        border: Border.all(color: AppColors.surfaceCard, width: 1),
      ),
      padding: const EdgeInsets.all(AppStyles.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            term,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            definition,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
