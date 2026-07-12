import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/utils/formatters.dart';
import '../models/mining_record.dart';

class PdfExportService {
  Future<void> exportRecords(List<MiningRecord> records) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Primerock Mining Companion — Production Records',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text('Generated ${Formatters.date(DateTime.now())}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [
              'Date',
              'Ore (t)',
              'Gold (g)',
              'Expenses',
              'Sales',
              'Notes',
            ],
            data: records
                .map(
                  (r) => [
                    Formatters.dateShort(r.date),
                    Formatters.number(r.oreProcessed),
                    Formatters.number(r.goldRecovered),
                    Formatters.number(r.expenses),
                    Formatters.number(r.sales),
                    r.notes,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }
}
