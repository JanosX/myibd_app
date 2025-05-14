import 'package:flutter/material.dart';
import 'package:myibd_app/models/bowel_movement.dart';
import 'package:myibd_app/repositories/bowel_repository.dart';

class BowelFormScreen extends StatefulWidget {
  const BowelFormScreen({super.key});

  @override
  State<BowelFormScreen> createState() => _BowelFormScreenState();
}

class _BowelFormScreenState extends State<BowelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bowelRepository = BowelRepository();
  
  DateTime _timestamp = DateTime.now();
  String _size = 'medium';
  String _color = 'brown';
  int _bristolScale = 4;
  int _urgency = 3;
  final Map<String, bool> _symptoms = {
    'blood': false,
    'mucus': false,
    'pain': false,
    'bloating': false,
    'gas': false,
  };
  final TextEditingController _notesController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        final bowelMovement = BowelMovement(
          userId: 'user123', // In real app, get from auth
          timestamp: _timestamp,
          size: _size,
          color: _color,
          bristolScale: _bristolScale,
          urgency: _urgency,
          symptoms: _symptoms,
          notes: _notesController.text,
        );
        
        await _bowelRepository.save(bowelMovement);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bowel movement recorded')),
          );
          Navigator.pop(context, true); // Return true to indicate data was saved
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Bowel Movement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              ElevatedButton(
                onPressed: () async {
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
                child: Text('Select Date & Time: ${_timestamp.toString().substring(0, 16)}'),
              ),
              const SizedBox(height: 16),
              
              // Size
              const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _size,
                items: const [
                  DropdownMenuItem(value: 'small', child: Text('Small')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'large', child: Text('Large')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _size = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Color
              const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _color,
                items: const [
                  DropdownMenuItem(value: 'brown', child: Text('Brown')),
                  DropdownMenuItem(value: 'yellow', child: Text('Yellow')),
                  DropdownMenuItem(value: 'green', child: Text('Green')),
                  DropdownMenuItem(value: 'black', child: Text('Black')),
                  DropdownMenuItem(value: 'red', child: Text('Red')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _color = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Bristol Scale
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bristol Scale', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _bristolScale.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: _bristolScale.toString(),
                    onChanged: (value) {
                      setState(() {
                        _bristolScale = value.round();
                      });
                    },
                  ),
                  Text('Selected: Type $_bristolScale'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Urgency
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Urgency', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _urgency.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _urgency.toString(),
                    onChanged: (value) {
                      setState(() {
                        _urgency = value.round();
                      });
                    },
                  ),
                  Text('Selected: $_urgency/5'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Symptoms
              const Text('Symptoms', style: TextStyle(fontWeight: FontWeight.bold)),
              ...Map.fromEntries(_symptoms.entries.toList()).entries.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1)),
                  value: entry.value,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        _symptoms[entry.key] = value;
                      });
                    }
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
              
              // Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Update the save button to call _saveEntry
              ElevatedButton(
                onPressed: _isSaving ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}