// lib/screens/settings/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:myibd_app/models/user_profile.dart';
import 'package:myibd_app/models/medicine_box.dart';
import 'package:myibd_app/repositories/user_repository.dart';
import 'package:myibd_app/repositories/medicine_box_repository.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _userRepository = UserRepository();
  final _medicineBoxRepository = MedicineBoxRepository();
  
  UserProfile? _userProfile;
  bool _notificationsEnabled = true;
  List<MedicationReminder> _reminders = [];
  List<MedicineBox> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _userRepository.getCurrentUser();
      final meds = await _medicineBoxRepository.getAll();
      
      setState(() {
        _userProfile = profile;
        _notificationsEnabled = profile?.preferences.notificationsEnabled ?? true;
        _reminders = profile?.preferences.medicationReminders ?? [];
        _medications = meds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    if (_userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPreferences = _userProfile!.preferences.copyWith(
        notificationsEnabled: _notificationsEnabled,
        medicationReminders: _reminders,
      );
      
      await _userRepository.updatePreferences(updatedPreferences);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification settings saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addReminder(MedicineBox medication) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final now = DateTime.now();
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      setState(() {
        _reminders.add(
          MedicationReminder(
            medicationId: medication.id!,
            medicationName: medication.name,
            reminderTimes: [reminderTime],
            enabled: true,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePreferences,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Master Switch
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Allow MyIBD to send notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Medication Reminders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Medication Reminders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _notificationsEnabled ? () {
                        // Show dialog to select medication
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Medication'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _medications.length,
                                itemBuilder: (context, index) {
                                  final med = _medications[index];
                                  return ListTile(
                                    title: Text(med.name),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _addReminder(med);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      } : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (_reminders.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No medication reminders set'),
                    ),
                  )
                else
                  ..._reminders.map((reminder) => Card(
                    child: ListTile(
                      title: Text(reminder.medicationName),
                      subtitle: Text(
                        'Daily at ${reminder.reminderTimes.map((t) => 
                          TimeOfDay.fromDateTime(t).format(context)).join(', ')}'
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: reminder.enabled,
                            onChanged: (value) {
                              setState(() {
                                final index = _reminders.indexOf(reminder);
                                _reminders[index] = MedicationReminder(
                                  medicationId: reminder.medicationId,
                                  medicationName: reminder.medicationName,
                                  reminderTimes: reminder.reminderTimes,
                                  enabled: value,
                                );
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _reminders.remove(reminder);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
              ],
            ),
    );
  }
}