import 'package:flutter/material.dart';
import 'package:myibd_app/models/medicine_box.dart';
import 'package:myibd_app/repositories/medicine_box_repository.dart';
import 'package:myibd_app/screens/medication/add_edit_medication_screen.dart';

class MedicineBoxScreen extends StatefulWidget {
  const MedicineBoxScreen({super.key});

  @override
  State<MedicineBoxScreen> createState() => _MedicineBoxScreenState();
}

class _MedicineBoxScreenState extends State<MedicineBoxScreen> {
  final _medicineBoxRepository = MedicineBoxRepository();
  List<MedicineBox> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final medications = await _medicineBoxRepository.getAll();
      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medications: $e')),
        );
      }
    }
  }

  Future<void> _deleteMedication(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: const Text('Are you sure you want to remove this medication from your medicine box?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _medicineBoxRepository.delete(id);
        await _loadMedications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medication removed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting medication: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Box'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Medicine Box'),
                  content: const Text(
                    'Store your frequently used medications here for quick tracking. '
                    'Set default dosages and mark medications as prescription or natural.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditMedicationScreen(),
            ),
          );
          if (result == true) {
            _loadMedications();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No medications in your medicine box',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to add a medication',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final medication = _medications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: medication.isPrescription
                              ? Colors.blue
                              : Colors.green,
                          child: Icon(
                            medication.isPrescription
                                ? Icons.medical_services
                                : Icons.eco,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(medication.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Default: ${medication.defaultDosage} (${_getRouteString(medication.defaultRoute)})'),
                            Row(
                              children: [
                                if (medication.isPrescription)
                                  const Chip(
                                    label: Text('Prescription'),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                if (medication.isNatural)
                                  const Chip(
                                    label: Text('Natural'),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditMedicationScreen(
                                    medication: medication,
                                  ),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  _loadMedications();
                                }
                              });
                            } else if (value == 'delete') {
                              _deleteMedication(medication.id!);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _getRouteString(String route) {
    switch (route) {
      case 'oral':
        return 'By mouth';
      case 'injection':
        return 'Injection';
      case 'topical':
        return 'On skin';
      case 'inhaled':
        return 'Inhaled';
      case 'eye_drops':
        return 'Eye drops';
      case 'ear_drops':
        return 'Ear drops';
      case 'nasal':
        return 'Nasal spray';
      case 'rectal':
        return 'Rectal';
      case 'sublingual':
        return 'Under tongue';
      case 'patch':
        return 'Skin patch';
      default:
        return route;
    }
  }
}