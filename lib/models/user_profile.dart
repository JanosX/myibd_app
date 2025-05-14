// lib/models/user_profile.dart
class UserProfile {
  final String? id;
  final String userId;
  final String name;
  final String email;
  final UserPreferences preferences;

  UserProfile({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'preferences': preferences.toMap(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      email: map['email'],
      preferences: UserPreferences.fromMap(map['preferences'] ?? {}),
    );
  }
}

class UserPreferences {
  final String unitSystem; // 'metric' or 'imperial'
  final bool notificationsEnabled;
  final List<MedicationReminder> medicationReminders;
  final String themeMode; // 'light', 'dark', or 'system'
  final bool autoExport;
  final int exportFrequencyDays;
  final String exportFormat; // 'pdf' or 'csv'
  
  UserPreferences({
    this.unitSystem = 'metric',
    this.notificationsEnabled = true,
    this.medicationReminders = const [],
    this.themeMode = 'system',
    this.autoExport = false,
    this.exportFrequencyDays = 30,
    this.exportFormat = 'pdf',
  });

  Map<String, dynamic> toMap() {
    return {
      'unit_system': unitSystem,
      'notifications_enabled': notificationsEnabled,
      'medication_reminders': medicationReminders.map((r) => r.toMap()).toList(),
      'theme_mode': themeMode,
      'auto_export': autoExport,
      'export_frequency_days': exportFrequencyDays,
      'export_format': exportFormat,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      unitSystem: map['unit_system'] ?? 'metric',
      notificationsEnabled: map['notifications_enabled'] ?? true,
      medicationReminders: (map['medication_reminders'] as List<dynamic>?)
          ?.map((r) => MedicationReminder.fromMap(r))
          .toList() ?? [],
      themeMode: map['theme_mode'] ?? 'system',
      autoExport: map['auto_export'] ?? false,
      exportFrequencyDays: map['export_frequency_days'] ?? 30,
      exportFormat: map['export_format'] ?? 'pdf',
    );
  }

  UserPreferences copyWith({
    String? unitSystem,
    bool? notificationsEnabled,
    List<MedicationReminder>? medicationReminders,
    String? themeMode,
    bool? autoExport,
    int? exportFrequencyDays,
    String? exportFormat,
  }) {
    return UserPreferences(
      unitSystem: unitSystem ?? this.unitSystem,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      medicationReminders: medicationReminders ?? this.medicationReminders,
      themeMode: themeMode ?? this.themeMode,
      autoExport: autoExport ?? this.autoExport,
      exportFrequencyDays: exportFrequencyDays ?? this.exportFrequencyDays,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }
}

class MedicationReminder {
  final String medicationId;
  final String medicationName;
  final List<DateTime> reminderTimes;
  final bool enabled;

  MedicationReminder({
    required this.medicationId,
    required this.medicationName,
    required this.reminderTimes,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'medication_id': medicationId,
      'medication_name': medicationName,
      'reminder_times': reminderTimes.map((t) => t.millisecondsSinceEpoch).toList(),
      'enabled': enabled,
    };
  }

  factory MedicationReminder.fromMap(Map<String, dynamic> map) {
    return MedicationReminder(
      medicationId: map['medication_id'],
      medicationName: map['medication_name'],
      reminderTimes: (map['reminder_times'] as List<dynamic>)
          .map((t) => DateTime.fromMillisecondsSinceEpoch(t))
          .toList(),
      enabled: map['enabled'] ?? true,
    );
  }
}