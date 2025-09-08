import 'package:flutter/material.dart';
import '../models/medication_model.dart';

class MedicationController with ChangeNotifier {
  final List<Medication> _medications = [];

  List<Medication> get medications => _medications;

  // Add medication (synchronous version)
  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
    print('✅ Added medication: ${medication.name} with ${medication.timesPerDay} daily reminders');
  }

  // Remove medication
  void removeMedication(String id) {
    _medications.removeWhere((med) => med.id == id);
    notifyListeners();
    print('🗑️ Removed medication with ID: $id');
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
    return _medications.where((med) =>
    med.nextDoseTime?.day == DateTime.now().day
    ).toList();
  }
}
