class Flare {
  final String? id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String notes;

  Flare({
    this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.notes = '',
  });

  int get daysActive {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'is_active': isActive,
      'notes': notes,
    };
  }

  factory Flare.fromMap(Map<String, dynamic> map) {
    return Flare(
      id: map['id'],
      userId: map['user_id'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: map['end_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date']) 
          : null,
      isActive: map['is_active'],
      notes: map['notes'] ?? '',
    );
  }
}