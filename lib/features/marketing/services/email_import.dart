// ============================================================
// EMAIL IMPORT  (Excel / CSV file se email nikalo)
//
// Web dashboard jaisa:
//   1. pehli line me "email" jaisa column ho -> sirf wahi column
//   2. warna poori sheet me jo bhi sahi email mile
// Dobara aaye email ek hi baar, sab chhote akshar me.
//
// .xlsx = zip ke andar XML. Use `archive` se kholte hain (alag Excel
// package app ke `image` package se takrata tha).
// .xls (purana Excel) nahi chalta -> .xlsx ya .csv me save karke do.
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

class EmailImport {
  EmailImport._();

  static final RegExp emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    caseSensitive: false,
  );

  static const Set<String> _emailHeaders = {
    'email',
    'emailaddress',
    'emailid',
    'emailids',
    'mail',
    'mailid',
    'mailaddress',
    'recipient',
    'recipientemail',
    'recipientemailaddress',
    'e-mail',
    'e-mailaddress',
  };

  static bool isEmail(String value) => emailPattern.hasMatch(value.trim());

  /// File padh kar saare email (khali list = kuch nahi mila)
  static Future<List<String>> fromFile(String path) async {
    final lower = path.toLowerCase();
    final bytes = await File(path).readAsBytes();

    if (lower.endsWith('.xls')) {
      throw const FormatException(
        'Old .xls files are not supported. Please save it as .xlsx or .csv.',
      );
    }

    final rows = lower.endsWith('.xlsx')
        ? _xlsxSheets(bytes).expand((sheet) => [sheet]).toList()
        : [_csvRows(utf8.decode(bytes, allowMalformed: true))];

    final found = <String>{};
    for (final sheet in rows) {
      found.addAll(_emailsFromRows(sheet));
    }
    return found.toList();
  }

  // ============================================================
  // ROWS -> EMAILS
  // ============================================================

  static Iterable<String> _emailsFromRows(List<List<String>> rows) sync* {
    if (rows.isEmpty) return;

    String clean(String v) => v.trim().toLowerCase();
    String header(String v) => clean(v).replaceAll(RegExp(r'[\s_-]+'), '');

    final emailColumns = [
      for (var i = 0; i < rows.first.length; i++)
        if (_emailHeaders.contains(header(rows.first[i]))) i,
    ];

    if (emailColumns.isNotEmpty) {
      for (final row in rows.skip(1)) {
        for (final i in emailColumns) {
          if (i < row.length && isEmail(row[i])) yield clean(row[i]);
        }
      }
      return;
    }

    for (final row in rows) {
      for (final cell in row) {
        if (isEmail(cell)) yield clean(cell);
      }
    }
  }

  // ============================================================
  // CSV  (quotes ke andar comma bhi chalta hai)
  // ============================================================

  static List<List<String>> _csvRows(String text) {
    final rows = <List<String>>[];
    final row = <String>[];
    final cell = StringBuffer();
    var quoted = false;

    void endCell() {
      row.add(cell.toString());
      cell.clear();
    }

    void endRow() {
      endCell();
      if (row.any((c) => c.trim().isNotEmpty)) rows.add(List.of(row));
      row.clear();
    }

    for (var i = 0; i < text.length; i++) {
      final ch = text[i];

      if (quoted) {
        if (ch == '"' && i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else if (ch == '"') {
          quoted = false;
        } else {
          cell.write(ch);
        }
      } else if (ch == '"') {
        quoted = true;
      } else if (ch == ',' || ch == ';' || ch == '\t') {
        endCell();
      } else if (ch == '\n') {
        endRow();
      } else if (ch != '\r') {
        cell.write(ch);
      }
    }
    endRow();

    return rows;
  }

  // ============================================================
  // XLSX  (har sheet ki rows)
  // ============================================================

  static List<List<List<String>>> _xlsxSheets(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);

    String read(String name) {
      final file = archive.files.where((f) => f.isFile && f.name == name);
      return file.isEmpty
          ? ''
          : utf8.decode(file.first.content, allowMalformed: true);
    }

    // Excel saare text ek jagah (sharedStrings) rakhta hai, cell me sirf number
    final shared = <String>[
      for (final si in RegExp(
        r'<si>(.*?)</si>',
        dotAll: true,
      ).allMatches(read('xl/sharedStrings.xml')))
        _xmlText(si[1]!),
    ];

    final sheets = archive.files
        .where(
          (f) =>
              f.isFile &&
              f.name.startsWith('xl/worksheets/') &&
              f.name.endsWith('.xml'),
        )
        .map((f) => f.name)
        .toList();

    return [for (final name in sheets) _sheetRows(read(name), shared)];
  }

  static List<List<String>> _sheetRows(String xml, List<String> shared) {
    final rows = <List<String>>[];

    for (final rowMatch in RegExp(
      r'<row[^>]*>(.*?)</row>',
      dotAll: true,
    ).allMatches(xml)) {
      final cells = <int, String>{};

      for (final c in RegExp(
        r'<c([^>]*?)(?:/>|>(.*?)</c>)',
        dotAll: true,
      ).allMatches(rowMatch[1]!)) {
        final attrs = c[1] ?? '';
        final inner = c[2] ?? '';
        final ref = RegExp(r'r="([A-Z]+)\d+"').firstMatch(attrs)?[1] ?? '';
        final type = RegExp(r't="(\w+)"').firstMatch(attrs)?[1] ?? '';

        String value;
        if (type == 's') {
          final index = int.tryParse(
            RegExp(r'<v>(.*?)</v>').firstMatch(inner)?[1] ?? '',
          );
          value = index != null && index < shared.length ? shared[index] : '';
        } else if (type == 'inlineStr') {
          value = _xmlText(inner);
        } else {
          value = _unescape(
            RegExp(r'<v>(.*?)</v>').firstMatch(inner)?[1] ?? '',
          );
        }

        cells[ref.isEmpty ? cells.length : _column(ref)] = value;
      }

      if (cells.isEmpty) continue;
      final width = cells.keys.reduce((a, b) => a > b ? a : b) + 1;
      rows.add([for (var i = 0; i < width; i++) cells[i] ?? '']);
    }

    return rows;
  }

  /// "A" -> 0, "B" -> 1, "AA" -> 26
  static int _column(String letters) =>
      letters.codeUnits.fold(0, (sum, c) => sum * 26 + (c - 64)) - 1;

  /// `<t>...</t>` ke andar ka saara text
  static String _xmlText(String xml) => _unescape(
    RegExp(
      r'<t[^>]*>(.*?)</t>',
      dotAll: true,
    ).allMatches(xml).map((m) => m[1]!).join(),
  );

  static String _unescape(String s) => s
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');
}
