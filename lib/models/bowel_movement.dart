class BowelMovement {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final String size;
  final String color;
  final int bristolScale;
  final int urgency;
  final Map<String, bool> symptoms;
  final String notes;

  BowelMovement({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.size,
    required this.color,
    required this.bristolScale,
    required this.urgency,
    required this.symptoms,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'size': size,
      'color': color,
      'bristol_scale': bristolScale,
      'urgency': urgency,
      'symptoms': symptoms,
      'notes': notes,
    };
  }

  factory BowelMovement.fromMap(Map<String, dynamic> map) {
    return BowelMovement(
      id: map['id'],
      userId: map['user_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      size: map['size'],
      color: map['color'],
      bristolScale: map['bristol_scale'],
      urgency: map['urgency'],
      symptoms: Map<String, bool>.from(map['symptoms']),
      notes: map['notes'] ?? '',
    );
  }
}