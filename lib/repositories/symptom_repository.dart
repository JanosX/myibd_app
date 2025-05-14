import 'package:myibd_app/models/symptom.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class SymptomRepository extends BaseRepository<Symptom> {
  static const String _storageKey = 'symptoms';
  
  SymptomRepository() : super(_storageKey);
  
  @override
  Symptom fromMap(Map<String, dynamic> map) {
    return Symptom.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(Symptom item) {
    return item.toMap();
  }
  
  // Get entries for a specific date
  Future<List<Symptom>> getForDate(DateTime date) async {
    final allEntries = await getAll();
    return allEntries.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }
  
  // Get count for today
  Future<int> getTodayCount() async {
    final today = DateTime.now();
    final todayEntries = await getForDate(today);
    // Count individual symptoms rather than entries
    int count = 0;
    for (final entry in todayEntries) {
      count += entry.symptoms.length;
    }
    return count;
  }
  
  // Get today's flare status
  Future<bool> isFlareTody() async {
    final today = DateTime.now();
    final todayEntries = await getForDate(today);
    return todayEntries.any((entry) => entry.isFlare);
  }
}