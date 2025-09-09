import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../../../services/notification_service.dart';

class MedicationController with ChangeNotifier {
  final List<Medication> _medications = [];
  int _nextId = 1;

  List<Medication> get medications => _medications;

  MedicationController() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
  }

  String _generateSafeId() {
    final id = _nextId;
    _nextId++;
    return id.toString();
  }

  Future<void> addMedication(Medication medication) async {
    final safeId = _generateSafeId();
    final now = DateTime.now();

    final medicationWithSafeId = medication.copyWith(
      id: safeId,
      startDate: DateTime(now.year, now.month, now.day),
    );

    _medications.add(medicationWithSafeId);
    await NotificationService.scheduleMedicationNotifications(medicationWithSafeId);
    notifyListeners();

    print('✅ Added medication: ${medicationWithSafeId.name} for ${medicationWithSafeId.durationInDays} days');
  }

  Future<void> removeMedication(String id) async {
    await NotificationService.cancelMedicationNotifications(id);
    _medications.removeWhere((med) => med.id == id);
    notifyListeners();
    print('🗑️ Removed medication for ID: $id');
  }

  // ✅ FIXED: Toggle specific dose for specific date
  void toggleMedicationDose(String id, DateTime date, int doseNumber) {
    final index = _medications.indexWhere((med) => med.id == id);

    if (index != -1) {
      final medication = _medications[index];
      final currentStatus = medication.isDoseTakenForDate(date, doseNumber);

      // ✅ FIXED: Only mark this specific dose, not other doses
      _medications[index] = medication.markDoseTaken(date, doseNumber, !currentStatus);
      notifyListeners();

      final dateStr = "${date.day}/${date.month}/${date.year}";
      print('${!currentStatus ? '✅' : '❌'} ${medication.name} dose $doseNumber ${!currentStatus ? 'taken' : 'not taken'} on $dateStr');
    }
  }

  // ✅ LEGACY: Keep old method for backwards compatibility
  void toggleMedicationTaken(String id, [DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    toggleMedicationDose(id, targetDate, 1); // Default to dose 1
  }

  List<Medication> getUpcomingMedications() {
    return _medications.take(3).toList();
  }

  List<Medication> getTodayMedications() {
    final today = DateTime.now();
    return _medications.where((med) => med.isActiveOnDate(today)).toList();
  }

  // ✅ UPDATED: Get medication doses for specific date
  List<MedicationDose> getMedicationsByDate(DateTime date) {
    final List<MedicationDose> doses = [];

    for (final medication in _medications) {
      if (medication.isActiveOnDate(date)) {
        // ✅ FIXED: Create separate dose objects for each daily dose
        for (int dose = 1; dose <= medication.timesPerDay; dose++) {
          doses.add(MedicationDose(
            medication: medication,
            doseNumber: dose,
            date: date,
          ));
        }
      }
    }

    return doses;
  }

  List<Medication> getActiveMedications() {
    return _medications.where((med) => !med.isCompletelyFinished && med.remainingDays > 0).toList();
  }

  List<Medication> getCompletedMedications() {
    return _medications.where((med) => med.isCompletelyFinished).toList();
  }

  Future<void> testNotification(String medicationId) async {
    final medication = _medications.firstWhere((med) => med.id == medicationId);
    await NotificationService.showImmediateNotification(medication);
  }
}

// ✅ UPDATED: Helper class for individual doses
class MedicationDose {
  final Medication medication;
  final int doseNumber;
  final DateTime date;

  MedicationDose({
    required this.medication,
    required this.doseNumber,
    required this.date,
  });

  String get doseLabel {
    if (medication.timesPerDay == 1) {
      return medication.time;
    } else {
      // Generate different times for multiple doses
      switch (doseNumber) {
        case 1:
          return '8:00 AM';
        case 2:
          return medication.timesPerDay == 2 ? '8:00 PM' : '2:00 PM';
        case 3:
          return '8:00 PM';
        case 4:
          return '11:00 PM';
        case 5:
          return '6:00 AM';
        case 6:
          return '12:00 PM';
        default:
          return medication.time;
      }
    }
  }

  String get doseDescription {
    if (medication.timesPerDay == 1) {
      return '';
    } else {
      switch (doseNumber) {
        case 1:
          return 'Morning dose';
        case 2:
          return medication.timesPerDay == 2 ? 'Evening dose' : 'Afternoon dose';
        case 3:
          return 'Evening dose';
        case 4:
          return 'Night dose';
        case 5:
          return 'Early morning dose';
        case 6:
          return 'Noon dose';
        default:
          return 'Dose $doseNumber';
      }
    }
  }

  // ✅ FIXED: Check individual dose status
  bool get isTaken {
    return medication.isDoseTakenForDate(date, doseNumber);
  }
}
