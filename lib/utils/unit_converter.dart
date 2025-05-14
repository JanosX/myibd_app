// lib/utils/unit_converter.dart
import 'package:myibd_app/repositories/user_repository.dart';

class UnitConverter {
  static final UserRepository _userRepository = UserRepository();
  
  static Future<bool> get isImperial async {
    final profile = await _userRepository.getCurrentUser();
    return profile?.preferences.unitSystem == 'imperial';
  }
  
  // Volume conversions
  static Future<double> convertVolumeToDisplay(double volumeInMl) async {
    if (await isImperial) {
      return volumeInMl * 0.033814; // ml to oz
    }
    return volumeInMl;
  }
  
  static Future<String> getVolumeUnit() async {
    if (await isImperial) {
      return 'oz';
    }
    return 'ml';
  }
  
  static Future<double> convertVolumeFromDisplay(double value, String unit) async {
    if (unit == 'oz') {
      return value * 29.5735; // oz to ml
    } else if (unit == 'cups') {
      return value * 236.588; // cups to ml
    } else if (unit == 'L') {
      return value * 1000; // L to ml
    }
    return value; // Already in ml
  }
  
  // Weight conversions (if needed in future)
  static Future<double> convertWeightToDisplay(double weightInKg) async {
    if (await isImperial) {
      return weightInKg * 2.20462; // kg to lbs
    }
    return weightInKg;
  }
  
  static Future<String> getWeightUnit() async {
    if (await isImperial) {
      return 'lbs';
    }
    return 'kg';
  }
}