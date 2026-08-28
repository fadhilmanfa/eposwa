import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// Halaman Pengerjaan Ujian & Skrining untuk Peserta Tertentu.
class InteractiveExamView extends StatefulWidget {
  final Map<String, dynamic> participant;
  final ValueChanged<Map<String, dynamic>> onFinishExam;
  final VoidCallback onCancel;

  const InteractiveExamView({
    super.key,
    required this.participant,
    required this.onFinishExam,
    required this.onCancel,
  });

  @override
  State<InteractiveExamView> createState() => _InteractiveExamViewState();
}

class _InteractiveExamViewState extends State<InteractiveExamView> {
  final Map<int, int> _answers = {};
  late TextEditingController _catatanController;

  final List<Map<String, dynamic>> _questions = const [
    {
      'kategori': 'Tes Pengalaman & Pengetahuan (Bobot 30%)',
      'tanya':
          '1. Apakah Anda memiliki pengalaman aktif dalam kegiatan posyandu atau pendataan kesehatan warga?',
      'opsi': [
        {'text': 'Sangat Berpengalaman (> 2 tahun)', 'score': 100},
        {'text': 'Pernah Mengikuti (1 - 2 tahun)', 'score': 85},
        {'text': 'Pemula / Belum Pernah (Bersedia Belajar)', 'score': 70},
      ],
    },
    {
      'kategori': 'Skrining Kesehatan Jiwa & SRQ (Bobot 40%)',
      'tanya':
          '2. Dalam 30 hari terakhir, seberapa sering Anda merasa cemas berlebih atau sulit beristirahat?',
      'opsi': [
        {'text': 'Tidak Pernah / Kondisi Sangat Stabil', 'score': 100},
        {'text': 'Kadang-kadang saat beban kerja tinggi', 'score': 85},
        {'text': 'Cukup sering merasa kewalahan', 'score': 60},
      ],
    },
    {
      'kategori': 'Skrining Kesehatan Jiwa & Sikap (Bobot 40%)',
      'tanya':
          '3. Bagaimana tindakan awal Anda jika mendapati warga yang menunjukkan gejala depresi atau kecemasan berat?',
      'opsi': [
        {
          'text':
              'Melakukan pendekatan empatik dan segera lapor ke Puskesmas/Kader Jiwa',
          'score': 100
        },
        {
          'text':
              'Memberikan saran pribadi tanpa koordinasi fasilitas kesehatan',
          'score': 70
        },
        {'text': 'Menghindari interaksi langsung', 'score': 40},
      ],
    },
    {
      'kategori': 'Kesiapan Teknis & Digital (Bobot 30%)',
      'tanya':
          '4. Apakah Anda bersedia dan terbiasa mengoperasikan aplikasi sistem informasi (ePOSWA) untuk pencatatan?',
      'opsi': [
        {
          'text':
              'Sangat Siap & Terbiasa Menggunakan Smartphone/Komputer',
          'score': 100
        },
        {'text': 'Cukup Siap dengan panduan awal', 'score': 85},
        {'text': 'Membutuhkan bimbingan intensif', 'score': 65},
      ],
    },
    {
      'kategori': 'Etika & Kerahasiaan Medis (Bobot 30%)',
      'tanya':
          '5. Bagaimana pemahaman Anda mengenai prinsip kerahasiaan data medis dan riwayat kejiwaan peserta?',
      'opsi': [
        {
          'text':
              'Sangat Memahami dan wajib menjaga kerahasiaan data 100%',
          'score': 100
        },
        {
          'text':
              'Cukup Memahami bahwa data tidak boleh disebar sembarangan',
          'score': 80
        },
        {'text': 'Belum terlalu paham batasan kerahasiaan data', 'score': 50},
      ],
    },
    {
      'kategori': 'Komitmen Waktu & Jadwal (Bobot 30%)',
      'tanya':
          '6. Seberapa siap Anda meluangkan waktu secara konsisten untuk sesi pendampingan warga?',
      'opsi': [
        {
          'text':
              'Sangat Siap dan fleksibel mengikuti jadwal kunjungan',
          'score': 100
        },
        {'text': 'Siap pada jam-jam tertentu', 'score': 80},
        {'text': 'Waktu sangat terbatas', 'score': 55},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _catatanController = TextEditingController(
      text: widget.participant['catatan']?.toString() ?? '',
    );

    // Pre-populate answers if the participant already has test scores
    final skor = (widget.participant['skor'] as num?)?.toInt() ?? 0;
    if (skor >= 85) {
      _answers[0] = 0;
      _answers[1] = 0;
      _answers[2] = 0;
      _answers[3] = 0;
      _answers[4] = 0;
      _answers[5] = 0;
    } else if (skor >= 70) {
      _answers[0] = 1;
      _answers[1] = 1;
      _answers[2] = 0;
      _answers[3] = 1;
      _answers[4] = 0;
      _answers[5] = 1;
    } else if (skor > 0) {
      _answers[0] = 2;
      _answers[1] = 2;
      _answers[2] = 1;
      _answers[3] = 2;
      _answers[4] = 1;
      _answers[5] = 2;
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _calculateAndSubmit() {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Mohon jawab seluruh butir soal sebelum menyelesaikan ujian!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final q1Score = _questions[0]['opsi'][_answers[0]!]['score'] as int;
    final q4Score = _questions[3]['opsi'][_answers[3]!]['score'] as int;
    final q5Score = _questions[4]['opsi'][_answers[4]!]['score'] as int;
    final skorPengetahuan = ((q1Score + q4Score + q5Score) / 3).round();

    final q2Score = _questions[1]['opsi'][_answers[1]!]['score'] as int;
    final q3Score = _questions[2]['opsi'][_answers[2]!]['score'] as int;
    final skorPsikologis = ((q2Score + q3Score) / 2).round();

    final skorWawancara = (_questions[5]['opsi'][_answers[5]!]['score'] as int);

    final finalScore = ((skorPengetahuan * 0.3) +
            (skorPsikologis * 0.4) +
            (skorWawancara * 0.3))
        .round();

    final status = finalScore >= 70 ? 'Lulus' : 'Tidak Lulus';

    final updated = Map<String, dynamic>.from(widget.participant);
    updated['skor'] = finalScore;
    updated['status'] = status;
    updated['skorPengetahuan'] = skorPengetahuan;
    updated['skorPsikologis'] = skorPsikologis;
    updated['skorWawancara'] = skorWawancara;
    final customNote = _catatanController.text.trim();
    updated['catatan'] = customNote.isNotEmpty
        ? customNote
        : (finalScore >= 70
            ? 'Peserta memenuhi seluruh indikator kelulusan ePOSWA.'
            : 'Nilai di bawah passing grade 70.');

    widget.onFinishExam(updated);
  }

  @override
  Widget build(BuildContext context) {
    final answeredCount = _answers.length;
    final progress = answeredCount / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Navigation Button
        InkWell(
          onTap: widget.onCancel,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_back_rounded,
                    size: 18, color: AppColors.textDark),
                SizedBox(width: 8),
                Text(
                  'Kembali ke Daftar Peserta',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Participant Info Header & Progress Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.heroButton.withValues(alpha: 0.12),
                child: Text(
                  (widget.participant['nama'] as String? ?? 'P')[0]
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.heroButton,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.participant['nama'] ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.participant['program'] ?? '-',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIK: ${widget.participant['nik'] ?? '-'} • Sesi: ${widget.participant['sesi'] ?? 'Ujian Potensi & Skrining'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Progress Bar
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$answeredCount dari ${_questions.length} Soal Dijawab',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heroButton,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.heroButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Questions List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, qIndex) {
            final q = _questions[qIndex];
            final options = q['opsi'] as List<Map<String, dynamic>>;
            final selectedOpt = _answers[qIndex];

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selectedOpt != null
                      ? AppColors.heroButton.withValues(alpha: 0.4)
                      : const Color(0xFFE2E8F0),
                  width: selectedOpt != null ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q['tanya'],
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Column(
                    children: List.generate(options.length, (optIndex) {
                      final opt = options[optIndex];
                      final isChosen = selectedOpt == optIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _answers[qIndex] = optIndex;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? AppColors.heroButton.withValues(alpha: 0.08)
                                  : const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isChosen
                                    ? AppColors.heroButton
                                    : const Color(0xFFE2E8F0),
                                width: isChosen ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isChosen
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  size: 18,
                                  color: isChosen
                                      ? AppColors.heroButton
                                      : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt['text'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isChosen
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isChosen
                                          ? AppColors.textDark
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Catatan Evaluator Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catatan / Rekomendasi Penguji (Opsional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _catatanController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText:
                      'Tambahkan catatan observasi terhadap peserta saat ujian...',
                  hintStyle: const TextStyle(
                      fontSize: 12.5, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.heroButton, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Bottom Action Buttons
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _answers.clear()),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset Jawaban',
                    style: TextStyle(color: AppColors.textDark, fontSize: 13)),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Batal',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _calculateAndSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.heroButton,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 18),
                    label: const Text(
                      'Selesaikan & Simpan Hasil Ujian',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
