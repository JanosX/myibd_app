import 'package:flutter/material.dart';
import 'package:myibd_app/models/medication.dart';
import 'package:myibd_app/models/medicine_box.dart';
import 'package:myibd_app/repositories/medication_repository.dart';
import 'package:myibd_app/repositories/medicine_box_repository.dart';
import 'package:myibd_app/screens/medication/medicine_box_screen.dart';

class MedicationFormScreen extends StatefulWidget {
  const MedicationFormScreen({super.key});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationRepository = MedicationRepository();
  final _medicineBoxRepository = MedicineBoxRepository();
  
  DateTime _timestamp = DateTime.now();
  String _dosage = '';
  String _medicationName = '';
  MedicationType _selectedType = MedicationType.medicineBox;
  String _route = 'oral';
  
  // Controllers
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  List<MedicineBox> _medicineBoxItems = [];
  MedicineBox? _selectedMedicineBoxItem;
  String? _selectedApiMedication;
  bool _isSearching = false;
  bool _isSaving = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadMedicineBox();
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _customNameController.dispose();
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicineBox() async {
    final items = await _medicineBoxRepository.getAll();
    setState(() {
      _medicineBoxItems = items;
    });
  }

  void _performSearch(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate API search - replace with actual API calls later
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _searchResults = [
        {'name': 'Aspirin', 'type': 'prescription', 'rxnorm_id': '1191'},
        {'name': 'Echinacea', 'type': 'natural', 'nhpl_id': '80012345'},
        {'name': 'Probiotic Complex', 'type': 'natural', 'nhpl_id': '80054321'},
      ];
      _isSearching = false;
    });
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        // Determine medication name and ID based on selection type
        String medicationId = '';
        String medicationName = '';
        String? rxnormId;
        String? nhplId;
        
        switch (_selectedType) {
          case MedicationType.medicineBox:
            if (_selectedMedicineBoxItem == null) {
              throw Exception('Please select a medication from your medicine box');
            }
            medicationId = _selectedMedicineBoxItem!.id ?? '';
            medicationName = _selectedMedicineBoxItem!.name;
            rxnormId = _selectedMedicineBoxItem!.rxnormId;
            nhplId = _selectedMedicineBoxItem!.nhplId;
            break;
          case MedicationType.prescription:
          case MedicationType.natural:
            if (_selectedApiMedication == null) {
              throw Exception('Please select a medication from search results');
            }
            medicationName = _selectedApiMedication!;
            // In real app, get the IDs from selected search result
            break;
          case MedicationType.custom:
            if (_customNameController.text.isEmpty) {
              throw Exception('Please enter medication name');
            }
            medicationName = _customNameController.text;
            break;
        }
        
        final medication = Medication(
          userId: 'user123', // In real app, get from auth
          timestamp: _timestamp,
          medicationId: medicationId,
          medicationName: medicationName,
          dosage: _dosageController.text,
          route: _route,
          type: _selectedType,
          rxnormId: rxnormId,
          nhplId: nhplId,
          notes: _notesController.text,
        );
        
        await _medicationRepository.save(medication);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medication recorded')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
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
        title: const Text('Record Medication'),
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
              
              // Medication Type Selection
              const Text('Medication Source', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<MedicationType>(
                segments: const [
                  ButtonSegment(
                    value: MedicationType.medicineBox,
                    label: Text('My Medicine Box'),
                    icon: Icon(Icons.medical_services, size: 18),
                  ),
                  ButtonSegment(
                    value: MedicationType.prescription,
                    label: Text('Search'),
                    icon: Icon(Icons.search, size: 18),
                  ),
                  ButtonSegment(
                    value: MedicationType.custom,
                    label: Text('Custom'),
                    icon: Icon(Icons.edit, size: 18),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<MedicationType> selection) {
                  setState(() {
                    _selectedType = selection.first;
                    // Reset selections when changing type
                    _selectedMedicineBoxItem = null;
                    _selectedApiMedication = null;
                    _customNameController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Content based on selected type
              if (_selectedType == MedicationType.medicineBox) ...[
                const Text('Select from Medicine Box', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_medicineBoxItems.isEmpty)
                  const Text('No items in your medicine box yet'),
                ...List.generate(_medicineBoxItems.length, (index) {
                  final item = _medicineBoxItems[index];
                  return Card(
                    child: RadioListTile<MedicineBox>(
                      title: Text(item.name),
                      subtitle: Text('Default: ${item.defaultDosage}'),
                      secondary: Icon(
                        item.isPrescription ? Icons.medical_services : Icons.eco,
                        color: item.isPrescription ? Colors.blue : Colors.green,
                      ),
                      value: item,
                      groupValue: _selectedMedicineBoxItem,
                      onChanged: (value) {
                        setState(() {
                          _selectedMedicineBoxItem = value;
                          _dosageController.text = value?.defaultDosage ?? '';
                          if (value != null) {
                            _route = value.defaultRoute;
                          }
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MedicineBoxScreen()),
                    ).then((value) {
                      // Reload medicine box items after returning
                      _loadMedicineBox();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Manage Medicine Box'),
                ),
              ] else if (_selectedType == MedicationType.prescription) ...[
                const Text('Search Medications', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search RXNORM and Canada NHPL...',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.search),
                  ),
                  onChanged: _performSearch,
                ),
                const SizedBox(height: 8),
                if (_searchResults.isNotEmpty) ...[
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return Card(
                          child: RadioListTile<String>(
                            title: Text(result['name']),
                            subtitle: Text(result['type']),
                            secondary: Icon(
                              result['type'] == 'prescription' 
                                  ? Icons.medical_services 
                                  : Icons.eco,
                              color: result['type'] == 'prescription' 
                                  ? Colors.blue 
                                  : Colors.green,
                            ),
                            value: result['name'],
                            groupValue: _selectedApiMedication,
                            onChanged: (value) {
                              setState(() {
                                _selectedApiMedication = value;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ] else if (_selectedType == MedicationType.custom) ...[
                const Text('Custom Medication', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customNameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedType == MedicationType.custom && 
                        (value == null || value.isEmpty)) {
                      return 'Please enter medication name';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              
              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 200mg, 2 tablets, 1 tsp',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
         
              // Route of Administration
              const Text('How is it taken?', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select route',
                ),
                value: _route,
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
                      _route = value;
                    });
                  }
                },
              ),
              
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
}