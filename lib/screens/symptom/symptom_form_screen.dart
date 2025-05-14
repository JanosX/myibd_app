import 'package:flutter/material.dart';
import 'package:myibd_app/models/symptom.dart';
import 'package:myibd_app/repositories/symptom_repository.dart';

class SymptomFormScreen extends StatefulWidget {
  const SymptomFormScreen({super.key});

  @override
  State<SymptomFormScreen> createState() => _SymptomFormScreenState();
}

class _SymptomFormScreenState extends State<SymptomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomRepository = SymptomRepository();
  
  DateTime _timestamp = DateTime.now();
  final Map<String, int> _selectedSymptoms = {};
  bool _isFlare = false;
  final TextEditingController _notesController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _saveEntry() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final symptom = Symptom(
        userId: 'user123', // In real app, get from auth
        timestamp: _timestamp,
        symptoms: _selectedSymptoms,
        isFlare: _isFlare,
        notes: _notesController.text,
      );
      
      await _symptomRepository.save(symptom);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Symptoms recorded')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Symptoms'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date & Time'),
                  subtitle: Text(_timestamp.toString().substring(0, 16)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _timestamp,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_timestamp),
                      );
                      if (time != null) {
                        setState(() {
                          _timestamp = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Flare status
              Card(
                color: _isFlare ? Colors.red.shade50 : null,
                child: SwitchListTile(
                  title: const Text('Is this a flare?'),
                  subtitle: Text(
                    _isFlare 
                        ? 'Currently experiencing a flare'
                        : 'Not currently in a flare',
                  ),
                  value: _isFlare,
                  onChanged: (value) {
                    setState(() {
                      _isFlare = value;
                    });
                  },
                  activeColor: Colors.red,
                  secondary: Icon(
                    _isFlare ? Icons.warning : Icons.check_circle,
                    color: _isFlare ? Colors.red : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Symptom categories
              ...SymptomCategories.categories.entries.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        category.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...category.value.map((symptom) {
                      final severity = _selectedSymptoms[symptom] ?? 0;
                      
                      return Card(
                        color: severity > 0 
                            ? _getSeverityColor(severity).withOpacity(0.1)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    symptom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (severity > 0)
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _selectedSymptoms.remove(symptom);
                                        });
                                      },
                                    ),
                                ],
                              ),
                              if (severity > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Severity: '),
                                    Expanded(
                                      child: Slider(
                                        value: severity.toDouble(),
                                        min: 1,
                                        max: 5,
                                        divisions: 4,
                                        label: _getSeverityLabel(severity),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedSymptoms[symptom] = value.round();
                                          });
                                        },
                                        activeColor: _getSeverityColor(severity),
                                      ),
                                    ),
                                    Text(
                                      _getSeverityLabel(severity),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _getSeverityColor(severity),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedSymptoms[symptom] = 3;
                                    });
                                  },
                                  child: const Text('+ Add this symptom'),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
              
              // Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Any additional observations?',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Save button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.amber.shade700,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Symptoms'),
              ),
            ],
          ),
        ),
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