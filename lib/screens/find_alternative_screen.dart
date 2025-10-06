import 'package:awan/shared/widgets/alternative_medicine_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alternative_medicine_model.dart';
import '../services/alternative_medicine_service.dart';

class FindAlternativeScreen extends StatefulWidget {
  const FindAlternativeScreen({Key? key}) : super(key: key);

  @override
  State<FindAlternativeScreen> createState() => _FindAlternativeScreenState();
}

class _FindAlternativeScreenState extends State<FindAlternativeScreen> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final AlternativeMedicineService _alternativeService = AlternativeMedicineService();

  List<AlternativeMedicine> _alternatives = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _findAlternatives() async {
    if (_medicineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a medicine name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final alternatives = await _alternativeService.getAlternatives(
        medicineName: _medicineNameController.text.trim(),
        dosage: _dosageController.text.trim(),
      );

      setState(() {
        _alternatives = alternatives;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _alternatives = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error finding alternatives: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D1D1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find Alternative',
          style: TextStyle(
            color: Color(0xFF1D1D1F),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            const Text(
              'Find Alternative Medicines',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the medicine details to find suitable alternatives',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 24),

            // Medicine Input Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _medicineNameController,
                    decoration: InputDecoration(
                      labelText: 'Medicine Name *',
                      hintText: 'e.g., Panadol, Aspirin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF007AFF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dosageController,
                    decoration: InputDecoration(
                      labelText: 'Dosage (Optional)',
                      hintText: 'e.g., 500mg, 10ml',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF007AFF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _findAlternatives,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Find Alternatives',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Results Section
            if (_hasSearched) ...[
              Text(
                _alternatives.isEmpty ? 'No Alternatives Found' : 'Alternative Medicines',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Alternatives List
            Expanded(
              child: _alternatives.isEmpty && _hasSearched && !_isLoading
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Color(0xFF8E8E93),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No alternatives found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try searching with a different medicine name',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _alternatives.length,
                itemBuilder: (context, index) {
                  final alternative = _alternatives[index];
                  return AlternativeMedicineCard(
                    alternative: alternative,
                    onAddPressed: () => _addAlternativeToMedicines(alternative),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addAlternativeToMedicines(AlternativeMedicine alternative) {
    // TODO: Implement adding alternative to user's medicine list
    // This would typically involve calling your medicine provider/service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${alternative.name} added to your medicines'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
