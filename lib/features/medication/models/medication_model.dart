import 'dart:convert';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final String type;
  final int timesPerDay;
  final int durationInDays;
  final DateTime startDate;
  final Map<String, bool> doseTaken;
  final bool isTaken;
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
    Map<String, bool>? doseTaken,
    this.isTaken = false,
    this.nextDoseTime,
    this.frequency = 'Daily',
  }) :
        startDate = startDate ?? DateTime.now(),
        doseTaken = doseTaken ?? {};

  bool get isCompletelyFinished {
    final totalDosesRequired = durationInDays * timesPerDay;
    final dosesCompleted = doseTaken.values.where((taken) => taken).length;
    return dosesCompleted >= totalDosesRequired;
  }

  bool isDoseTakenForDate(DateTime date, int doseNumber) {
    final doseKey = _formatDoseKey(date, doseNumber);
    return doseTaken[doseKey] ?? false;
  }

  bool areAllDosesTakenForDate(DateTime date) {
    for (int dose = 1; dose <= timesPerDay; dose++) {
      if (!isDoseTakenForDate(date, dose)) {
        return false;
      }
    }
    return true;
  }

  double get completionPercentage {
    final totalDoses = durationInDays * timesPerDay;
    if (totalDoses == 0) return 0.0;
    final completedDoses = doseTaken.values.where((taken) => taken).length;
    return (completedDoses / totalDoses).clamp(0.0, 1.0);
  }

  bool isActiveOnDate(DateTime date) {
    final endDate = startDate.add(Duration(days: durationInDays));
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return !dateOnly.isBefore(startOnly) && dateOnly.isBefore(endOnly);
  }

  int get remainingDays {
    final today = DateTime.now();
    final endDate = startDate.add(Duration(days: durationInDays));
    final remaining = endDate.difference(today).inDays;
    return remaining < 0 ? 0 : remaining;
  }

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
    Map<String, bool>? doseTaken,
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
      doseTaken: doseTaken ?? Map.from(this.doseTaken),
      isTaken: isTaken ?? this.isTaken,
      nextDoseTime: nextDoseTime ?? this.nextDoseTime,
      frequency: frequency ?? this.frequency,
    );
  }

  Medication markDoseTaken(DateTime date, int doseNumber, bool taken) {
    final doseKey = _formatDoseKey(date, doseNumber);
    final newDoseTaken = Map<String, bool>.from(doseTaken);
    newDoseTaken[doseKey] = taken;

    return copyWith(
      doseTaken: newDoseTaken,
      isTaken: taken,
    );
  }

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
      'id': int.tryParse(id),
      'name': name,
      'dosage': dosage,
      'time': '$time:00',
      'type': type,
      'times_per_day': timesPerDay,
      'duration_in_days': durationInDays,
      'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'dose_taken': doseTaken,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      time: (json['time'] as String?)?.substring(0, 5) ?? '',
      type: json['type'] ?? 'Tablet',
      timesPerDay: json['times_per_day'] ?? 1,
      durationInDays: json['duration_in_days'] ?? 7,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      doseTaken: Map<String, bool>.from(json['dose_taken'] ?? {}),
      isTaken: json['is_taken'] ?? false,
    );
  }
}