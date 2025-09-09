class Medication {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final String type;
  final int timesPerDay;
  final int durationInDays;
  final DateTime startDate;
  final Map<String, bool> doseTaken; // ✅ FIXED: Now tracks individual doses
  final bool isTaken; // For backwards compatibility only
  final DateTime? nextDoseTime;
  final String frequency;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.type = 'Tablet',
    this.timesPerDay = 1,
    this.durationInDays = 7,
    DateTime? startDate,
    Map<String, bool>? doseTaken, // ✅ FIXED: Individual dose tracking
    this.isTaken = false,
    this.nextDoseTime,
    this.frequency = 'Daily',
  }) :
        startDate = startDate ?? DateTime.now(),
        doseTaken = doseTaken ?? {};

  // ✅ FIXED: Check if medication is completely finished (all days, all doses)
  bool get isCompletelyFinished {
    final totalDosesRequired = durationInDays * timesPerDay;
    final dosesCompleted = doseTaken.values.where((taken) => taken).length;
    return dosesCompleted >= totalDosesRequired;
  }

  // ✅ FIXED: Check if specific dose for specific date is taken
  bool isDoseTakenForDate(DateTime date, int doseNumber) {
    final doseKey = _formatDoseKey(date, doseNumber);
    return doseTaken[doseKey] ?? false;
  }

  // ✅ NEW: Check if ALL doses for a specific date are taken
  bool areAllDosesTakenForDate(DateTime date) {
    for (int dose = 1; dose <= timesPerDay; dose++) {
      if (!isDoseTakenForDate(date, dose)) {
        return false;
      }
    }
    return true;
  }

  // ✅ NEW: Get completion percentage
  double get completionPercentage {
    final totalDoses = durationInDays * timesPerDay;
    if (totalDoses == 0) return 0.0;
    final completedDoses = doseTaken.values.where((taken) => taken).length;
    return (completedDoses / totalDoses).clamp(0.0, 1.0);
  }

  // ✅ FIXED: Check if date is within medication period
  bool isActiveOnDate(DateTime date) {
    final endDate = startDate.add(Duration(days: durationInDays));
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return !dateOnly.isBefore(startOnly) && dateOnly.isBefore(endOnly);
  }

  // ✅ NEW: Get remaining days
  int get remainingDays {
    final today = DateTime.now();
    final endDate = startDate.add(Duration(days: durationInDays));
    final remaining = endDate.difference(today).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  // ✅ NEW: Get days completed (all doses taken)
  int get daysCompleted {
    int completedDays = 0;
    for (int day = 0; day < durationInDays; day++) {
      final checkDate = startDate.add(Duration(days: day));
      if (areAllDosesTakenForDate(checkDate)) {
        completedDays++;
      }
    }
    return completedDays;
  }

  // ✅ FIXED: Create unique key for each dose
  static String _formatDoseKey(DateTime date, int doseNumber) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$dateKey-dose-$doseNumber';
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? time,
    String? type,
    int? timesPerDay,
    int? durationInDays,
    DateTime? startDate,
    Map<String, bool>? doseTaken, // ✅ FIXED
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
      durationInDays: durationInDays ?? this.durationInDays,
      startDate: startDate ?? this.startDate,
      doseTaken: doseTaken ?? Map.from(this.doseTaken), // ✅ FIXED
      isTaken: isTaken ?? this.isTaken,
      nextDoseTime: nextDoseTime ?? this.nextDoseTime,
      frequency: frequency ?? this.frequency,
    );
  }

  // ✅ FIXED: Mark specific dose taken for specific date
  Medication markDoseTaken(DateTime date, int doseNumber, bool taken) {
    final doseKey = _formatDoseKey(date, doseNumber);
    final newDoseTaken = Map<String, bool>.from(doseTaken);
    newDoseTaken[doseKey] = taken;

    return copyWith(
      doseTaken: newDoseTaken,
      isTaken: taken, // Keep for backward compatibility
    );
  }

  // ✅ NEW: Get status text for UI
  String getStatusText() {
    if (isCompletelyFinished) {
      return 'Completed ($daysCompleted/$durationInDays days)';
    } else if (remainingDays <= 0) {
      return 'Expired';
    } else {
      return 'Active ($daysCompleted/$durationInDays days)';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': time,
      'type': type,
      'timesPerDay': timesPerDay,
      'durationInDays': durationInDays,
      'startDate': startDate.toIso8601String(),
      'doseTaken': doseTaken, // ✅ FIXED
      'isTaken': isTaken,
      'nextDoseTime': nextDoseTime?.toIso8601String(),
      'frequency': frequency,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? 'Tablet',
      timesPerDay: json['timesPerDay'] ?? 1,
      durationInDays: json['durationInDays'] ?? 7,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      doseTaken: Map<String, bool>.from(json['doseTaken'] ?? {}), // ✅ FIXED
      isTaken: json['isTaken'] ?? false,
      nextDoseTime: json['nextDoseTime'] != null
          ? DateTime.parse(json['nextDoseTime'])
          : null,
      frequency: json['frequency'] ?? 'Daily',
    );
  }
}
