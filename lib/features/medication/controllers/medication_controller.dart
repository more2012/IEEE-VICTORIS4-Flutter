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

    // ✅ FIXED: Set nextDoseTime to selected date instead of current time + 1 hour
    final now = DateTime.now();
    final medicationWithSafeId = medication.copyWith(
      id: safeId,
      nextDoseTime: DateTime(now.year, now.month, now.day), // Today's date
    );

    _medications.add(medicationWithSafeId);

    await NotificationService.scheduleMedicationNotifications(medicationWithSafeId);

    notifyListeners();

    print('✅ Added medication: ${medicationWithSafeId.name} with ID: $safeId and ${medicationWithSafeId.timesPerDay} daily notifications');
  }

  Future<void> removeMedication(String id) async {
    await NotificationService.cancelMedicationNotifications(id);

    _medications.removeWhere((med) => med.id == id);
    notifyListeners();

    print('🗑️ Removed medication and cancelled notifications for ID: $id');
  }

  void toggleMedicationTaken(String id) {
    final index = _medications.indexWhere((med) => med.id == id);
    if (index != -1) {
      _medications[index] = _medications[index].copyWith(
        isTaken: !_medications[index].isTaken,
      );
      notifyListeners();
    }
  }

  List<Medication> getUpcomingMedications() {
    return _medications.take(3).toList();
  }

  List<Medication> getTodayMedications() {
    return _medications
        .where((med) => med.nextDoseTime?.day == DateTime.now().day)
        .toList();
  }

  // ✅ FIXED: Better date filtering that properly matches dates
  List<Medication> getMedicationsByDate(DateTime date) {
    return _medications.where((medication) {
      final dt = medication.nextDoseTime;
      if (dt == null) return false;

      // Compare year, month, and day only (ignore time)
      return dt.year == date.year &&
          dt.month == date.month &&
          dt.day == date.day;
    }).toList();
  }

  Future<void> testNotification(String medicationId) async {
    final medication = _medications.firstWhere((med) => med.id == medicationId);
    await NotificationService.showImmediateNotification(medication);
  }
}
