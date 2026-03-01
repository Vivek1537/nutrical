import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

class ReportService {
  static Future<Uint8List> generateWeeklyReport(UserProfile profile) async {
    final now = DateTime.now();
    final pdf = pw.Document();
    final days = <DateTime>[];
    final dayData = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      days.add(date);
      final meals = await StorageService.getMealsForDate(date);
      final water = await StorageService.getWaterForDate(date);
      dayData.add({
        'date': '${date.day}/${date.month}',
        'calories': meals.fold<double>(0, (s, m) => s + m.calories),
        'protein': meals.fold<double>(0, (s, m) => s + m.protein),
        'carbs': meals.fold<double>(0, (s, m) => s + m.carbs),
        'fat': meals.fold<double>(0, (s, m) => s + m.fat),
        'meals': meals.length,
        'water': water,
      });
    }

    final avgCal = dayData.fold<double>(0, (s, d) => s + (d['calories'] as double)) / 7;
    final avgPro = dayData.fold<double>(0, (s, d) => s + (d['protein'] as double)) / 7;
    final avgCarb = dayData.fold<double>(0, (s, d) => s + (d['carbs'] as double)) / 7;
    final avgFat = dayData.fold<double>(0, (s, d) => s + (d['fat'] as double)) / 7;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('NutriCal Weekly Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#00897B'))),
            pw.Text('${days.first.day}/${days.first.month} - ${days.last.day}/${days.last.month}/${days.last.year}', style: const pw.TextStyle(fontSize: 12)),
          ]),
          pw.Divider(),
          pw.SizedBox(height: 10),
        ]),
        build: (context) => [
          // User Info
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E0F2F1'), borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
              _pdfStat('Name', profile.name),
              _pdfStat('Goal', profile.goal),
              _pdfStat('Target', '${profile.dailyCalorieTarget.round()} kcal'),
              _pdfStat('Weight', '${profile.weightKg} kg'),
            ]),
          ),
          pw.SizedBox(height: 20),

          // Weekly Averages
          pw.Text('Weekly Averages', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
            _pdfStatBox('Calories', '${avgCal.round()}', 'kcal/day'),
            _pdfStatBox('Protein', '${avgPro.round()}', 'g/day'),
            _pdfStatBox('Carbs', '${avgCarb.round()}', 'g/day'),
            _pdfStatBox('Fat', '${avgFat.round()}', 'g/day'),
          ]),
          pw.SizedBox(height: 20),

          // Daily Breakdown Table
          pw.Text('Daily Breakdown', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#00897B')),
            
            cellAlignment: pw.Alignment.center,
            headers: ['Date', 'Calories', 'Protein', 'Carbs', 'Fat', 'Meals', 'Water (L)'],
            data: dayData.map((d) => [
              d['date'],
              '${(d['calories'] as double).round()}',
              '${(d['protein'] as double).round()}g',
              '${(d['carbs'] as double).round()}g',
              '${(d['fat'] as double).round()}g',
              '${d['meals']}',
              ((d['water'] as double) / 1000).toStringAsFixed(1),
            ]).toList(),
          ),
          pw.SizedBox(height: 20),

          // Goal Adherence
          pw.Text('Goal Adherence', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Average daily intake: ${avgCal.round()} kcal vs Target: ${profile.dailyCalorieTarget.round()} kcal'),
          pw.Text('Difference: ${(avgCal - profile.dailyCalorieTarget).round()} kcal/day'),
          pw.SizedBox(height: 8),
          pw.Text(avgCal <= profile.dailyCalorieTarget * 1.1
            ? 'Great job! You are on track with your calorie goals.'
            : 'You are exceeding your calorie target. Consider adjusting portions.',
            style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> printReport(UserProfile profile) async {
    final bytes = await generateWeeklyReport(profile);
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  static Future<void> shareReport(UserProfile profile) async {
    final bytes = await generateWeeklyReport(profile);
    await Printing.sharePdf(bytes: bytes, filename: 'nutrical_weekly_report.pdf');
  }

  static pw.Widget _pdfStat(String label, String value) => pw.Column(children: [
    pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
  ]);

  static pw.Widget _pdfStatBox(String label, String value, String unit) => pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: pw.BorderRadius.circular(6)),
    child: pw.Column(children: [
      pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#00897B'))),
      pw.Text(unit, style: const pw.TextStyle(fontSize: 9)),
      pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
    ]),
  );
}


