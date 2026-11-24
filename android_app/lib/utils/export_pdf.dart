
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> exportPdf(String text) async {
  if (text.trim().isEmpty) {
    throw Exception('Resume is empty. Nothing to export.');
  }

  final document = pw.Document();

  final lines = text
      .replaceAll('\r\n', '\n')
      .split('\n');

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),

      header: (context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text(
            'CAREERAI',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
              letterSpacing: 1.5,
            ),
          ),
        );
      },

      footer: (context) {
        return pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        );
      },

      build: (context) {
        return [
          pw.Text(
            'Resume',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.deepPurple,
            ),
          ),

          pw.SizedBox(height: 20),

          ...lines.map((line) {
            final value = line.trim();

            if (value.isEmpty) {
              return pw.SizedBox(height: 7);
            }

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Text(
                value,
                style: const pw.TextStyle(
                  fontSize: 10,
                  lineSpacing: 3,
                  color: PdfColors.black,
                ),
              ),
            );
          }),
        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async {
      return document.save();
    },
    name: 'CareerAI_Resume.pdf',
  );
}
