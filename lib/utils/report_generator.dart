import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../l10n/generated/app_localizations.dart';

class ReportGenerator {
  static Future<void> generateAndPrint(
    List<MoodEntry> entries, 
    String profileName, 
    AppLocalizations l10n, 
  ) async {
    final pdf = pw.Document();
    
    // Standard-Fonts
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Daten vorbereiten (letzte 30 Tage)
    final recentEntries = entries.where((e) => 
      e.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30)))
    ).toList();
    
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
                pw.Text(l10n.pdfTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
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
                pw.Text(l10n.pdfProfile(profileName), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(l10n.pdfPeriod),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBadge(l10n.pdfAvgMood, avgMood.toStringAsFixed(1), PdfColors.blue100),
                    _buildStatBadge(l10n.pdfAvgSleep, sleepCount > 0 ? "${avgSleep.toStringAsFixed(1)} h" : "-", PdfColors.purple100),
                    _buildStatBadge(l10n.pdfEntriesCount, "${recentEntries.length}", PdfColors.grey200),
                  ]
                )
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // TABELLE
          pw.Text("Einträge", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          
          // ignore: deprecated_member_use
          pw.TableHelper.fromTextArray( 
            headers: [
              l10n.pdfHeaderDate, 
              l10n.pdfHeaderTime, 
              l10n.pdfHeaderMood, 
              l10n.pdfHeaderSleep, 
              l10n.pdfHeaderTags, 
              l10n.pdfHeaderNote
            ],
            // FIX: Breitere Spalten für einzeilige Header
            columnWidths: {
              0: const pw.FixedColumnWidth(45), // Datum (war 40)
              1: const pw.FixedColumnWidth(40), // Zeit (war 30) -> Jetzt passt "Time"
              2: const pw.FixedColumnWidth(45), // Mood (war 30) -> Jetzt passt "Mood"
              3: const pw.FixedColumnWidth(45), // Schlaf (war 30) -> Jetzt passt "Sleep"
              4: const pw.FixedColumnWidth(110), // Tags (etwas breiter für lange Wörter)
              5: const pw.FlexColumnWidth(),    // Notiz (Rest)
            },
            data: recentEntries.map((e) {
              // FIX: Mapping-Logik für ALLE Sprachen
              final translatedTags = e.tags.map((tag) {
                 // Prüft auf EN oder DE Strings und gibt das aktuelle l10n Label zurück
                 if (['Familie', 'Family'].contains(tag)) return l10n.tagFamily;
                 if (['Beziehung', 'Relationship'].contains(tag)) return l10n.tagRelationship;
                 if (['Freunde', 'Friends'].contains(tag)) return l10n.tagFriends;
                 if (['Party'].contains(tag)) return l10n.tagParty;
                 
                 if (['Arbeit', 'Work'].contains(tag)) return l10n.tagWork;
                 if (['Schule', 'School'].contains(tag)) return l10n.tagSchool;
                 if (['Uni', 'University'].contains(tag)) return l10n.tagUni;
                 if (['Hausaufgaben', 'Homework'].contains(tag)) return l10n.tagHomework;
                 if (['Haushalt', 'Household'].contains(tag)) return l10n.tagHousehold;

                 if (['Schlaf', 'Sleep'].contains(tag)) return l10n.tagSleep;
                 if (['Sport'].contains(tag)) return l10n.tagSport;
                 if (['Essen', 'Food'].contains(tag)) return l10n.tagFood;
                 if (['Gesundheit', 'Health'].contains(tag)) return l10n.tagHealth;
                 if (['Meditation'].contains(tag)) return l10n.tagMeditation;
                 
                 if (['Hobby'].contains(tag)) return l10n.tagHobby;
                 if (['Reisen', 'Travel'].contains(tag)) return l10n.tagTravel;
                 if (['Wetter', 'Weather'].contains(tag)) return l10n.tagWeather;
                 if (['Gaming'].contains(tag)) return l10n.tagGaming;
                 if (['Lesen', 'Reading'].contains(tag)) return l10n.tagReading;
                 if (['Musik', 'Music'].contains(tag)) return l10n.tagMusic;

                 // Zyklus
                 if (['PMS'].contains(tag)) return l10n.tagPMS;
                 if (['Periode (Leicht)', 'Period (Light)'].contains(tag)) return l10n.tagPeriodLight;
                 if (['Periode (Mittel)', 'Period (Medium)'].contains(tag)) return l10n.tagPeriodMedium;
                 if (['Periode (Stark)', 'Period (Heavy)'].contains(tag)) return l10n.tagPeriodHeavy;
                 if (['Schmierblutung', 'Spotting'].contains(tag)) return l10n.tagSpotting;
                 if (['Regelschmerzen', 'Cramps'].contains(tag)) return l10n.tagCramps;
                 if (['Eisprung', 'Ovulation'].contains(tag)) return l10n.tagOvulation;

                 return tag; // Fallback für Custom Tags (bleiben wie sie sind)
              }).join(', ');

              return [
                DateFormat('dd.MM.').format(e.timestamp),
                DateFormat('HH:mm').format(e.timestamp),
                e.score.toStringAsFixed(1),
                e.sleepRating?.toStringAsFixed(1) ?? '-',
                translatedTags, 
                e.note ?? '',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10), 
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center, // Datum zentriert
              1: pw.Alignment.center, // Zeit zentriert
              2: pw.Alignment.center, // Mood zentriert
              3: pw.Alignment.center  // Schlaf zentriert
            },
          ),
          
          pw.Padding(padding: const pw.EdgeInsets.only(top: 20), child: pw.Text(l10n.pdfFooter, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
        ],
      ),
    );

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