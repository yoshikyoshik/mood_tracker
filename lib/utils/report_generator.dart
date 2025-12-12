import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';

class ReportGenerator {
  static Future<void> generateAndPrint(
    List<MoodEntry> entries, 
    String profileName, 
    String title
  ) async {
    final pdf = pw.Document();
    
    // Wir nutzen Standard-Fonts (Helvetica), die immer da sind.
    // Das verhindert Ladefehler im Web.
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Daten vorbereiten (letzte 30 Tage)
    final recentEntries = entries.where((e) => 
      e.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30)))
    ).toList();
    
    // Sortieren: Neueste zuerst
    recentEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Stats berechnen
    double avgMood = 0;
    double avgSleep = 0;
    int sleepCount = 0;
    
    if (recentEntries.isNotEmpty) {
      avgMood = recentEntries.fold(0.0, (sum, e) => sum + e.score) / recentEntries.length;
      final sleepEntries = recentEntries.where((e) => e.sleepRating != null).toList();
      if (sleepEntries.isNotEmpty) {
        sleepCount = sleepEntries.length;
        avgSleep = sleepEntries.fold(0.0, (sum, e) => sum + e.sleepRating!) / sleepCount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) => [
          // HEADER
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('LuvioSphere Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                pw.Text(DateFormat('dd.MM.yyyy').format(DateTime.now()), style: const pw.TextStyle(color: PdfColors.grey)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // INFO BLOCK
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Profil: $profileName", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text("Zeitraum: Letzte 30 Tage"),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBadge("Ø Stimmung", avgMood.toStringAsFixed(1), PdfColors.blue100),
                    _buildStatBadge("Ø Schlaf", sleepCount > 0 ? "${avgSleep.toStringAsFixed(1)} h" : "-", PdfColors.purple100),
                    _buildStatBadge("Einträge", "${recentEntries.length}", PdfColors.grey200),
                  ]
                )
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // TABELLE
          pw.Text("Einträge", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          
          // HIER WAR DER FEHLER: JETZT TableHelper
          pw.TableHelper.fromTextArray( 
            headers: ['Datum', 'Zeit', 'Mood', 'Schlaf', 'Tags', 'Notiz'],
            data: recentEntries.map((e) {
              return [
                DateFormat('dd.MM.').format(e.timestamp),
                DateFormat('HH:mm').format(e.timestamp),
                e.score.toStringAsFixed(1),
                e.sleepRating?.toStringAsFixed(1) ?? '-',
                e.tags.join(', '),
                e.note ?? '',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {2: pw.Alignment.center, 3: pw.Alignment.center},
          ),
          
          pw.Padding(padding: const pw.EdgeInsets.only(top: 20), child: pw.Text("Erstellt mit LuvioSphere", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
        ],
      ),
    );

    // Druck-Dialog öffnen
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'LuvioSphere_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildStatBadge(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: pw.BoxDecoration(color: color, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12))),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}