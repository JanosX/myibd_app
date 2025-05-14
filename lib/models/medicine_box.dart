class MedicineBox {
  final String? id;
  final String userId;
  final String name;
  final String? rxnormId;
  final String? nhplId;
  final bool isPrescription;
  final bool isNatural;
  final String defaultDosage;
  final String notes;
  final DateTime createdAt;
  final String defaultRoute;

MedicineBox({
    this.id,
    required this.userId,
    required this.name,
    this.rxnormId,
    this.nhplId,
    required this.isPrescription,
    required this.isNatural,
    required this.defaultDosage,
    required this.defaultRoute,
    this.notes = '',
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'rxnorm_id': rxnormId,
      'nhpl_id': nhplId,
      'is_prescription': isPrescription,
      'is_natural': isNatural,
      'default_dosage': defaultDosage,
      'default_route': defaultRoute,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
factory MedicineBox.fromMap(Map<String, dynamic> map) {
    return MedicineBox(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      rxnormId: map['rxnorm_id'],
      nhplId: map['nhpl_id'],
      isPrescription: map['is_prescription'],
      isNatural: map['is_natural'],
      defaultDosage: map['default_dosage'],
      defaultRoute: map['default_route'] ?? 'oral',
      notes: map['notes'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}