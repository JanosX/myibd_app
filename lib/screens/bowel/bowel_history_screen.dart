import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myibd_app/models/bowel_movement.dart';
import 'package:myibd_app/repositories/bowel_repository.dart';
import 'package:myibd_app/screens/bowel/bowel_form_screen.dart';

class BowelHistoryScreen extends StatefulWidget {
  const BowelHistoryScreen({super.key});

  @override
  State<BowelHistoryScreen> createState() => _BowelHistoryScreenState();
}

class _BowelHistoryScreenState extends State<BowelHistoryScreen> {
  final _bowelRepository = BowelRepository();
  List<BowelMovement> _entries = [];
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
      final entries = await _bowelRepository.getAll();
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
        title: const Text('Bowel Movement History'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BowelFormScreen()),
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
                  child: Text('No bowel movements recorded yet'),
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
                          child: Text(entry.bristolScale.toString()),
                        ),
                        title: Text(dateFormat.format(entry.timestamp)),
                        subtitle: Text('Size: ${entry.size}, Urgency: ${entry.urgency}/5'),
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
                              await _bowelRepository.delete(entry.id!);
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
}