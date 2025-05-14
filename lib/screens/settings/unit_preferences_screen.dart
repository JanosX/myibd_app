// lib/screens/settings/unit_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:myibd_app/models/user_profile.dart';
import 'package:myibd_app/repositories/user_repository.dart';

class UnitPreferencesScreen extends StatefulWidget {
  const UnitPreferencesScreen({super.key});

  @override
  State<UnitPreferencesScreen> createState() => _UnitPreferencesScreenState();
}

class _UnitPreferencesScreenState extends State<UnitPreferencesScreen> {
  final _userRepository = UserRepository();
  UserProfile? _userProfile;
  String _selectedUnitSystem = 'metric';
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
        _selectedUnitSystem = profile?.preferences.unitSystem ?? 'metric';
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
        unitSystem: _selectedUnitSystem,
      );
      
      await _userRepository.updatePreferences(updatedPreferences);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit preferences saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
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
        title: const Text('Unit Preferences'),
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
                const Text(
                  'Choose your preferred unit system',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                // Metric Option
                Card(
                  child: RadioListTile<String>(
                    title: const Text('Metric'),
                    subtitle: const Text('Milliliters (ml), Liters (L), Kilograms (kg)'),
                    value: 'metric',
                    groupValue: _selectedUnitSystem,
                    onChanged: (value) {
                      setState(() {
                        _selectedUnitSystem = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                
                // Imperial Option
                Card(
                  child: RadioListTile<String>(
                    title: const Text('Imperial'),
                    subtitle: const Text('Ounces (oz), Cups, Pounds (lbs)'),
                    value: 'imperial',
                    groupValue: _selectedUnitSystem,
                    onChanged: (value) {
                      setState(() {
                        _selectedUnitSystem = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Examples
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Examples',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedUnitSystem == 'metric'
                              ? '• Fluid: 250ml, 1.5L\n• Weight: 70kg\n• Temperature: 37°C'
                              : '• Fluid: 8oz, 2 cups\n• Weight: 154lbs\n• Temperature: 98.6°F',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}