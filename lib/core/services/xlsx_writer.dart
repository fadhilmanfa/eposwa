import 'package:archive/archive.dart';

/// Satu sheet: nama sheet + baris data (baris pertama dianggap header).
class XlsxSheet {
  final String name;
  final List<List<Object?>> rows;

  const XlsxSheet(this.name, this.rows);
}

/// Writer .xlsx minimal (file xlsx = ZIP berisi XML).
/// Hanya mendukung penulisan: teks sebagai inline string, angka sebagai sel
/// numerik, dan baris pertama bergaya bold.
class XlsxWriter {
  static const _nsMain =
      'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
  static const _nsRel =
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships';

  static const _xmlHeader =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n';

  static List<int> build(List<XlsxSheet> sheets) {
    final archive = Archive();
    archive.add(
      ArchiveFile.string('[Content_Types].xml', _contentTypes(sheets.length)),
    );
    archive.add(ArchiveFile.string('_rels/.rels', _rootRels()));
    archive.add(ArchiveFile.string('xl/workbook.xml', _workbook(sheets)));
    archive.add(
      ArchiveFile.string(
        'xl/_rels/workbook.xml.rels',
        _workbookRels(sheets.length),
      ),
    );
    archive.add(ArchiveFile.string('xl/styles.xml', _styles()));
    for (var i = 0; i < sheets.length; i++) {
      archive.add(
        ArchiveFile.string(
          'xl/worksheets/sheet${i + 1}.xml',
          _worksheet(sheets[i]),
        ),
      );
    }
    return ZipEncoder().encode(archive);
  }

  static String _contentTypes(int sheetCount) {
    final buffer = StringBuffer(_xmlHeader)
      ..writeln(
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
      )
      ..writeln(
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
      )
      ..writeln('<Default Extension="xml" ContentType="application/xml"/>')
      ..writeln(
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
      )
      ..writeln(
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>',
      );
    for (var i = 1; i <= sheetCount; i++) {
      buffer.writeln(
        '<Override PartName="/xl/worksheets/sheet$i.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',
      );
    }
    buffer.writeln('</Types>');
    return buffer.toString();
  }

  static String _rootRels() {
    return '$_xmlHeader'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="$_nsRel/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>';
  }

  static String _workbook(List<XlsxSheet> sheets) {
    final buffer = StringBuffer(_xmlHeader)
      ..writeln('<workbook xmlns="$_nsMain" xmlns:r="$_nsRel">')
      ..writeln('<sheets>');
    for (var i = 0; i < sheets.length; i++) {
      buffer.writeln(
        '<sheet name="${_escapeXml(_sheetName(sheets[i].name))}" sheetId="${i + 1}" r:id="rId${i + 1}"/>',
      );
    }
    buffer
      ..writeln('</sheets>')
      ..writeln('</workbook>');
    return buffer.toString();
  }

  static String _workbookRels(int sheetCount) {
    final buffer = StringBuffer(_xmlHeader)
      ..writeln(
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
      );
    for (var i = 1; i <= sheetCount; i++) {
      buffer.writeln(
        '<Relationship Id="rId$i" Type="$_nsRel/worksheet" Target="worksheets/sheet$i.xml"/>',
      );
    }
    buffer
      ..writeln(
        '<Relationship Id="rId${sheetCount + 1}" Type="$_nsRel/styles" Target="styles.xml"/>',
      )
      ..writeln('</Relationships>');
    return buffer.toString();
  }

  static String _styles() {
    return '$_xmlHeader'
        '<styleSheet xmlns="$_nsMain">'
        '<fonts count="2">'
        '<font><sz val="11"/><name val="Calibri"/></font>'
        '<font><b/><sz val="11"/><name val="Calibri"/></font>'
        '</fonts>'
        '<fills count="2">'
        '<fill><patternFill patternType="none"/></fill>'
        '<fill><patternFill patternType="gray125"/></fill>'
        '</fills>'
        '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
        '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
        '<cellXfs count="2">'
        '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
        '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
        '</cellXfs>'
        '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
        '</styleSheet>';
  }

  static String _worksheet(XlsxSheet sheet) {
    final buffer = StringBuffer(_xmlHeader)
      ..writeln('<worksheet xmlns="$_nsMain" xmlns:r="$_nsRel">')
      ..writeln(
        '<sheetViews><sheetView workbookViewId="0">'
        '<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>'
        '</sheetView></sheetViews>',
      )
      ..write(_columns(sheet.rows))
      ..writeln('<sheetData>');

    for (var r = 0; r < sheet.rows.length; r++) {
      final isHeader = r == 0;
      buffer.write('<row r="${r + 1}">');
      final row = sheet.rows[r];
      for (var c = 0; c < row.length; c++) {
        buffer.write(_cell(c, r + 1, row[c], isHeader: isHeader));
      }
      buffer.writeln('</row>');
    }

    buffer
      ..writeln('</sheetData>')
      ..writeln('</worksheet>');
    return buffer.toString();
  }

  static String _columns(List<List<Object?>> rows) {
    if (rows.isEmpty) return '';
    final columnCount = rows.fold<int>(0, (max, row) => row.length > max ? row.length : max);
    if (columnCount == 0) return '';

    final buffer = StringBuffer('<cols>');
    for (var c = 0; c < columnCount; c++) {
      var longest = 0;
      for (final row in rows) {
        if (c >= row.length) continue;
        final length = row[c]?.toString().length ?? 0;
        if (length > longest) longest = length;
      }
      final width = (longest + 2).clamp(10, 45);
      buffer.write(
        '<col min="${c + 1}" max="${c + 1}" width="$width" customWidth="1"/>',
      );
    }
    buffer.write('</cols>');
    return buffer.toString();
  }

  static String _cell(int column, int row, Object? value, {required bool isHeader}) {
    if (value == null) return '';
    final ref = '${_columnName(column)}$row';
    final style = isHeader ? ' s="1"' : '';

    if (value is num) return '<c r="$ref"$style><v>$value</v></c>';

    final text = value.toString();
    if (text.isEmpty) return '';
    return '<c r="$ref"$style t="inlineStr"><is><t xml:space="preserve">'
        '${_escapeXml(text)}</t></is></c>';
  }

  static String _columnName(int index) {
    var remaining = index;
    final buffer = StringBuffer();
    while (remaining >= 0) {
      buffer.write(String.fromCharCode(65 + (remaining % 26)));
      remaining = (remaining ~/ 26) - 1;
    }
    return String.fromCharCodes(buffer.toString().codeUnits.reversed);
  }

  static String _sheetName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\[\]:*?/\\]'), ' ').trim();
    final safe = cleaned.isEmpty ? 'Sheet' : cleaned;
    return safe.length <= 31 ? safe : safe.substring(0, 31);
  }

  static String _escapeXml(String value) {
    final sanitized = value.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'),
      '',
    );
    return sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
