class FoodEntry {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final String mealName;
  final List<String> ingredients;
  final String amount; // light, some, lots
  final String category; // breakfast, lunch, dinner, snack
  final String notes;

  FoodEntry({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.mealName,
    required this.ingredients,
    required this.amount,
    required this.category,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'meal_name': mealName,
      'ingredients': ingredients,
      'amount': amount,
      'category': category,
      'notes': notes,
    };
  }

  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'],
      userId: map['user_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      mealName: map['meal_name'],
      ingredients: List<String>.from(map['ingredients']),
      amount: map['amount'],
      category: map['category'],
      notes: map['notes'] ?? '',
    );
  }
}