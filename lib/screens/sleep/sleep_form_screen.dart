import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myibd_app/models/sleep.dart';
import 'package:myibd_app/repositories/sleep_repository.dart';

class SleepFormScreen extends StatefulWidget {
  const SleepFormScreen({super.key});

  @override
  State<SleepFormScreen> createState() => _SleepFormScreenState();
}

class _SleepFormScreenState extends State<SleepFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sleepRepository = SleepRepository();
  
  // Initialize with reasonable defaults
  DateTime _bedTime = DateTime.now().subtract(const Duration(hours: 8));
  DateTime _wakeTime = DateTime.now();
  int _awakeMinutes = 0;
  int _quality = 3;
  
  final TextEditingController _awakeMinutesController = TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController();
  
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    // Set default bedtime to 11 PM previous day
    final now = DateTime.now();
    _bedTime = DateTime(now.year, now.month, now.day - 1, 23, 0);
    // Set default wake time to 7 AM today
    _wakeTime = DateTime(now.year, now.month, now.day, 7, 0);
  }

  @override
  void dispose() {
    _awakeMinutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  int _calculateTotalMinutes() {
    return _wakeTime.difference(_bedTime).inMinutes;
  }
  
  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
  
  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      if (_wakeTime.isBefore(_bedTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wake time must be after bed time')),
        );
        return;
      }
      
      setState(() {
        _isSaving = true;
      });
      
      try {
        final totalMinutes = _calculateTotalMinutes();
        
        final sleep = Sleep(
          userId: 'user123', // In real app, get from auth
          startTime: _bedTime,
          endTime: _wakeTime,
          totalSleepMinutes: totalMinutes,
          awakeMinutes: _awakeMinutes,
          quality: _quality,
          notes: _notesController.text,
        );
        
        await _sleepRepository.save(sleep);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sleep record saved')),
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
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = _calculateTotalMinutes();
    final actualSleepMinutes = totalMinutes - _awakeMinutes;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Sleep'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bed Time
              Card(
                child: ListTile(
                  leading: const Icon(Icons.bedtime, color: Colors.indigo),
                  title: const Text('Bed Time'),
                  subtitle: Text(DateFormat('MMM d, yyyy - h:mm a').format(_bedTime)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _bedTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 7)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_bedTime),
                      );
                      if (time != null) {
                        setState(() {
                          _bedTime = DateTime(
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
              
              // Wake Time
              Card(
                child: ListTile(
                  leading: const Icon(Icons.wb_sunny, color: Colors.orange),
                  title: const Text('Wake Time'),
                  subtitle: Text(DateFormat('MMM d, yyyy - h:mm a').format(_wakeTime)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _wakeTime,
                      firstDate: _bedTime,
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_wakeTime),
                      );
                      if (time != null) {
                        setState(() {
                          _wakeTime = DateTime(
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
              
              // Sleep Duration Summary
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Time in Bed:'),
                          Text(
                            _formatDuration(totalMinutes),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Actual Sleep Time:'),
                          Text(
                            _formatDuration(actualSleepMinutes),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Awake Time
              TextFormField(
                controller: _awakeMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Time Awake (minutes)',
                  border: OutlineInputBorder(),
                  hintText: 'How many minutes were you awake?',
                  prefixIcon: Icon(Icons.timer_off),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter awake time';
                  }
                  final minutes = int.tryParse(value);
                  if (minutes == null || minutes < 0) {
                    return 'Please enter a valid number';
                  }
                  if (minutes > totalMinutes) {
                    return 'Awake time cannot be more than total time in bed';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _awakeMinutes = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Sleep Quality
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sleep Quality', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
                      Expanded(
                        child: Slider(
                          value: _quality.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _getQualityLabel(_quality),
                          onChanged: (value) {
                            setState(() {
                              _quality = value.round();
                            });
                          },
                        ),
                      ),
                      const Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                    ],
                  ),
                  Center(
                    child: Text(
                      _getQualityLabel(_quality),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getQualityColor(_quality),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Quick Tips
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Sleep Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Adults need 7-9 hours of sleep\n'
                        '• Consistent sleep schedule helps\n'
                        '• Track patterns to identify triggers',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Any observations about your sleep?',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Save button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.indigo.shade700,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Sleep Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getQualityLabel(int quality) {
    switch (quality) {
      case 1:
        return 'Very Poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unknown';
    }
  }
  
  Color _getQualityColor(int quality) {
    switch (quality) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}