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

  void toggleMedicationDose(String id, DateTime date, int doseNumber) {
    final index = _medications.indexWhere((med) => med.id == id);

    if (index != -1) {
      final medication = _medications[index];
      final currentStatus = medication.isDoseTakenForDate(date, doseNumber);

      _medications[index] = medication.markDoseTaken(date, doseNumber, !currentStatus);
      notifyListeners();

      final dateStr = "${date.day}/${date.month}/${date.year}";
      print('${!currentStatus ? '✅' : '❌'} ${medication.name} dose $doseNumber ${!currentStatus ? 'taken' : 'not taken'} on $dateStr');
    }
  }

  void toggleMedicationTaken(String id, [DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    toggleMedicationDose(id, targetDate, 1);
  }

  List<Medication> getUpcomingMedications() {
    return _medications.take(3).toList();
  }

  List<Medication> getTodayMedications() {
    final today = DateTime.now();
    return _medications.where((med) => med.isActiveOnDate(today)).toList();
  }

  List<MedicationDose> getMedicationsByDate(DateTime date) {
    final List<MedicationDose> doses = [];

    for (final medication in _medications) {
      if (medication.isActiveOnDate(date)) {
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
    final baseTime = NotificationTimeUtil.parseTimeString(medication.time);
    final calculatedTime = NotificationTimeUtil.getDoseTime(baseTime, doseNumber, medication.timesPerDay);

    return calculatedTime.hour.toString().padLeft(2, '0') + ':' + calculatedTime.minute.toString().padLeft(2, '0');
  }

  String get doseDescription {
    if (medication.timesPerDay == 1) {
      return '';
    }
    return NotificationTimeUtil.getDoseDescription(doseNumber, medication.timesPerDay);
  }

  bool get isTaken {
    return medication.isDoseTakenForDate(date, doseNumber);
  }
}