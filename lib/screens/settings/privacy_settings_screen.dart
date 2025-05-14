// lib/screens/settings/privacy_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:myibd_app/models/user_profile.dart';
import 'package:myibd_app/repositories/user_repository.dart';
import 'package:myibd_app/screens/reports/report_screen.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final _userRepository = UserRepository();
  UserProfile? _userProfile;
  bool _autoExport = false;
  int _exportFrequency = 30;
  String _exportFormat = 'pdf';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _userRepository.getCurrentUser();
      setState(() {
        _userProfile = profile;
        _autoExport = profile?.preferences.autoExport ?? false;
        _exportFrequency = profile?.preferences.exportFrequencyDays ?? 30;
        _exportFormat = profile?.preferences.exportFormat ?? 'pdf';
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
        autoExport: _autoExport,
        exportFrequencyDays: _exportFrequency,
        exportFormat: _exportFormat,
      );
      
      await _userRepository.updatePreferences(updatedPreferences);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy settings saved')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Export'),
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
                // Manual Export
                const Text(
                  'Data Export',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Export Data Now'),
                    subtitle: const Text('Generate a report of your data'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Automatic Export
                const Text(
                  'Automatic Export',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable Auto Export'),
                    subtitle: const Text('Automatically export your data periodically'),
                    value: _autoExport,
                    onChanged: (value) {
                      setState(() {
                        _autoExport = value;
                      });
                    },
                  ),
                ),
                
                if (_autoExport) ...[
                  const SizedBox(height: 16),
                  
                  // Export Frequency
                  Card(
                    child: ListTile(
                      title: const Text('Export Frequency'),
                      subtitle: Text('Every $_exportFrequency days'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Export Frequency'),
                            content: DropdownButtonFormField<int>(
                              value: _exportFrequency,
                              items: const [
                                DropdownMenuItem(value: 7, child: Text('Weekly')),
                                DropdownMenuItem(value: 14, child: Text('Every 2 weeks')),
                                DropdownMenuItem(value: 30, child: Text('Monthly')),
                                DropdownMenuItem(value: 90, child: Text('Quarterly')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _exportFrequency = value!;
                                });
                                Navigator.pop(context);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Export Format
                  Card(
                    child: ListTile(
                      title: const Text('Export Format'),
                      subtitle: Text(_exportFormat.toUpperCase()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Export Format'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<String>(
                                  title: const Text('PDF'),
                                  value: 'pdf',
                                  groupValue: _exportFormat,
                                  onChanged: (value) {
                                    setState(() {
                                      _exportFormat = value!;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile<String>(
                                  title: const Text('CSV'),
                                  value: 'csv',
                                  groupValue: _exportFormat,
                                  onChanged: (value) {
                                    setState(() {
                                      _exportFormat = value!;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                
                // Data Management
                const Text(
                  'Data Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete All Data'),
                    subtitle: const Text('Permanently delete all your tracking data'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete All Data?'),
                          content: const Text(
                            'This action cannot be undone. All your tracking data will be permanently deleted.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // TODO: Implement data deletion
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Data deletion not implemented yet'),
                                  ),
                                );
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}