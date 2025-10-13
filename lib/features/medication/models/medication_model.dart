
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
  final List<dynamic>? severityCheck;

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
    this.severityCheck, // ADD THIS LINE
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
    List<dynamic>? severityCheck,
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
      severityCheck: severityCheck ?? this.severityCheck, // ADD THIS LINE
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
    final map = <String, dynamic>{
      'name': name,
      'dosage': dosage,
      'time': time.contains(':') ? '$time:00' : time,
      'type': type,
      'times_per_day': timesPerDay,
      'duration_in_days': durationInDays,
      'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'dose_taken': doseTaken,
    };
    final parsedId = int.tryParse(id);
    if (parsedId != null) {
      map['id'] = parsedId;
    }
    return map;
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    String pickString(dynamic value, [String fallback = '']) {
      if (value == null) return fallback;
      if (value is String) return value;
      return value.toString();
    }

    // Accept alternate field names from backend
    final rawId = json['id'] ?? json['pk'] ?? json['uuid'];
    final rawName = json['name'] ?? json['drug_name'] ?? json['title'];
    final rawDosage = json['dosage'] ?? json['dose'] ?? json['dosage_mg'];
    final rawTime = json['time'] ?? json['dose_time'] ?? '08:00:00';
    final rawType = json['type'] ?? json['form'] ?? 'Tablet';
    final rawTimesPerDay = json['times_per_day'] ?? json['timesPerDay'] ?? 1;
    final rawDuration = json['duration_in_days'] ?? json['duration'] ?? 7;
    final rawStartDate = json['start_date'] ?? json['startDate'];
    final rawDoseTaken = json['dose_taken'] ?? json['doseTaken'] ?? {};

    String parseTimeString(dynamic t) {
      final s = pickString(t, '08:00:00');
      if (s.length >= 5 && s.contains(':')) {
        return s.substring(0, 5);
      }
      return '08:00';
    }

    DateTime parseDate(dynamic d) {
      final s = pickString(d, '');
      if (s.isEmpty) return DateTime.now();
      try {
        return DateTime.parse(s);
      } catch (_) {
        return DateTime.now();
      }
    }

    Map<String, bool> coerceDoseTaken(dynamic raw) {
      final result = <String, bool>{};
      if (raw is Map) {
        raw.forEach((k, v) {
          if (v is bool) {
            result[pickString(k)] = v;
          } else if (v is num) {
            result[pickString(k)] = v != 0;
          } else if (v is String) {
            final lower = v.toLowerCase();
            result[pickString(k)] = lower == 'true' || lower == '1' || lower == 'yes';
          } else {
            result[pickString(k)] = false;
          }
        });
      }
      return result;
    }

    return Medication(
      id: pickString(rawId, ''),
      name: pickString(rawName, ''),
      dosage: pickString(rawDosage, ''),
      time: parseTimeString(rawTime),
      type: pickString(rawType, 'Tablet'),
      timesPerDay: (rawTimesPerDay is num) ? rawTimesPerDay.toInt() : int.tryParse(pickString(rawTimesPerDay, '1')) ?? 1,
      durationInDays: (rawDuration is num) ? rawDuration.toInt() : int.tryParse(pickString(rawDuration, '7')) ?? 7,
      startDate: parseDate(rawStartDate),
      doseTaken: coerceDoseTaken(rawDoseTaken),
      isTaken: (json['is_taken'] is bool) ? json['is_taken'] as bool : false,
      severityCheck: json['severity_check'],
    );
  }
}