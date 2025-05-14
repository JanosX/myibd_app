import 'package:myibd_app/models/sleep.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class SleepRepository extends BaseRepository<Sleep> {
  static const String _storageKey = 'sleep_entries';
  
  SleepRepository() : super(_storageKey);
  
  @override
  Sleep fromMap(Map<String, dynamic> map) {
    return Sleep.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(Sleep item) {
    return item.toMap();
  }
  
  // Get last sleep entry
  Future<Sleep?> getLastSleep() async {
    final allEntries = await getAll();
    if (allEntries.isEmpty) return null;
    
    allEntries.sort((a, b) => b.endTime.compareTo(a.endTime));
    return allEntries.first;
  }
  
  // Get formatted duration for last sleep
  Future<String> getLastSleepFormatted() async {
    final lastSleep = await getLastSleep();
    if (lastSleep == null) return '0h';
    
    final hours = lastSleep.actualSleepMinutes ~/ 60;
    final minutes = lastSleep.actualSleepMinutes % 60;
    
    if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }
  
  // Get entries for a specific date
  Future<List<Sleep>> getForDate(DateTime date) async {
    final allEntries = await getAll();
    return allEntries.where((entry) {
      return entry.endTime.year == date.year &&
          entry.endTime.month == date.month &&
          entry.endTime.day == date.day;
    }).toList();
  }
}