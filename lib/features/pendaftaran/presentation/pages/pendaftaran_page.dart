import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/core/services/session_service.dart';
import 'package:eposwa/core/widgets/animated_segmented_selector.dart';
import 'package:eposwa/features/pendaftaran/data/pendaftar_store.dart';
import 'package:eposwa/features/pendaftaran/data/peserta_repository.dart';

class PendaftaranPage extends StatefulWidget {
  final VoidCallback? onSuccessSubmit;
  final VoidCallback? onSubmitAndContinue;

  const PendaftaranPage({
    super.key,
    this.onSuccessSubmit,
    this.onSubmitAndContinue,
  });

  @override
  State<PendaftaranPage> createState() => _PendaftaranPageState();
}

class _PendaftaranPageState extends State<PendaftaranPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();

  String _jenisKelamin = 'Laki-laki';
  String? _tglLahir;
  String? _jamKunjungan;
  bool? _pernahKonsultasi;
  bool? _pernahDapatObat;
  bool _isSubmitting = false;
  bool _showRiwayatError = false;
  bool _showJadwalError = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  bool _validate() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final riwayatValid = _pernahKonsultasi != null && _pernahDapatObat != null;
    final jadwalValid = _tglLahir != null && _jamKunjungan != null;

    setState(() {
      _showRiwayatError = !riwayatValid;
      _showJadwalError = !jadwalValid;
    });

    if (!formValid || !riwayatValid || !jadwalValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua bidang isian yang wajib!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    _simpanKeStore();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 26,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pendaftaran Berhasil',
                softWrap: true,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Data pendaftaran peserta "${_namaController.text.trim()}" telah berhasil disimpan ke dalam sistem.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetForm();
              if (widget.onSuccessSubmit != null) {
                widget.onSuccessSubmit!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.heroButton,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmitAndContinue() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    _simpanKeStore();

    _resetForm();
    widget.onSubmitAndContinue?.call();
  }

  Future<void> _simpanKeStore() async {
    // keep legacy store for backward compat
    PendaftarStore.instance.add(
      Pendaftar(
        nama: _namaController.text.trim(),
        nik: _nikController.text.trim(),
        program: '-',
      ),
    );
    // also persist to DB
    try {
      final db = getAppDatabase();
      final repo = PesertaRepository(db);
      final existing = await repo.getByNik(_nikController.text.trim());
      if (existing != null) return; // skip duplicate NIK
      await repo.insertPeserta(
        nama: _namaController.text.trim(),
        nik: _nikController.text.trim(),
        noHp: _noHpController.text.trim(),
        jenisKelamin: _jenisKelamin,
        tglLahir: _tglLahir,
        alamat: _alamatController.text.trim().isEmpty ? null : _alamatController.text.trim(),
        pernahKonsultasi: _pernahKonsultasi,
        pernahDapatObat: _pernahDapatObat,
        tglKunjungan: _tglLahir,
        jamKunjungan: _jamKunjungan,
        createdBy: SessionService.currentAdmin?.id,
      );
    } catch (_) {}
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _nikController.clear();
    _alamatController.clear();
    _noHpController.clear();
    setState(() {
      _jenisKelamin = 'Laki-laki';
      _tglLahir = null;
      _jamKunjungan = null;
      _pernahKonsultasi = null;
      _pernahDapatObat = null;
      _showRiwayatError = false;
      _showJadwalError = false;
    });
  }

  Future<void> _pickTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tglLahir =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickJamKunjungan() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _jamKunjungan =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seksi 1: Data Diri
                _buildSectionHeader(
                  title: 'Form Data Diri',
                  subtitle: 'Informasi identitas pribadi peserta',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _buildFieldRow([
                      _buildTextField(
                        controller: _namaController,
                        label: 'Nama Lengkap *',
                        hint: 'Masukkan nama lengkap sesuai KTP',
                        icon: Icons.badge_outlined,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                      _buildTextField(
                        controller: _nikController,
                        label: 'NIK *',
                        hint: '16 digit NIK',
                        icon: Icons.subtitles_outlined,
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.length < 16
                            ? 'NIK minimal 16 digit'
                            : null,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildFieldRow([
                      _buildTextField(
                        controller: null,
                        label: 'Tanggal Lahir *',
                        hint: 'DD/MM/YYYY',
                        icon: Icons.calendar_month_outlined,
                        value: _tglLahir,
                        onTap: _pickTanggalLahir,
                        error: _showJadwalError && _tglLahir == null,
                      ),
                      _buildGenderSelector(),
                    ]),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _noHpController,
                      label: 'No. HP / WhatsApp *',
                      hint: '08xxxxxxxxxx',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'No. HP wajib diisi';
                        }
                        final v = val.trim();
                        if (!RegExp(r'^08\d{8,13}$').hasMatch(v)) {
                          return 'Format 08... 10-15 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _alamatController,
                      label: 'Alamat *',
                      hint: 'Alamat lengkap tempat tinggal',
                      icon: Icons.home_outlined,
                      maxLines: 3,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Alamat wajib diisi'
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Seksi 2: Riwayat Kesehatan Jiwa
                _buildSectionHeader(
                  title: 'Riwayat Kesehatan Jiwa',
                  subtitle: 'Informasi riwayat kesehatan jiwa peserta',
                  icon: Icons.psychology_outlined,
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _buildYaTidakRow(
                      question:
                          'Apakah Anda pernah konsultasi jiwa sebelumnya?',
                      value: _pernahKonsultasi,
                      showError:
                          _showRiwayatError && _pernahKonsultasi == null,
                      onChanged: (val) =>
                          setState(() => _pernahKonsultasi = val),
                    ),
                    const SizedBox(height: 16),
                    _buildYaTidakRow(
                      question:
                          'Apakah Anda pernah mendapatkan obat sebelumnya?',
                      value: _pernahDapatObat,
                      showError: _showRiwayatError && _pernahDapatObat == null,
                      onChanged: (val) =>
                          setState(() => _pernahDapatObat = val),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Seksi 3: Jadwal & Layanan
                _buildSectionHeader(
                  title: 'Jadwal & Layanan',
                  subtitle: 'Pilih jadwal kunjungan yang diinginkan',
                  icon: Icons.event_available_outlined,
                ),
                const SizedBox(height: 20),
                _buildFieldRow([
                  _buildTextField(
                    controller: null,
                    label: 'Tanggal Kunjungan *',
                    hint: 'DD/MM/YYYY',
                    icon: Icons.event_outlined,
                    value: _tglLahir,
                    onTap: _pickTanggalLahir,
                    error: _showJadwalError && _tglLahir == null,
                  ),
                  _buildTextField(
                    controller: null,
                    label: 'Jam Kunjungan *',
                    hint: 'HH:MM',
                    icon: Icons.access_time_rounded,
                    value: _jamKunjungan,
                    onTap: _pickJamKunjungan,
                    error: _showJadwalError && _jamKunjungan == null,
                  ),
                ]),

                const SizedBox(height: 28),

                // Action Bar (Wrap agar tombol turun ke baris berikutnya saat sempit)
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Reset Form',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : _handleSubmitAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        _isSubmitting
                            ? 'Menyimpan...'
                            : 'Simpan dan Lanjut Ujian',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.heroButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _isSubmitting ? 'Menyimpan...' : 'Simpan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menyusun field berdampingan di layar lebar, dan menumpuk vertikal
  /// saat layar compact agar tidak overflow.
  Widget _buildFieldRow(List<Widget> fields) {
    final isCompact = context.isCompact;

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            fields[i],
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: fields[i]),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.heroButton, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.sectionCardBg),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    VoidCallback? onTap,
    String? value,
    int maxLines = 1,
    bool error = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: Color(0xFF334155),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: onTap != null,
          onTap: onTap,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13.5, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: error ? Colors.redAccent : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.heroButton,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
        if (error)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Wajib diisi',
              style: TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kelamin *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: Color(0xFF334155),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSegmentedSelector<String>(
          options: const [
            SegmentedOption(value: 'Laki-laki', label: 'Laki-laki'),
            SegmentedOption(value: 'Perempuan', label: 'Perempuan'),
          ],
          selected: _jenisKelamin,
          onChanged: (v) => setState(() => _jenisKelamin = v),
        ),
      ],
    );
  }

  Widget _buildYaTidakRow({
    required String question,
    required bool? value,
    required bool showError,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          softWrap: true,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: Color(0xFF334155),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSegmentedSelector<bool>(
          options: const [
            SegmentedOption(value: true, label: 'Ya'),
            SegmentedOption(value: false, label: 'Tidak'),
          ],
          selected: value,
          error: showError,
          onChanged: onChanged,
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Wajib diisi',
              style: TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
          ),
      ],
    );
  }
}
