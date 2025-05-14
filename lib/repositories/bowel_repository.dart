import 'package:myibd_app/models/bowel_movement.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class BowelRepository extends BaseRepository<BowelMovement> {
  static const String _storageKey = 'bowel_movements';
  
  BowelRepository() : super(_storageKey);
  
  @override
  BowelMovement fromMap(Map<String, dynamic> map) {
    return BowelMovement.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(BowelMovement item) {
    return item.toMap();
  }
  
  // Get entries for a specific date
  Future<List<BowelMovement>> getForDate(DateTime date) async {
    final allEntries = await getAll();
    return allEntries.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }
  
  // Get entries for date range
  Future<List<BowelMovement>> getForDateRange(DateTime start, DateTime end) async {
    final allEntries = await getAll();
    return allEntries.where((entry) {
      return entry.timestamp.isAfter(start) && 
          entry.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Get count for today
  Future<int> getTodayCount() async {
    final today = DateTime.now();
    final todayEntries = await getForDate(today);
    return todayEntries.length;
  }
}