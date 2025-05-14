class Medication {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final String medicationId; // Reference to MedicineBox item or custom
  final String medicationName;
  final String dosage;
  final String route; // oral, injection, topical, etc.
  final MedicationType type;
  final String? rxnormId;
  final String? nhplId;
  final String notes;

  Medication({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.route,
    required this.type,
    this.rxnormId,
    this.nhplId,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'medication_id': medicationId,
      'medication_name': medicationName,
      'dosage': dosage,
      'route': route,
      'type': type.name,
      'rxnorm_id': rxnormId,
      'nhpl_id': nhplId,
      'notes': notes,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      userId: map['user_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      medicationId: map['medication_id'],
      medicationName: map['medication_name'],
      dosage: map['dosage'],
      route: map['route'] ?? 'oral', // default to oral for backwards compatibility
      type: MedicationType.values.byName(map['type']),
      rxnormId: map['rxnorm_id'],
      nhplId: map['nhpl_id'],
      notes: map['notes'] ?? '',
    );
  }
}

enum MedicationType {
  prescription,
  natural,
  custom,
  medicineBox
}