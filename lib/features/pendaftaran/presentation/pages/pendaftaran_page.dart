import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 26),
            SizedBox(width: 10),
            Text('Pendaftaran Berhasil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

    _resetForm();
    widget.onSubmitAndContinue?.call();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _nikController.clear();
    _alamatController.clear();
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
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seksi 1: Data Diri
                _buildSectionCard(
                  title: 'Form Pendaftaran Peserta Baru',
                  subtitle: 'Informasi identitas pribadi peserta',
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _namaController,
                              label: 'Nama Lengkap *',
                              hint: 'Masukkan nama lengkap sesuai KTP',
                              icon: Icons.badge_outlined,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Nama wajib diisi'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _nikController,
                              label: 'NIK *',
                              hint: '16 digit NIK',
                              icon: Icons.subtitles_outlined,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.length < 16
                                  ? 'NIK minimal 16 digit'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: null,
                              label: 'Tanggal Lahir *',
                              hint: 'DD/MM/YYYY',
                              icon: Icons.calendar_month_outlined,
                              value: _tglLahir,
                              onTap: _pickTanggalLahir,
                              error:
                                  _showJadwalError && _tglLahir == null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGenderSelector(),
                          ),
                        ],
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
                ),

                const SizedBox(height: 24),

                // Seksi 2: Riwayat Kesehatan Jiwa
                _buildSectionCard(
                  title: 'Riwayat Kesehatan Jiwa',
                  subtitle: 'Informasi riwayat kesehatan jiwa peserta',
                  icon: Icons.psychology_outlined,
                  child: Column(
                    children: [
                      _buildYaTidakRow(
                        question: 'Apakah Anda pernah konsultasi jiwa sebelumnya?',
                        value: _pernahKonsultasi,
                        showError: _showRiwayatError && _pernahKonsultasi == null,
                        onChanged: (val) => setState(() => _pernahKonsultasi = val),
                      ),
                      const SizedBox(height: 16),
                      _buildYaTidakRow(
                        question: 'Apakah Anda pernah mendapatkan obat sebelumnya?',
                        value: _pernahDapatObat,
                        showError: _showRiwayatError && _pernahDapatObat == null,
                        onChanged: (val) => setState(() => _pernahDapatObat = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Seksi 3: Jadwal & Layanan
                _buildSectionCard(
                  title: 'Jadwal & Layanan',
                  subtitle: 'Pilih jadwal kunjungan yang diinginkan',
                  icon: Icons.event_available_outlined,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: null,
                          label: 'Tanggal Kunjungan *',
                          hint: 'DD/MM/YYYY',
                          icon: Icons.event_outlined,
                          value: _tglLahir,
                          onTap: _pickTanggalLahir,
                          error:
                              _showJadwalError && _tglLahir == null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: null,
                          label: 'Jam Kunjungan *',
                          hint: 'HH:MM',
                          icon: Icons.access_time_rounded,
                          value: _jamKunjungan,
                          onTap: _pickJamKunjungan,
                          error:
                              _showJadwalError && _jamKunjungan == null,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reset Form', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmitAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
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
                        _isSubmitting ? 'Menyimpan...' : 'Simpan dan Lanjut Ujian',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.heroButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
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
                            fontWeight: FontWeight.w700, fontSize: 14),
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

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.heroButton, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          child,
        ],
      ),
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
              borderSide: const BorderSide(color: AppColors.heroButton, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        Container(
          height: 44,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _GenderChip(
                  label: 'Laki-laki',
                  isSelected: _jenisKelamin == 'Laki-laki',
                  onTap: () => setState(() => _jenisKelamin = 'Laki-laki'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _GenderChip(
                  label: 'Perempuan',
                  isSelected: _jenisKelamin == 'Perempuan',
                  onTap: () => setState(() => _jenisKelamin = 'Perempuan'),
                ),
              ),
            ],
          ),
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: Color(0xFF334155),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: showError ? Colors.redAccent : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _GenderChip(
                  label: 'Ya',
                  isSelected: value == true,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _GenderChip(
                  label: 'Tidak',
                  isSelected: value == false,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
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

class _GenderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.heroButton : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}