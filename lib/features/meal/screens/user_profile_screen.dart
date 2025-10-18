import 'package:awan/features/meal/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/user_profile.dart';
import '../services/google_nutrition_service.dart';
import 'breakfast_screen.dart';
import 'lunch_screen.dart';
import 'dinner_screen.dart';
import 'snacks_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedGender = 'Male';
  final List<String> _selectedHealthConditions = [];
  bool _isLoading = false;

  final List<String> _healthConditions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'Kidney Disease',
    'Thyroid Disorder',
    'High Cholesterol',
    'Other'
  ];

  final Color _teal = const Color(0xff0284C7);
  final Color _scaffoldGray = const Color(0xFFF3F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldGray,
      appBar: AppBar(
        backgroundColor: _teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nutrition Assistant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      // Wrapped in SingleChildScrollView for responsive layout
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // White card with title and the four inputs (Age/Gender / Weight/Height)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tell us about Yourself',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Fill in your health information',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 18),

                          // Age & Gender
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Age',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(hint: '35'),
                                      style: const TextStyle(fontSize: 15),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Required';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Gender',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedGender,
                                      decoration: _inputDecoration(),
                                      items: ['Male', 'Female']
                                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                          .toList(),
                                      onChanged: (v) {
                                        setState(() => _selectedGender = v!);
                                      },
                                      isDense: true,
                                      style: const TextStyle(color: Colors.black, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Weight & Height
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Weight(kg)',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _weightController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(hint: '80'),
                                      style: const TextStyle(fontSize: 15),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Required';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Height(cm)',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _heightController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(hint: '190'),
                                      style: const TextStyle(fontSize: 15),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Required';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Health Conditions',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _teal, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SizedBox(
                          height: 180, // Reduced height for better responsiveness
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _healthConditions.length,
                              itemBuilder: (context, index) {
                                final condition = _healthConditions[index];
                                final selected = _selectedHealthConditions.contains(condition);
                                return CheckboxListTile(
                                  title: Text(
                                    condition,
                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                                  ),
                                  value: selected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!_selectedHealthConditions.contains(condition)) {
                                          _selectedHealthConditions.add(condition);
                                        }
                                      } else {
                                        _selectedHealthConditions.remove(condition);
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                  activeColor: _teal,
                                  contentPadding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Spacer to push button toward bottom but not inside previous containers
                  const SizedBox(height: 22),

                  // The Generate button is OUTSIDE the white cards and in its own container
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateNutritionPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        'Generate Nutrition Plan',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint ?? '',
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xff0284C7), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xff0284C7), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff0284C7), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Future<void> _generateNutritionPlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProfile = UserProfile(
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        healthConditions: _selectedHealthConditions,
      );

      final mealPlan = await GoogleNutritionService.getPersonalizedMealPlan(userProfile);

      setState(() {
        _isLoading = false;
      });

      // Navigate to meal plan screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MealPlanScreen(
            mealPlan: mealPlan,
            userProfile: userProfile,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
