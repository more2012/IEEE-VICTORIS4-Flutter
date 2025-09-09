import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../../../services/notification_service.dart';

class MedicationController with ChangeNotifier {
  final List<Medication> _medications = [];
  int _nextId = 1; // Simple counter for IDs

  List<Medication> get medications => _medications;

  // Initialize notifications when controller is created
  MedicationController() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
  }

  // Generate a safe ID for notifications (within 32-bit integer range)
  String _generateSafeId() {
    final id = _nextId;
    _nextId++;
    return id.toString();
  }

  // Add medication with notifications
  Future<void> addMedication(Medication medication) async {
    // Create medication with safe ID
    final safeId = _generateSafeId();
    final medicationWithSafeId = medication.copyWith(id: safeId);

    _medications.add(medicationWithSafeId);

    // Schedule notifications for this medication
    await NotificationService.scheduleMedicationNotifications(
      medicationWithSafeId,
    );

    notifyListeners();

    print(
      '✅ Added medication: ${medicationWithSafeId.name} with ID: $safeId and ${medicationWithSafeId.timesPerDay} daily notifications',
    );
  }

  // Remove medication and cancel notifications
  Future<void> removeMedication(String id) async {
    // Cancel notifications first
    await NotificationService.cancelMedicationNotifications(id);

    // Remove from list
    _medications.removeWhere((med) => med.id == id);
    notifyListeners();

    print('🗑️ Removed medication and cancelled notifications for ID: $id');
  }

  // Toggle medication taken status
  void toggleMedicationTaken(String id) {
    final index = _medications.indexWhere((med) => med.id == id);
    if (index != -1) {
      _medications[index] = _medications[index].copyWith(
        isTaken: !_medications[index].isTaken,
      );
      notifyListeners();
    }
  }

  // Get upcoming medications for homepage
  List<Medication> getUpcomingMedications() {
    return _medications.take(3).toList();
  }

  // Get today's medications
  List<Medication> getTodayMedications() {
    return _medications
        .where((med) => med.nextDoseTime?.day == DateTime.now().day)
        .toList();
  }

  // Get medications by specific date (matches day, month, year)
  List<Medication> getMedicationsByDate(DateTime date) {
    return _medications.where((medication) {
      final dt = medication.nextDoseTime;
      if (dt == null) return false;
      return dt.year == date.year &&
          dt.month == date.month &&
          dt.day == date.day;
    }).toList();
  }

  // Test notification for a medication
  Future<void> testNotification(String medicationId) async {
    final medication = _medications.firstWhere((med) => med.id == medicationId);
    await NotificationService.showImmediateNotification(medication);
  }
}
