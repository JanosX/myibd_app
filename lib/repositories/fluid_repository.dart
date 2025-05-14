import 'package:myibd_app/models/fluid_intake.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class FluidRepository extends BaseRepository<FluidIntake> {
  static const String _storageKey = 'fluid_intakes';
  
  FluidRepository() : super(_storageKey);
  
  @override
  FluidIntake fromMap(Map<String, dynamic> map) {
    return FluidIntake.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(FluidIntake item) {
    return item.toMap();
  }
  
  // Get entries for a specific date
  Future<List<FluidIntake>> getForDate(DateTime date) async {
    final allEntries = await getAll();
    return allEntries.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }
  
  // Get total volume for today in ml
  Future<double> getTodayTotalMl() async {
    final today = DateTime.now();
    final todayEntries = await getForDate(today);
    
    double totalMl = 0;
    for (final entry in todayEntries) {
      totalMl += _convertToMl(entry.volume, entry.volumeUnit);
    }
    
    return totalMl;
  }
  
  // Convert any unit to ml
  double _convertToMl(double volume, String unit) {
    switch (unit) {
      case 'ml':
        return volume;
      case 'L':
        return volume * 1000;
      case 'cups':
        return volume * 236.588; // 1 cup = 236.588 ml
      case 'oz':
        return volume * 29.5735; // 1 oz = 29.5735 ml
      default:
        return volume;
    }
  }
  
  // Get formatted total for display (e.g., "1.2L")
  Future<String> getTodayTotalFormatted() async {
    final totalMl = await getTodayTotalMl();
    
    if (totalMl >= 1000) {
      return '${(totalMl / 1000).toStringAsFixed(1)}L';
    } else {
      return '${totalMl.toInt()}ml';
    }
  }
}