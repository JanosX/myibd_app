import 'package:myibd_app/models/flare.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class FlareRepository extends BaseRepository<Flare> {
  static const String _storageKey = 'flares';
  
  FlareRepository() : super(_storageKey);
  
  @override
  Flare fromMap(Map<String, dynamic> map) {
    return Flare.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(Flare item) {
    return item.toMap();
  }
  
  // Get current active flare
  Future<Flare?> getActiveFlare() async {
    final allFlares = await getAll();
    try {
      return allFlares.firstWhere((flare) => flare.isActive);
    } catch (e) {
      return null;
    }
  }
  
  // Start a new flare
  Future<void> startFlare() async {
    // End any existing active flares
    final activeFlare = await getActiveFlare();
    if (activeFlare != null) {
      final updatedFlare = Flare(
        id: activeFlare.id,
        userId: activeFlare.userId,
        startDate: activeFlare.startDate,
        endDate: DateTime.now(),
        isActive: false,
        notes: activeFlare.notes,
      );
      await update(updatedFlare);
    }
    
    // Create new flare
    final newFlare = Flare(
      userId: 'user123', // In real app, get from auth
      startDate: DateTime.now(),
      isActive: true,
    );
    await save(newFlare);
  }
  
  // End current flare
  Future<void> endFlare() async {
    final activeFlare = await getActiveFlare();
    if (activeFlare != null) {
      final updatedFlare = Flare(
        id: activeFlare.id,
        userId: activeFlare.userId,
        startDate: activeFlare.startDate,
        endDate: DateTime.now(),
        isActive: false,
        notes: activeFlare.notes,
      );
      await update(updatedFlare);
    }
  }
  
  // Get flare days
  Future<int> getFlareDays() async {
    final activeFlare = await getActiveFlare();
    if (activeFlare == null) return 0;
    return activeFlare.daysActive;
  }
}