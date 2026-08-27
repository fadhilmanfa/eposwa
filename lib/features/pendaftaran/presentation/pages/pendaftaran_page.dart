import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

class PendaftaranPage extends StatefulWidget {
  final VoidCallback? onSuccessSubmit;

  const PendaftaranPage({
    super.key,
    this.onSuccessSubmit,
  });

  @override
  State<PendaftaranPage> createState() => _PendaftaranPageState();
}

class _PendaftaranPageState extends State<PendaftaranPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tglLahirController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _asalSekolahController = TextEditingController();

  String _jenisKelamin = 'Laki-laki';
  String _pilihanProgram = 'Regular Pagi';
  String _jalurPendaftaran = 'Prestasi Akademik';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _tempatLahirController.dispose();
    _tglLahirController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _asalSekolahController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua bidang isian yang wajib!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Text('Pendaftaran Berhasil'),
          ],
        ),
        content: Text(
          'Data pendaftaran calon peserta "${_namaController.text.trim()}" telah berhasil disimpan ke dalam sistem.',
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
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _nikController.clear();
    _tempatLahirController.clear();
    _tglLahirController.clear();
    _noHpController.clear();
    _emailController.clear();
    _asalSekolahController.clear();
    setState(() {
      _jenisKelamin = 'Laki-laki';
      _pilihanProgram = 'Regular Pagi';
      _jalurPendaftaran = 'Prestasi Akademik';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderSection(),

                const SizedBox(height: 24),

                // Form Section 1: Data Diri
                _buildSectionCard(
                  title: '1. Informasi Data Diri Peserta',
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _namaController,
                              label: 'Nama Lengkap Peserta *',
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
                              label: 'NIK / Nomor Identitas *',
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
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _tempatLahirController,
                              label: 'Tempat Lahir *',
                              hint: 'Kota kelahiran',
                              icon: Icons.location_on_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _tglLahirController,
                              label: 'Tanggal Lahir *',
                              hint: 'DD/MM/YYYY',
                              icon: Icons.calendar_month_outlined,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2005),
                                  firstDate: DateTime(1970),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  _tglLahirController.text =
                                      '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jenis Kelamin *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Laki-laki',
                                            style: TextStyle(fontSize: 13)),
                                        value: 'Laki-laki',
                                        groupValue: _jenisKelamin,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onChanged: (val) => setState(
                                            () => _jenisKelamin = val!),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Perempuan',
                                            style: TextStyle(fontSize: 13)),
                                        value: 'Perempuan',
                                        groupValue: _jenisKelamin,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onChanged: (val) => setState(
                                            () => _jenisKelamin = val!),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _noHpController,
                              label: 'No. WhatsApp / HP *',
                              hint: 'cth: 081234567890',
                              icon: Icons.phone_android_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'No. HP wajib diisi'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Alamat Email *',
                              hint: 'email@domain.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => val == null || !val.contains('@')
                                  ? 'Email tidak valid'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Section 2: Data Akademik & Program
                _buildSectionCard(
                  title: '2. Pilihan Program & Asal Sekolah',
                  icon: Icons.school_outlined,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _asalSekolahController,
                              label: 'Asal Sekolah / Instansi *',
                              hint: 'Nama SMA / SMK / Instansi asal',
                              icon: Icons.apartment_rounded,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Asal sekolah wajib diisi'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pilihan Program *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _pilihanProgram,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Regular Pagi',
                                        child: Text('Regular Pagi')),
                                    DropdownMenuItem(
                                        value: 'Regular Sore/Malam',
                                        child: Text('Regular Sore/Malam')),
                                    DropdownMenuItem(
                                        value: 'Eksekutif / Karyawan',
                                        child: Text('Eksekutif / Karyawan')),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _pilihanProgram = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jalur Pendaftaran *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _jalurPendaftaran,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Prestasi Akademik',
                                        child: Text('Prestasi Akademik')),
                                    DropdownMenuItem(
                                        value: 'Ujian Mandiri',
                                        child: Text('Ujian Mandiri')),
                                    DropdownMenuItem(
                                        value: 'Beasiswa Undangan',
                                        child: Text('Beasiswa Undangan')),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _jalurPendaftaran = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Section 3: Upload Dokumen UI
                _buildSectionCard(
                  title: '3. Upload Dokumen Pendukung',
                  icon: Icons.cloud_upload_outlined,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildUploadCard(
                          title: 'KTP / Kartu Pelajar',
                          subtitle: 'Format PNG, JPG, PDF (Max 2MB)',
                          icon: Icons.picture_in_picture_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUploadCard(
                          title: 'Ijazah / Rapor',
                          subtitle: 'Format PNG, JPG, PDF (Max 5MB)',
                          icon: Icons.description_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUploadCard(
                          title: 'Pasfoto 3x4 (Latar Merah)',
                          subtitle: 'Format JPG, PNG (Max 1MB)',
                          icon: Icons.account_box_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit & Reset Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reset Form'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                      label: Text(
                        _isSubmitting ? 'Menyimpan...' : 'Simpan Pendaftaran',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPastel),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formulir Pendaftaran Peserta Baru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Isi formulir pendaftaran di bawah ini dengan data yang benar dan sah.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: onTap != null,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sectionLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: const Text('Pilih File', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
