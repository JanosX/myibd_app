// lib/screens/settings/profile_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:myibd_app/models/user_profile.dart';
import 'package:myibd_app/repositories/user_repository.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _userRepository = UserRepository();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _userRepository.getCurrentUser();
      setState(() {
        _userProfile = profile;
        _nameController.text = profile?.name ?? '';
        _emailController.text = profile?.email ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) {
      // Create new profile if it doesn't exist
      _userProfile = UserProfile(
        userId: 'user123', // In real app, get from auth
        name: _nameController.text,
        email: _emailController.text,
        preferences: UserPreferences(),
      );
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedProfile = UserProfile(
        id: _userProfile!.id,
        userId: _userProfile!.userId,
        name: _nameController.text,
        email: _emailController.text,
        preferences: _userProfile!.preferences,
      );

      if (_userProfile!.id == null) {
        await _userRepository.save(updatedProfile);
      } else {
        await _userRepository.update(updatedProfile);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
    );
  }
}