import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../../../services/notification_service.dart';
import '../../../services/api_service.dart';
import 'dart:async';

class MedicationController with ChangeNotifier {
  final List<Medication> _medications = [];
  final int _missedDoseThreshold = 2; // Threshold for missed doses

  List<Medication> get medications => _medications;
  Timer? _missedDoseTimer;

  MedicationController() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
    _startMissedDoseChecker();
  }

  void _startMissedDoseChecker() {
    _missedDoseTimer?.cancel();
    _missedDoseTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkMissedDosesAndAlert();
    });
  }

  Future<void> _checkMissedDosesAndAlert() async {
    print('🔎 Checking for missed doses...');
    final today = DateTime.now();

    for (final medication in _medications) {
      if (!medication.isCompletelyFinished && medication.isActiveOnDate(today)) {
        int missedDoses = 0;
        for (int i = 0; i < medication.durationInDays; i++) {
          final checkDate = today.subtract(Duration(days: i));
          if (!medication.areAllDosesTakenForDate(checkDate)) {
            missedDoses++;
          } else {
            break;
          }
        }

        if (missedDoses >= _missedDoseThreshold) {
          print('🚨 Missed dose alert triggered for ${medication.name}');
          await NotificationService.showMissedDoseNotification(medication, missedDoses);
        }
      }
    }
  }

  Future<void> fetchMedications() async {
    try {
      final response = await ApiService.get('/drugs/');
      final List<dynamic> medicationsJson = response as List<dynamic>;
      _medications.clear();
      _medications.addAll(medicationsJson.map((json) => Medication.fromJson(json)).toList());
      notifyListeners();
      print('✅ Fetched all medications from backend');
    } catch (e) {
      print('⚠️ Error fetching medications: $e');
    }
  }

  Future<Medication> addMedication(Medication medication) async {
    // Check for existing medication with the same name before adding
    final existingMedication = _medications.firstWhere(
          (m) => m.name.toLowerCase() == medication.name.toLowerCase(),
      orElse: () => Medication(id: '', name: '', dosage: '', time: ''), // Return a dummy object if not found
    );

    if (existingMedication.name.isNotEmpty) {
      // If a medication with the same name exists, return the existing one.
      // This prevents adding duplicates.
      return existingMedication;
    }

    try {
      final response = await ApiService.post('/drugs/', medication.toJson());
      final newMedication = Medication.fromJson(response);
      _medications.add(newMedication);
      await NotificationService.scheduleMedicationNotifications(newMedication);
      notifyListeners();
      print('✅ Added medication to backend: ${newMedication.name}');
      return newMedication;
    } catch (e) {
      print('⚠️ Error adding medication: $e');
      throw Exception('Failed to add medication');
    }
  }

  Future<void> removeMedication(String id) async {
    try {
      await ApiService.delete('/drugs/$id/');
      await NotificationService.cancelMedicationNotifications(id);
      _medications.removeWhere((med) => med.id == id);
      notifyListeners();
      print('🗑️ Removed medication from backend for ID: $id');
    } catch (e) {
      print('⚠️ Error removing medication: $e');
    }
  }

  Future<void> toggleMedicationDose(String id, DateTime date, int doseNumber) async {
    final index = _medications.indexWhere((med) => med.id == id);

    if (index != -1) {
      final medication = _medications[index];
      final currentStatus = medication.isDoseTakenForDate(date, doseNumber);
      final updatedMedication = medication.markDoseTaken(date, doseNumber, !currentStatus);

      try {
        await ApiService.put('/drugs/$id/', updatedMedication.toJson());
        _medications[index] = updatedMedication;
        notifyListeners();
        final dateStr = "${date.day}/${date.month}/${date.year}";
        print('${!currentStatus ? '✅' : '❌'} ${medication.name} dose $doseNumber ${!currentStatus ? 'taken' : 'not taken'} on $dateStr');
      } catch (e) {
        print('⚠️ Error updating medication status: $e');
      }
    }
  }

  void toggleMedicationTaken(String id, [DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    toggleMedicationDose(id, targetDate, 1);
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

    return '${calculatedTime.hour.toString().padLeft(2, '0')}:${calculatedTime.minute.toString().padLeft(2, '0')}';
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