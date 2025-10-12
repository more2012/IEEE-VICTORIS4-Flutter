import 'package:flutter/material.dart';
import '../models/alternative_medicine_model.dart';
import '../services/alternative_medicine_service.dart';
import '../shared/widgets/alternative_medicine_card.dart';

class FindAlternativeScreen extends StatefulWidget {
  final String? initialSearchTerm;

  const FindAlternativeScreen({super.key, this.initialSearchTerm});

  @override
  State<FindAlternativeScreen> createState() => _FindAlternativeScreenState();
}

class _FindAlternativeScreenState extends State<FindAlternativeScreen> {
  final TextEditingController _medicineNameController = TextEditingController();
  final AlternativeMedicineService _alternativeService = AlternativeMedicineService();
  List<AlternativeMedicine> _alternatives = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchTerm != null && widget.initialSearchTerm!.isNotEmpty) {
      _medicineNameController.text = widget.initialSearchTerm!;
      Future.microtask(() => _findAlternatives());
    }
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
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
      print('🔍 Searching for alternatives: ${_medicineNameController.text.trim()}');

      final alternatives = await _alternativeService.findAlternatives(
        _medicineNameController.text.trim(),
      );

      setState(() {
        _alternatives = alternatives;
        _isLoading = false;
      });

      if (alternatives.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No alternatives found for "${_medicineNameController.text.trim()}"'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${alternatives.length} alternatives!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error finding alternatives: $e');
      setState(() {
        _isLoading = false;
        _alternatives = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error finding alternatives: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0284C7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find Alternative',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            color: const Color(0xFF0284C7),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _medicineNameController,
                    decoration: InputDecoration(
                      hintText: 'Medicine Name (e.g., Panadol, Aspirin)',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      suffixIcon: _medicineNameController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          _medicineNameController.clear();
                          setState(() {
                            _hasSearched = false;
                            _alternatives = [];
                          });
                        },
                      )
                          : Icon(Icons.mic, color: const Color(0xFF0284C7)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) => _findAlternatives(),
                    onChanged: (value) {
                      setState(() {}); // Refresh UI to show/hide clear button
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Search Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _findAlternatives,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E40AF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
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
          // Content Area
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_hasSearched) {
      // Initial state with image and instructions
      return Column(
        children: [
          const SizedBox(height: 40),
          // Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/find-alternative-image.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.medical_services,
                    size: 60,
                    color: Color(0xFF0284C7),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Instructions
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Type the name of your medicine to find available alternatives with the same active ingredient.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Feature Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildFeatureCard(
                  icon: Icons.search,
                  text: 'Search by medicine name',
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.check_circle,
                  text: 'Same active ingredients',
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.attach_money,
                  text: 'Compare prices',
                  color: const Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_isLoading) {
      // Loading state
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF0284C7)),
            ),
            SizedBox(height: 16),
            Text(
              'Searching for alternatives...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    } else if (_alternatives.isEmpty) {
      // No results state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No alternatives found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with "${_medicineNameController.text.trim()}" or a different medicine name',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasSearched = false;
                  _alternatives.clear();
                });
                _medicineNameController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Search Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      // Results state
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Alternative Medicines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_alternatives.length} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _alternatives.length,
              itemBuilder: (context, index) {
                final alternative = _alternatives[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AlternativeMedicineCard(
                    alternative: alternative,
                    onAddPressed: () => _addAlternativeToMedicines(alternative),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addAlternativeToMedicines(AlternativeMedicine alternative) {
    // TODO: Implement adding alternative to user's medicine list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${alternative.name} added to your medicines'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}