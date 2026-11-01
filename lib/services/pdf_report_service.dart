import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReportService {
  Future<void> previewReport({
    required List<DateTime> periodStarts,
    required Map<String, Map<String, dynamic>> dailyLogs,
    required String language,
  }) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');
    doc.addPage(pw.MultiPage(
      build: (context) => [
        pw.Text('LunaCare - Cycle & Wellness Report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
        pw.SizedBox(height: 16),
        pw.Text('Period start dates', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        if (periodStarts.isEmpty) pw.Text('No period dates recorded.')
        else ...periodStarts.map((d) => pw.Text(dateFormat.format(d))),
        pw.SizedBox(height: 16),
        pw.Text('Daily notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        if (dailyLogs.isEmpty) pw.Text('No daily logs recorded.')
        else ...dailyLogs.entries.map((e) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text('${e.key}: ${e.value}'),
        )),
        pw.SizedBox(height: 18),
        pw.Text('This report is a personal record, not a diagnosis or medical advice.',
            style: const pw.TextStyle(fontSize: 9)),
      ],
    ));
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  Future<Uint8List> buildBytes({
    required List<DateTime> periodStarts,
    required Map<String, Map<String, dynamic>> dailyLogs,
  }) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('LunaCare report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        ...periodStarts.map((d) => pw.Text(DateFormat('yyyy-MM-dd').format(d))),
        ...dailyLogs.entries.map((e) => pw.Text('${e.key}: ${e.value}')),
      ],
    )));
    return doc.save();
  }
}
