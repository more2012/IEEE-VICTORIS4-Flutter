class Medication {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final String type; // New: Type of medicine
  final int timesPerDay; // New: Times per day
  final bool isTaken;
  final DateTime? nextDoseTime;
  final String frequency;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.type = 'Tablet', // New field
    this.timesPerDay = 1, // New field
    this.isTaken = false,
    this.nextDoseTime,
    this.frequency = 'Daily',
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? time,
    String? type,
    int? timesPerDay,
    bool? isTaken,
    DateTime? nextDoseTime,
    String? frequency,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      type: type ?? this.type,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      isTaken: isTaken ?? this.isTaken,
      nextDoseTime: nextDoseTime ?? this.nextDoseTime,
      frequency: frequency ?? this.frequency,
    );
  }
}
