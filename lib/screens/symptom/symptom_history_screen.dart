import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myibd_app/models/symptom.dart';
import 'package:myibd_app/repositories/symptom_repository.dart';
import 'package:myibd_app/screens/symptom/symptom_form_screen.dart';

class SymptomHistoryScreen extends StatefulWidget {
  const SymptomHistoryScreen({super.key});

  @override
  State<SymptomHistoryScreen> createState() => _SymptomHistoryScreenState();
}

class _SymptomHistoryScreenState extends State<SymptomHistoryScreen> {
  final _symptomRepository = SymptomRepository();
  List<Symptom> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final entries = await _symptomRepository.getAll();
      setState(() {
        _entries = entries..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entries: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Symptom analytics coming soon')),
              );
            },
            tooltip: 'Symptom Analytics',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SymptomFormScreen()),
          );
          
          if (result == true) {
            _loadEntries();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Text('No symptoms recorded yet'),
                )
              : ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final symptoms = entry.symptoms;
                    final maxSeverity = symptoms.isEmpty 
                        ? 0 
                        : symptoms.values.reduce((a, b) => a > b ? a : b);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: entry.isFlare 
                              ? Colors.red 
                              : _getSeverityColor(maxSeverity),
                          child: entry.isFlare
                              ? const Icon(Icons.warning, color: Colors.white, size: 20)
                              : Text(
                                  maxSeverity.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        title: Row(
                          children: [
                            Text(DateFormat('MMM d, yyyy - h:mm a').format(entry.timestamp)),
                            if (entry.isFlare) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'FLARE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            ...symptoms.entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(e.key),
                                  ),
                                  ...List.generate(5, (i) => Icon(
                                    i < e.value ? Icons.circle : Icons.circle_outlined,
                                    size: 8,
                                    color: _getSeverityColor(e.value),
                                  )),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getSeverityLabel(e.value),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getSeverityColor(e.value),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Entry'),
                                content: const Text('Are you sure you want to delete this entry?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true && entry.id != null) {
                              await _symptomRepository.delete(entry.id!);
                              _loadEntries();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
  
  String _getSeverityLabel(int severity) {
    switch (severity) {
      case 1:
        return 'Mild';
      case 2:
        return 'Moderate';
      case 3:
        return 'Significant';
      case 4:
        return 'Severe';
      case 5:
        return 'Very Severe';
      default:
        return 'Unknown';
    }
  }
  
  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}