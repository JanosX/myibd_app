class Symptom {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final Map<String, int> symptoms; // symptom name -> severity (1-5)
  final bool isFlare;
  final String notes;

  Symptom({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.symptoms,
    required this.isFlare,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'symptoms': symptoms,
      'is_flare': isFlare,
      'notes': notes,
    };
  }

  factory Symptom.fromMap(Map<String, dynamic> map) {
    return Symptom(
      id: map['id'],
      userId: map['user_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      symptoms: Map<String, int>.from(map['symptoms']),
      isFlare: map['is_flare'],
      notes: map['notes'] ?? '',
    );
  }
}

// Predefined symptom categories
class SymptomCategories {
  static const Map<String, List<String>> categories = {
    'Intestinal': [
      'Abdominal Pain',
      'Diarrhea',
      'Constipation',
      'Bloating',
      'Cramping',
      'Nausea',
      'Vomiting',
      'Rectal Bleeding',
      'Urgency',
      'Tenesmus',
    ],
    'Extra-intestinal': [
      'Joint Pain',
      'Eye Inflammation',
      'Skin Rashes',
      'Mouth Ulcers',
      'Fatigue',
      'Fever',
      'Night Sweats',
      'Weight Loss',
      'Loss of Appetite',
    ],
    'Mental Health': [
      'Anxiety',
      'Depression',
      'Brain Fog',
      'Irritability',
      'Insomnia',
    ],
  };
}