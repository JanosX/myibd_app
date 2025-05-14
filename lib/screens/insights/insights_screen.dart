import 'package:flutter/material.dart';
import 'package:myibd_app/models/bowel_movement.dart';
import 'package:myibd_app/models/fluid_intake.dart';
import 'package:myibd_app/models/symptom.dart';
import 'package:myibd_app/repositories/bowel_repository.dart';
import 'package:myibd_app/repositories/fluid_repository.dart';
import 'package:myibd_app/repositories/symptom_repository.dart';
import 'package:myibd_app/widgets/charts/trend_chart.dart';
import 'package:myibd_app/widgets/charts/symptom_frequency_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _bowelRepository = BowelRepository();
  final _fluidRepository = FluidRepository();
  final _symptomRepository = SymptomRepository();
  
  bool _isLoading = true;
  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();
  
  // Chart data
  List<TrendPoint> _bristolScaleTrend = [];
  List<TrendPoint> _fluidIntakeTrend = [];
  List<TrendPoint> _bowelFrequencyTrend = [];
  Map<String, int> _symptomFrequencies = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load bowel movement data
      final bowelMovements = await _bowelRepository.getForDateRange(
        _selectedStartDate, 
        _selectedEndDate
      );
      
      // Load fluid intake data
      final fluidIntakes = await _fluidRepository.getAll();
      final filteredFluids = fluidIntakes.where((f) => 
        f.timestamp.isAfter(_selectedStartDate) && 
        f.timestamp.isBefore(_selectedEndDate.add(const Duration(days: 1)))
      ).toList();
      
      // Load symptom data
      final symptoms = await _symptomRepository.getAll();
      final filteredSymptoms = symptoms.where((s) => 
        s.timestamp.isAfter(_selectedStartDate) && 
        s.timestamp.isBefore(_selectedEndDate.add(const Duration(days: 1)))
      ).toList();

      _processData(bowelMovements, filteredFluids, filteredSymptoms);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _processData(
    List<BowelMovement> bowelMovements,
    List<FluidIntake> fluidIntakes,
    List<Symptom> symptoms,
  ) {
    // Process Bristol Scale trend
    final Map<DateTime, List<int>> bristolByDay = {};
    final Map<DateTime, int> bowelCountByDay = {};
    
    for (final movement in bowelMovements) {
      final date = DateTime(
        movement.timestamp.year,
        movement.timestamp.month,
        movement.timestamp.day,
      );
      
      bristolByDay.putIfAbsent(date, () => []).add(movement.bristolScale);
      bowelCountByDay.update(date, (count) => count + 1, ifAbsent: () => 1);
    }
    
    _bristolScaleTrend = bristolByDay.entries.map((entry) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return TrendPoint(date: entry.key, value: avg);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
    
    _bowelFrequencyTrend = bowelCountByDay.entries.map((entry) {
      return TrendPoint(date: entry.key, value: entry.value.toDouble());
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
    
    // Process fluid intake trend
    final Map<DateTime, double> fluidByDay = {};
    
    for (final intake in fluidIntakes) {
      final date = DateTime(
        intake.timestamp.year,
        intake.timestamp.month,
        intake.timestamp.day,
      );
      
      // Convert to ml for consistency
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
      
      fluidByDay.update(date, (total) => total + volumeInMl, ifAbsent: () => volumeInMl);
    }
    
    _fluidIntakeTrend = fluidByDay.entries.map((entry) {
      return TrendPoint(date: entry.key, value: entry.value / 1000); // Convert to liters
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
    
    // Process symptom frequencies
    _symptomFrequencies.clear();
    for (final symptom in symptoms) {
      for (final entry in symptom.symptoms.entries) {
        _symptomFrequencies.update(entry.key, (count) => count + 1, ifAbsent: () => 1);
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );
    
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trends'),
            Tab(text: 'Patterns'),
            Tab(text: 'AI Analysis'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTrendsTab(),
                _buildPatternsTab(),
                _buildAIAnalysisTab(),
              ],
            ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TrendChart(
            title: 'Bristol Scale Trend',
            data: _bristolScaleTrend,
            lineColor: Colors.blue,
            yAxisLabel: 'Bristol Scale',
            minY: 1,
            maxY: 7,
          ),
          const SizedBox(height: 16),
          TrendChart(
            title: 'Daily Bowel Movements',
            data: _bowelFrequencyTrend,
            lineColor: Colors.green,
            yAxisLabel: 'Count',
            minY: 0,
          ),
          const SizedBox(height: 16),
          TrendChart(
            title: 'Fluid Intake Trend',
            data: _fluidIntakeTrend,
            lineColor: Colors.cyan,
            yAxisLabel: 'Liters',
            minY: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SymptomFrequencyChart(
            symptomFrequencies: _symptomFrequencies,
            title: 'Most Common Symptoms',
          ),
          const SizedBox(height: 16),
          // Add more pattern analysis here
        ],
      ),
    );
  }

  Widget _buildAIAnalysisTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology,
              size: 80,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Deep Dive Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Analyze your tracking data to identify patterns and potential triggers',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('AI analysis will be available in a future update'),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate AI Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}