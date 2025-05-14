import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseRepository<T> {
  final String storageKey;
  
  BaseRepository(this.storageKey);
  
  // Abstract methods that subclasses must implement
  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T item);
  
  // Common storage methods
  Future<List<T>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataJson = prefs.getString(storageKey);
    
    if (dataJson == null) {
      return [];
    }
    
    final List<dynamic> decodedJson = jsonDecode(dataJson);
    return decodedJson.map((json) => fromMap(json)).toList();
  }
  
  Future<void> save(T item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<T> items = await getAll();
    
    final Map<String, dynamic> itemMap = toMap(item);
    
    // Add an ID if it doesn't have one
    if (itemMap['id'] == null) {
      itemMap['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    items.add(fromMap(itemMap));
    
    final List<Map<String, dynamic>> jsonList = 
        items.map((item) => toMap(item)).toList();
    
    await prefs.setString(storageKey, jsonEncode(jsonList));
  }
  
  Future<void> update(T item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<T> items = await getAll();
    
    final itemMap = toMap(item);
    final index = items.indexWhere((i) => toMap(i)['id'] == itemMap['id']);
    
    if (index != -1) {
      items[index] = item;
      
      final List<Map<String, dynamic>> jsonList = 
          items.map((item) => toMap(item)).toList();
      
      await prefs.setString(storageKey, jsonEncode(jsonList));
    }
  }
  
  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<T> items = await getAll();
    
    items.removeWhere((item) => toMap(item)['id'] == id);
    
    final List<Map<String, dynamic>> jsonList = 
        items.map((item) => toMap(item)).toList();
    
    await prefs.setString(storageKey, jsonEncode(jsonList));
  }
  
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}