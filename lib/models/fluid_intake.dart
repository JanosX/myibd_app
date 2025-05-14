class FluidIntake {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final double volume;
  final String volumeUnit; // ml, L, cups, oz
  final String fluidType; // water, coffee, tea, etc.
  final String notes;

  FluidIntake({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.volume,
    required this.volumeUnit,
    required this.fluidType,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'volume': volume,
      'volume_unit': volumeUnit,
      'fluid_type': fluidType,
      'notes': notes,
    };
  }

  factory FluidIntake.fromMap(Map<String, dynamic> map) {
    return FluidIntake(
      id: map['id'],
      userId: map['user_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      volume: map['volume'].toDouble(),
      volumeUnit: map['volume_unit'],
      fluidType: map['fluid_type'],
      notes: map['notes'] ?? '',
    );
  }
}