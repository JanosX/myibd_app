// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:myibd_app/models/user_profile.dart';
import 'package:myibd_app/repositories/user_repository.dart';
import 'package:myibd_app/screens/settings/profile_settings_screen.dart';
import 'package:myibd_app/screens/settings/unit_preferences_screen.dart';
import 'package:myibd_app/screens/settings/notification_settings_screen.dart';
import 'package:myibd_app/screens/settings/theme_settings_screen.dart';
import 'package:myibd_app/screens/settings/privacy_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _userRepository = UserRepository();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _userRepository.getCurrentUser();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Profile Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile Settings'),
                  subtitle: Text(_userProfile?.name ?? 'Not set'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileSettingsScreen(),
                      ),
                    );
                    _loadUserProfile();
                  },
                ),
                const Divider(),
                
                // Preferences Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Units'),
                  subtitle: Text(_userProfile?.preferences.unitSystem == 'imperial' 
                      ? 'Imperial (oz, lbs)' 
                      : 'Metric (ml, kg)'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnitPreferencesScreen(),
                      ),
                    );
                    _loadUserProfile();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: Text(_userProfile?.preferences.notificationsEnabled ?? true
                      ? 'Enabled'
                      : 'Disabled'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsScreen(),
                      ),
                    );
                    _loadUserProfile();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeText(_userProfile?.preferences.themeMode ?? 'system')),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThemeSettingsScreen(),
                      ),
                    );
                    _loadUserProfile();
                  },
                ),
                const Divider(),
                
                // Data & Privacy Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Data & Privacy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Privacy & Export'),
                  subtitle: const Text('Data export and privacy settings'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacySettingsScreen(),
                      ),
                    );
                    _loadUserProfile();
                  },
                ),
                const Divider(),
                
                // About Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About MyIBD'),
                  subtitle: const Text('Version 1.0.0'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'MyIBD',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.medical_services, size: 48),
                      children: [
                        const Text('MyIBD is a comprehensive tracking app for managing Inflammatory Bowel Disease.'),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }

  String _getThemeText(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System default';
    }
  }
}