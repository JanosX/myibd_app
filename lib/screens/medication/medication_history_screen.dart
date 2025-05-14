import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myibd_app/models/medication.dart';
import 'package:myibd_app/repositories/medication_repository.dart';
import 'package:myibd_app/screens/medication/medication_form_screen.dart';
import 'package:myibd_app/screens/medication/medicine_box_screen.dart';

class MedicationHistoryScreen extends StatefulWidget {
  const MedicationHistoryScreen({super.key});

  @override
  State<MedicationHistoryScreen> createState() => _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState extends State<MedicationHistoryScreen> {
  final _medicationRepository = MedicationRepository();
  List<Medication> _entries = [];
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
      final entries = await _medicationRepository.getAll();
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
        title: const Text('Medication History'),
actions: [
        IconButton(
          icon: const Icon(Icons.medical_services),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MedicineBoxScreen()),
            );
          },
          tooltip: 'Medicine Box',
        ),
      ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MedicationFormScreen()),
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
                  child: Text('No medications recorded yet'),
                )
              : ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getTypeColor(entry.type),
                          child: Icon(
                            _getTypeIcon(entry.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(entry.medicationName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateFormat.format(entry.timestamp)),
                            Text('Dosage: ${entry.dosage}'),
                            Text('Route: ${_getRouteString(entry.route)}'),
                            Text('Type: ${_getTypeString(entry.type)}'),
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
                              await _medicationRepository.delete(entry.id!);
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
  
  Color _getTypeColor(MedicationType type) {
    switch (type) {
      case MedicationType.prescription:
        return Colors.blue.shade700;
      case MedicationType.natural:
        return Colors.green.shade700;
      case MedicationType.custom:
        return Colors.orange.shade700;
      case MedicationType.medicineBox:
        return Colors.purple.shade700;
    }
  }
  
  IconData _getTypeIcon(MedicationType type) {
    switch (type) {
      case MedicationType.prescription:
        return Icons.medical_services;
      case MedicationType.natural:
        return Icons.eco;
      case MedicationType.custom:
        return Icons.edit;
      case MedicationType.medicineBox:
        return Icons.medical_services;
    }
  }
  
  String _getTypeString(MedicationType type) {
    switch (type) {
      case MedicationType.prescription:
        return 'Prescription';
      case MedicationType.natural:
        return 'Natural';
      case MedicationType.custom:
        return 'Custom';
      case MedicationType.medicineBox:
        return 'Medicine Box';
    }
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