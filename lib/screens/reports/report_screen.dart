import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:myibd_app/services/report_generator.dart';
import 'package:myibd_app/repositories/bowel_repository.dart';
import 'package:myibd_app/repositories/fluid_repository.dart';
import 'package:myibd_app/repositories/food_repository.dart';
import 'package:myibd_app/repositories/medication_repository.dart';
import 'package:myibd_app/repositories/sleep_repository.dart';
import 'package:myibd_app/repositories/symptom_repository.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _nameController = TextEditingController();
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Load data from repositories
      final bowelRepository = BowelRepository();
      final fluidRepository = FluidRepository();
      final foodRepository = FoodRepository();
      final medicationRepository = MedicationRepository();
      final sleepRepository = SleepRepository();
      final symptomRepository = SymptomRepository();

      final bowelMovements = await bowelRepository.getForDateRange(
        _selectedDateRange.start,
        _selectedDateRange.end,
      );

      final allFluids = await fluidRepository.getAll();
      final fluidIntakes = allFluids.where((f) =>
        f.timestamp.isAfter(_selectedDateRange.start) &&
        f.timestamp.isBefore(_selectedDateRange.end.add(const Duration(days: 1)))
      ).toList();

      final allFoods = await foodRepository.getAll();
      final foodEntries = allFoods.where((f) =>
        f.timestamp.isAfter(_selectedDateRange.start) &&
        f.timestamp.isBefore(_selectedDateRange.end.add(const Duration(days: 1)))
      ).toList();

      final allMedications = await medicationRepository.getAll();
      final medications = allMedications.where((m) =>
        m.timestamp.isAfter(_selectedDateRange.start) &&
        m.timestamp.isBefore(_selectedDateRange.end.add(const Duration(days: 1)))
      ).toList();

      final allSleep = await sleepRepository.getAll();
      final sleepRecords = allSleep.where((s) =>
        s.endTime.isAfter(_selectedDateRange.start) &&
        s.endTime.isBefore(_selectedDateRange.end.add(const Duration(days: 1)))
      ).toList();

      final allSymptoms = await symptomRepository.getAll();
      final symptoms = allSymptoms.where((s) =>
        s.timestamp.isAfter(_selectedDateRange.start) &&
        s.timestamp.isBefore(_selectedDateRange.end.add(const Duration(days: 1)))
      ).toList();

      // Generate the report
      final file = await ReportGenerator.generateReport(
        patientName: _nameController.text,
        startDate: _selectedDateRange.start,
        endDate: _selectedDateRange.end,
        bowelMovements: bowelMovements,
        fluidIntakes: fluidIntakes,
        foodEntries: foodEntries,
        medications: medications,
        sleepRecords: sleepRecords,
        symptoms: symptoms,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report generated successfully')),
        );

        // Show dialog with options
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Report Generated'),
            content: const Text('Your IBD tracking report has been generated. What would you like to do?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Open the file
                  await OpenFilex.open(file.path);
                },
                child: const Text('Open'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // In a real app, implement sharing functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing functionality will be added soon')),
                  );
                },
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Generate PDF Report',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a comprehensive report of your IBD tracking data for your healthcare provider.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                hintText: 'Enter your name for the report',
              ),
            ),
            const SizedBox(height: 16),
            
            // Date range selector
            Card(
              child: ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Report Period'),
                subtitle: Text(
                  '${dateFormat.format(_selectedDateRange.start)} - '
                  '${dateFormat.format(_selectedDateRange.end)}',
                ),
                onTap: _selectDateRange,
              ),
            ),
            const SizedBox(height: 24),
            
            // Report contents
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Contents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContentItem(Icons.water_drop, 'Bowel Movements'),
                    _buildContentItem(Icons.local_drink, 'Fluid Intake'),
                    _buildContentItem(Icons.restaurant, 'Food Entries'),
                    _buildContentItem(Icons.medication, 'Medications'),
                    _buildContentItem(Icons.bedtime, 'Sleep Records'),
                    _buildContentItem(