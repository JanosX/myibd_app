import 'package:myibd_app/models/medication.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class MedicationRepository extends BaseRepository<Medication> {
  static const String _storageKey = 'medications';
  
  MedicationRepository() : super(_storageKey);
  
  @override
  Medication fromMap(Map<String, dynamic> map) {
    return Medication.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(Medication item) {
    return item.toMap();
  }
  
  // Get entries for a specific date
  Future<List<Medication>> getForDate(DateTime date) async {
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
    return todayEntries.length;
  }
}