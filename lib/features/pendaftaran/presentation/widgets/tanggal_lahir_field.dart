import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eposwa/features/pendaftaran/domain/tanggal_lahir.dart';

/// Input tanggal terpisah: tanggal & tahun ketik angka, bulan dropdown.
///
/// Dipakai untuk Tanggal Lahir. Label, validasi tahun, dan pesan error
/// bulan bisa disesuaikan lewat parameter.
class TanggalLahirField extends StatelessWidget {
  final TextEditingController tanggalController;
  final TextEditingController tahunController;
  final int? bulan;
  final ValueChanged<int?> onBulanChanged;
  final ValueChanged<String> onTanggalChanged;
  final ValueChanged<String> onTahunChanged;
  final bool showBulanError;
  final String label;
  final String bulanErrorText;
  final FormFieldValidator<String>? tanggalValidator;
  final FormFieldValidator<String>? tahunValidator;

  const TanggalLahirField({
    super.key,
    required this.tanggalController,
    required this.tahunController,
    required this.bulan,
    required this.onBulanChanged,
    required this.onTanggalChanged,
    required this.onTahunChanged,
    this.showBulanError = false,
    this.label = 'Tanggal Lahir *',
    this.bulanErrorText = 'Pilih bulan lahir',
    this.tanggalValidator,
    this.tahunValidator,
  });

  @override
  Widget build(BuildContext context) {
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: tanggalController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: onTanggalChanged,
                validator:
                    tanggalValidator ??
                    (v) => TanggalLahir.errorTanggal(
                      v,
                      bulan: bulan,
                      tahun: int.tryParse(tahunController.text.trim()),
                    ),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF1A1A1A),
                ),
                decoration: _decoration(hint: 'DD'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: _bulanDropdown(),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: tahunController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: onTahunChanged,
                validator: tahunValidator ?? TanggalLahir.errorTahun,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF1A1A1A),
                ),
                decoration: _decoration(hint: 'YYYY'),
              ),
            ),
          ],
        ),
        if (showBulanError && bulan == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              bulanErrorText,
              style: const TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
          ),
      ],
    );
  }

  Widget _bulanDropdown() {
    final hasError = showBulanError && bulan == null;
    return DropdownButtonFormField<int>(
      key: ValueKey('$label-$bulan'),
      initialValue: bulan,
      hint: const Text(
        'Bulan',
        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      ),
      decoration: _decoration(hint: 'Bulan', hasError: hasError),
      style: const TextStyle(fontSize: 13.5, color: Color(0xFF1A1A1A)),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
      menuMaxHeight: 320,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
        color: Color(0xFF64748B),
      ),
      isExpanded: true,
      items: List.generate(
        12,
        (i) => DropdownMenuItem(
          value: i + 1,
          child: Text(
            TanggalLahir.namaBulan[i],
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      onChanged: onBulanChanged,
      validator: (v) => v == null ? '' : null,
    );
  }

  InputDecoration _decoration({
    required String hint,
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFF0E7C7B),
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
      errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent),
    );
  }
}
