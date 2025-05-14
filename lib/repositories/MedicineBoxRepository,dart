import 'package:myibd_app/models/medicine_box.dart';
import 'package:myibd_app/repositories/base_repository.dart';

class MedicineBoxRepository extends BaseRepository<MedicineBox> {
  static const String _storageKey = 'medicine_box';
  
  MedicineBoxRepository() : super(_storageKey);
  
  @override
  MedicineBox fromMap(Map<String, dynamic> map) {
    return MedicineBox.fromMap(map);
  }
  
  @override
  Map<String, dynamic> toMap(MedicineBox item) {
    return item.toMap();
  }
  
  // Get all active medications
  Future<List<MedicineBox>> getActive() async {
    final allMeds = await getAll();
    // You could add an 'isActive' field to the model if needed
    return allMeds;
  }
  
  // Search medications by name
  Future<List<MedicineBox>> searchByName(String query) async {
    final allMeds = await getAll();
    final searchQuery = query.toLowerCase();
    return allMeds.where((med) => 
      med.name.toLowerCase().contains(searchQuery)
    ).toList();
  }
}