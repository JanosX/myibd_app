// lib/repositories/user_repository.dart
import 'package:myibd_app/models/user_profile.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class UserRepository extends BaseRepository<UserProfile> {
  static const String _storageKey = 'user_profile';
  
  UserRepository() : super(_storageKey);
  
  @override
  UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(UserProfile item) {
    return item.toMap();
  }
  
  // Get current user profile
  Future<UserProfile?> getCurrentUser() async {
    final users = await getAll();
    return users.isEmpty ? null : users.first;
  }
  
  // Update preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      final updatedUser = UserProfile(
        id: currentUser.id,
        userId: currentUser.userId,
        name: currentUser.name,
        email: currentUser.email,
        preferences: preferences,
      );
      await update(updatedUser);
    }
  }
}