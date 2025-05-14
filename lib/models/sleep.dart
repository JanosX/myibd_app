class Sleep {
  final String? id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int totalSleepMinutes;
  final int awakeMinutes;
  final int quality; // 1-5 scale
  final String notes;

  Sleep({
    this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.totalSleepMinutes,
    required this.awakeMinutes,
    required this.quality,
    this.notes = '',
  });

  // Calculate actual sleep time (total - awake)
  int get actualSleepMinutes => totalSleepMinutes - awakeMinutes;
  
  // Format sleep duration as hours and minutes
  String get formattedDuration {
    final hours = totalSleepMinutes ~/ 60;
    final minutes = totalSleepMinutes % 60;
    return '${hours}h ${minutes}m';
  }
  
  String get formattedActualSleep {
    final hours = actualSleepMinutes ~/ 60;
    final minutes = actualSleepMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'total_sleep_minutes': totalSleepMinutes,
      'awake_minutes': awakeMinutes,
      'quality': quality,
      'notes': notes,
    };
  }

  factory Sleep.fromMap(Map<String, dynamic> map) {
    return Sleep(
      id: map['id'],
      userId: map['user_id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time']),
      totalSleepMinutes: map['total_sleep_minutes'],
      awakeMinutes: map['awake_minutes'],
      quality: map['quality'],
      notes: map['notes'] ?? '',
    );
  }
}