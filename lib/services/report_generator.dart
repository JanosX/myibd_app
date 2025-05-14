import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:myibd_app/models/bowel_movement.dart';
import 'package:myibd_app/models/fluid_intake.dart';
import 'package:myibd_app/models/food_entry.dart';
import 'package:myibd_app/models/medication.dart';
import 'package:myibd_app/models/sleep.dart';
import 'package:myibd_app/models/symptom.dart';
import 'package:intl/intl.dart';

class ReportGenerator {
  static Future<File> generateReport({
    required String patientName,
    required DateTime startDate,
    required DateTime endDate,
    required List<BowelMovement> bowelMovements,
    required List<FluidIntake> fluidIntakes,
    required List<FoodEntry> foodEntries,
    required List<Medication> medications,
    required List<Sleep> sleepRecords,
    required List<Symptom> symptoms,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    // Create PDF pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 2)),
              ),
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'IBD Tracking Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Patient: $patientName'),
                  pw.Text(
                    'Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  ),
                  pw.Text(
                    'Generated: ${dateFormat.format(DateTime.now())}',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Summary Section
            _buildSummarySection(
              bowelMovements,
              fluidIntakes,
              foodEntries,
              medications,
              sleepRecords,
              symptoms,
            ),
            
            // Bowel Movements Section
            if (bowelMovements.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildBowelMovementSection(bowelMovements, dateFormat, timeFormat),
            ],
            
            // Symptoms Section
            if (symptoms.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildSymptomSection(symptoms, dateFormat, timeFormat),
            ],
            
            // Medications Section
            if (medications.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildMedicationSection(medications, dateFormat, timeFormat),
            ],
            
            // Sleep Section
            if (sleepRecords.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildSleepSection(sleepRecords, dateFormat),
            ],
            
            // Fluid Intake Section
            if (fluidIntakes.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildFluidSection(fluidIntakes, dateFormat),
            ],
            
            // Food Section
            if (foodEntries.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildFoodSection(foodEntries, dateFormat, timeFormat),
            ],
          ];
        },
      ),
    );

    // Save the PDF file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/myibd_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  static pw.Widget _buildSummarySection(
    List<BowelMovement> bowelMovements,
    List<FluidIntake> fluidIntakes,
    List<FoodEntry> foodEntries,
    List<Medication> medications,
    List<Sleep> sleepRecords,
    List<Symptom> symptoms,
  ) {
    // Calculate averages and totals
    final avgBristol = bowelMovements.isEmpty ? 0.0 
        : bowelMovements.map((e) => e.bristolScale).reduce((a, b) => a + b) / bowelMovements.length;
    
    final totalFluid = fluidIntakes.fold<double>(0, (sum, intake) {
      double volumeInMl = intake.volume;
      switch (intake.volumeUnit) {
        case 'L':
          volumeInMl = intake.volume * 1000;
          break;
        case 'cups':
          volumeInMl = intake.volume * 236.588;
          break;
        case 'oz':
          volumeInMl = intake.volume * 29.5735;
          break;
      }
      return sum + volumeInMl;
    });
    
    final avgSleep = sleepRecords.isEmpty ? 0.0
        : sleepRecords.map((e) => e.actualSleepMinutes).reduce((a, b) => a + b) / sleepRecords.length / 60;
    
    final flareCount = symptoms.where((s) => s.isFlare).length;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Summary',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                _buildTableCell('Metric', isHeader: true),
                _buildTableCell('Value', isHeader: true),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Total Bowel Movements'),
                _buildTableCell('${bowelMovements.length}'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Average Bristol Scale'),
                _buildTableCell('${avgBristol.toStringAsFixed(1)}'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Total Fluid Intake'),
                _buildTableCell('${(totalFluid / 1000).toStringAsFixed(1)}L'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Average Sleep'),
                _buildTableCell('${avgSleep.toStringAsFixed(1)}h'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Flare Days'),
                _buildTableCell('$flareCount'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Medications Taken'),
                _buildTableCell('${medications.length}'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBowelMovementSection(
    List<BowelMovement> movements,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Bowel Movements',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              children: [
                _buildTableCell('Date/Time', isHeader: true),
                _buildTableCell('Bristol', isHeader: true),
                _buildTableCell('Size', isHeader: true),
                _buildTableCell('Color', isHeader: true),
                _buildTableCell('Urgency', isHeader: true),
                _buildTableCell('Symptoms', isHeader: true),
              ],
            ),
            ...movements.map((movement) {
              final symptomsList = movement.symptoms.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .join(', ');
              
              return pw.TableRow(
                children: [
                  _buildTableCell(
                    '${dateFormat.format(movement.timestamp)} ${timeFormat.format(movement.timestamp)}',
                  ),
                  _buildTableCell('${movement.bristolScale}'),
                  _buildTableCell(movement.size),
                  _buildTableCell(movement.color),
                  _buildTableCell('${movement.urgency}/5'),
                  _buildTableCell(symptomsList.isEmpty ? 'None' : symptomsList),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSymptomSection(
    List<Symptom> symptoms,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Symptoms',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        ...symptoms.map((symptom) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              color: symptom.isFlare ? PdfColors.red50 : null,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${dateFormat.format(symptom.timestamp)} ${timeFormat.format(symptom.timestamp)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    if (symptom.isFlare)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                        ),
                        child: pw.Text(
                          'FLARE',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                pw.SizedBox(height: 5),
                ...symptom.symptoms.entries.map((entry) {
                  return pw.Text('• ${entry.key}: ${_getSeverityLabel(entry.value)}');
                }),
                if (symptom.notes.isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text('Notes: ${symptom.notes}'),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildMedicationSection(
    List<Medication> medications,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Medications',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              children: [
                _buildTableCell('Date/Time', isHeader: true),
                _buildTableCell('Medication', isHeader: true),
                _buildTableCell('Dosage', isHeader: true),
                _buildTableCell('Route', isHeader: true),
                _buildTableCell('Type', isHeader: true),
              ],
            ),
            ...medications.map((med) {
              return pw.TableRow(
                children: [
                  _buildTableCell(
                    '${dateFormat.format(med.timestamp)} ${timeFormat.format(med.timestamp)}',
                  ),
                  _buildTableCell(med.medicationName),
                  _buildTableCell(med.dosage),
                  _buildTableCell(_getRouteString(med.route)),
                  _buildTableCell(_getTypeString(med.type)),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSleepSection(
    List<Sleep> sleepRecords,
    DateFormat dateFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Sleep Records',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Bed Time', isHeader: true),
                _buildTableCell('Wake Time', isHeader: true),
                _buildTableCell('Total Sleep', isHeader: true),
                _buildTableCell('Awake Time', isHeader: true),
                _buildTableCell('Quality', isHeader: true),
              ],
            ),
            ...sleepRecords.map((sleep) {
              return pw.TableRow(
                children: [
                  _buildTableCell(dateFormat.format(sleep.startTime)),
                  _buildTableCell(DateFormat('h:mm a').format(sleep.startTime)),
                  _buildTableCell(DateFormat('h:mm a').format(sleep.endTime)),
                  _buildTableCell(sleep.formattedActualSleep),
                  _buildTableCell('${sleep.awakeMinutes}m'),
                  _buildTableCell('${sleep.quality}/5'),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFluidSection(
    List<FluidIntake> fluidIntakes,
    DateFormat dateFormat,
  ) {
    // Group fluid intakes by day
    final Map<DateTime, double> dailyTotals = {};
    
    for (final intake in fluidIntakes) {
      final date = DateTime(
        intake.timestamp.year,
        intake.timestamp.month,
        intake.timestamp.day,
      );
      
      double volumeInMl = intake.volume;
      switch (intake.volumeUnit) {
        case 'L':
          volumeInMl = intake.volume * 1000;
          break;
        case 'cups':
          volumeInMl = intake.volume * 236.588;
          break;
        case 'oz':
          volumeInMl = intake.volume * 29.5735;
          break;
      }
      
      dailyTotals.update(date, (total) => total + volumeInMl, ifAbsent: () => volumeInMl);
    }
    
    final sortedDates = dailyTotals.keys.toList()..sort();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Daily Fluid Intake',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Total Fluid Intake', isHeader: true),
              ],
            ),
            ...sortedDates.map((date) {
              final totalMl = dailyTotals[date]!;
              return pw.TableRow(
                children: [
                  _buildTableCell(dateFormat.format(date)),
                  _buildTableCell('${(totalMl / 1000).toStringAsFixed(2)}L (${totalMl.toInt()}ml)'),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFoodSection(
    List<FoodEntry> foodEntries,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Food Intake',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(3),
          },
          children: [
            pw.TableRow(
              children: [
                _buildTableCell('Date/Time', isHeader: true),
                _buildTableCell('Meal', isHeader: true),
                _buildTableCell('Category', isHeader: true),
                _buildTableCell('Amount', isHeader: true),
                _buildTableCell('Ingredients', isHeader: true),
              ],
            ),
            ...foodEntries.map((food) {
              return pw.TableRow(
                children: [
                  _buildTableCell(
                    '${dateFormat.format(food.timestamp)} ${timeFormat.format(food.timestamp)}',
                  ),
                  _buildTableCell(food.mealName),
                  _buildTableCell(food.category),
                  _buildTableCell(food.amount),
                  _buildTableCell(food.ingredients.join(', ')),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      color: isHeader ? PdfColors.grey300 : null,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          fontSize: isHeader ? 10 : 9,
        ),
      ),
    );
  }

  static