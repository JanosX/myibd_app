import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SymptomFrequencyChart extends StatelessWidget {
  final Map<String, int> symptomFrequencies;
  final String title;

  const SymptomFrequencyChart({
    super.key,
    required this.symptomFrequencies,
    this.title = 'Symptom Frequency',
  });

  @override
  Widget build(BuildContext context) {
    if (symptomFrequencies.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text('No symptom data available'),
            ],
          ),
        ),
      );
    }

    final sortedEntries = symptomFrequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topSymptoms = sortedEntries.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topSymptoms.first.value.toDouble() * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < topSymptoms.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  topSymptoms[index].key,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 80,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: topSymptoms.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: _getSymptomColor(entry.value.key),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSymptomColor(String symptom) {
    // Color code by symptom type
    if (['Abdominal Pain', 'Diarrhea', 'Constipation', 'Bloating', 'Cramping'].contains(symptom)) {
      return Colors.blue;
    } else if (['Joint Pain', 'Eye Inflammation', 'Skin Rashes', 'Mouth Ulcers'].contains(symptom)) {
      return Colors.orange;
    } else if (['Anxiety', 'Depression', 'Brain Fog', 'Irritability'].contains(symptom)) {
      return Colors.purple;
    } else {
      return Colors.green;
    }
  }
}