import 'package:flutter/material.dart';
import 'package:myibd_app/models/fluid_intake.dart';
import 'package:myibd_app/repositories/fluid_repository.dart';

class FluidFormScreen extends StatefulWidget {
  const FluidFormScreen({super.key});

  @override
  State<FluidFormScreen> createState() => _FluidFormScreenState();
}

class _FluidFormScreenState extends State<FluidFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fluidRepository = FluidRepository();
  
  DateTime _timestamp = DateTime.now();
  double _volume = 250.0;
  String _volumeUnit = 'ml';
  String _fluidType = 'water';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  
  final List<String> _fluidTypes = [
    'water', 
    'coffee', 
    'tea', 
    'juice',
    'soda',
    'milk',
    'beer',
    'wine',
    'sports drink',
    'other',
  ];
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _volumeController.text = _volume.toString();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _volumeController.dispose();
    super.dispose();
  }
  
  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        final fluidIntake = FluidIntake(
          userId: 'user123', // In real app, get from auth
          timestamp: _timestamp,
          volume: double.parse(_volumeController.text),
          volumeUnit: _volumeUnit,
          fluidType: _fluidType,
          notes: _notesController.text,
        );
        
        await _fluidRepository.save(fluidIntake);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fluid intake recorded')),
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
        title: const Text('Record Fluid Intake'),
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
              
              // Volume with unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Volume input
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _volumeController,
                      decoration: const InputDecoration(
                        labelText: 'Volume',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter volume';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Unit selector
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      value: _volumeUnit,
                      items: const [
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'L', child: Text('L')),
                        DropdownMenuItem(value: 'cups', child: Text('cups')),
                        DropdownMenuItem(value: 'oz', child: Text('oz')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _volumeUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quick volume buttons
              const Text('Quick Add:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getQuickVolumeButtons(),
              ),
              
              const SizedBox(height: 16),
              
              // Fluid Type
              const Text('Fluid Type', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _fluidType,
                isExpanded: true,
                items: _fluidTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _fluidType = value;
                    });
                  }
                },
              ),
              
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
              
              // Save button
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
  
  List<Widget> _getQuickVolumeButtons() {
    // Define quick add volumes based on the selected unit
    List<double> quickVolumes = [];
    
    switch (_volumeUnit) {
      case 'ml':
        quickVolumes = [100, 200, 250, 300, 500, 750];
        break;
      case 'L':
        quickVolumes = [0.25, 0.5, 0.75, 1, 1.5, 2];
        break;
      case 'cups':
        quickVolumes = [0.5, 1, 1.5, 2, 3, 4];
        break;
      case 'oz':
        quickVolumes = [4, 8, 12, 16, 20, 32];
        break;
    }
    
    return quickVolumes.map((volume) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _volumeController.text = volume.toString();
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text('$volume $_volumeUnit'),
      );
    }).toList();
  }
}