import 'package:myibd_app/models/food_entry.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class FoodRepository extends BaseRepository<FoodEntry> {
  static const String _storageKey = 'food_entries';
  
  FoodRepository() : super(_storageKey);
  
  @override
  FoodEntry fromMap(Map<String, dynamic> map) {
    return FoodEntry.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(FoodEntry item) {
    return item.toMap();
  }
  
  // Get entries for a specific date
  Future<List<FoodEntry>> getForDate(DateTime date) async {
    final allEntries = await getAll();
    return allEntries.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }
  
  // Get meal count for today
  Future<int> getTodayMealCount() async {
    final today = DateTime.now();
    final todayEntries = await getForDate(today);
    return todayEntries.length;
  }
}