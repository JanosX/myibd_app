import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myibd_app/models/fluid_intake.dart';
import 'package:myibd_app/repositories/fluid_repository.dart';
import 'package:myibd_app/screens/fluid/fluid_form_screen.dart';

class FluidHistoryScreen extends StatefulWidget {
  const FluidHistoryScreen({super.key});

  @override
  State<FluidHistoryScreen> createState() => _FluidHistoryScreenState();
}

class _FluidHistoryScreenState extends State<FluidHistoryScreen> {
  final _fluidRepository = FluidRepository();
  List<FluidIntake> _entries = [];
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
      final entries = await _fluidRepository.getAll();
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
        title: const Text('Fluid Intake History'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FluidFormScreen()),
          );
          
          if (result == true) {
            _loadEntries(); // Reload if data was saved
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Text('No fluid intake recorded yet'),
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
                          backgroundColor: _getFluidColor(entry.fluidType),
                          child: Icon(
                            _getFluidIcon(entry.fluidType),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(dateFormat.format(entry.timestamp)),
                        subtitle: Text('${entry.volume} ${entry.volumeUnit} of ${entry.fluidType}'),
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
                              await _fluidRepository.delete(entry.id!);
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
  
  IconData _getFluidIcon(String fluidType) {
    switch (fluidType) {
      case 'water':
        return Icons.water_drop;
      case 'coffee':
        return Icons.coffee;
      case 'tea':
        return Icons.emoji_food_beverage;
      case 'juice':
        return Icons.local_drink;
      case 'soda':
        return Icons.bubble_chart;
      case 'milk':
        return Icons.coffee;
      case 'beer':
        return Icons.sports_bar;
      case 'wine':
        return Icons.wine_bar;
      case 'sports drink':
        return Icons.sports_handball;
      default:
        return Icons.local_drink;
    }
  }
  
  Color _getFluidColor(String fluidType) {
    switch (fluidType) {
      case 'water':
        return Colors.blue;
      case 'coffee':
        return Colors.brown;
      case 'tea':
        return Colors.orange;
      case 'juice':
        return Colors.orange.shade700;
      case 'soda':
        return Colors.red;
      case 'milk':
        return Colors.blueGrey;
      case 'beer':
        return Colors.amber;
      case 'wine':
        return Colors.purple;
      case 'sports drink':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}