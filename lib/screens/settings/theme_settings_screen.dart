// lib/screens/settings/theme_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:myibd_app/models/user_profile.dart';
import 'package:myibd_app/repositories/user_repository.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  final _userRepository = UserRepository();
  UserProfile? _userProfile;
  String _selectedTheme = 'system';
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
        _selectedTheme = profile?.preferences.themeMode ?? 'system';
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
        themeMode: _selectedTheme,
      );
      
      await _userRepository.updatePreferences(updatedPreferences);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme preferences saved')),
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
        title: const Text('Theme Settings'),
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
                  'Choose your preferred theme',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                // Light Theme
                Card(
                  child: RadioListTile<String>(
                    title: const Text('Light'),
                    subtitle: const Text('Always use light theme'),
                    value: 'light',
                    groupValue: _selectedTheme,
                    secondary: const Icon(Icons.light_mode),
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                
                // Dark Theme
                Card(
                  child: RadioListTile<String>(
                    title: const Text('Dark'),
                    subtitle: const Text('Always use dark theme'),
                    value: 'dark',
                    groupValue: _selectedTheme,
                    secondary: const Icon(Icons.dark_mode),
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                
                // System Theme
                Card(
                  child: RadioListTile<String>(
                    title: const Text('System'),
                    subtitle: const Text('Follow system theme'),
                    value: 'system',
                    groupValue: _selectedTheme,
                    secondary: const Icon(Icons.settings_brightness),
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}