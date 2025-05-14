import 'package:flutter/material.dart';
import 'package:myibd_app/models/medicine_box.dart';
import 'package:myibd_app/repositories/medicine_box_repository.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final MedicineBox? medication;

  const AddEditMedicationScreen({
    super.key,
    this.medication,
  });

  @override
  State<AddEditMedicationScreen> createState() => _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineBoxRepository = MedicineBoxRepository();
  
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;
  
  bool _isPrescription = false;
  bool _isNatural = false;
  bool _isSaving = false;
  String _defaultRoute = 'oral';

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _dosageController = TextEditingController(text: widget.medication?.defaultDosage ?? '');
    _notesController = TextEditingController(text: widget.medication?.notes ?? '');
    
    if (widget.medication != null) {
      _isPrescription = widget.medication!.isPrescription;
      _isNatural = widget.medication!.isNatural;
      _defaultRoute = widget.medication!.defaultRoute;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final medication = MedicineBox(
          id: widget.medication?.id,
          userId: 'user123', // In real app, get from auth
          name: _nameController.text,
          rxnormId: widget.medication?.rxnormId,
          nhplId: widget.medication?.nhplId,
          isPrescription: _isPrescription,
          isNatural: _isNatural,
          defaultDosage: _dosageController.text,
          defaultRoute: _defaultRoute,
          notes: _notesController.text,
        );

        if (widget.medication == null) {
          await _medicineBoxRepository.save(medication);
        } else {
          await _medicineBoxRepository.update(medication);
        }

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.medication == null 
                  ? 'Medication added to medicine box' 
                  : 'Medication updated'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving medication: $e')),
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
        title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Default Dosage',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 200mg, 2 tablets, 1 tsp',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter default dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Default Route
              const Text('How is it taken?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select route',
                ),
                value: _defaultRoute,
                items: const [
                  DropdownMenuItem(value: 'oral', child: Text('By mouth (oral)')),
                  DropdownMenuItem(value: 'injection', child: Text('Injection')),
                  DropdownMenuItem(value: 'topical', child: Text('On skin (topical)')),
                  DropdownMenuItem(value: 'inhaled', child: Text('Inhaled')),
                  DropdownMenuItem(value: 'eye_drops', child: Text('Eye drops')),
                  DropdownMenuItem(value: 'ear_drops', child: Text('Ear drops')),
                  DropdownMenuItem(value: 'nasal', child: Text('Nasal spray')),
                  DropdownMenuItem(value: 'rectal', child: Text('Rectal')),
                  DropdownMenuItem(value: 'sublingual', child: Text('Under tongue')),
                  DropdownMenuItem(value: 'patch', child: Text('Skin patch')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _defaultRoute = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Medication Type
              const Text(
                'Medication Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              CheckboxListTile(
                title: const Text('Prescription'),
                subtitle: const Text('This is a prescription medication'),
                value: _isPrescription,
                onChanged: (value) {
                  setState(() {
                    _isPrescription = value ?? false;
                  });
                },
                secondary: const Icon(Icons.medical_services, color: Colors.blue),
              ),
              
              CheckboxListTile(
                title: const Text('Natural'),
                subtitle: const Text('This is a natural remedy or supplement'),
                value: _isNatural,
                onChanged: (value) {
                  setState(() {
                    _isNatural = value ?? false;
                  });
                },
                secondary: const Icon(Icons.eco, color: Colors.green),
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Any additional information',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // API Integration Note
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Future update: Search and add medications from '
                          'RXNORM and Canada NHPL databases',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveMedication,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text(widget.medication == null ? 'Add to Medicine Box' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}