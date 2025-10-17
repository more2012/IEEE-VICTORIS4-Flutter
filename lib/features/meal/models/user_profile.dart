// User Profile Data Model
class UserProfile {
  final int age;
  final String gender;
  final double weight;
  final double height;
  final List<String> healthConditions;

  UserProfile({
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.healthConditions,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'healthConditions': healthConditions,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'],
      gender: json['gender'],
      weight: json['weight'],
      height: json['height'],
      healthConditions: List<String>.from(json['healthConditions']),
    );
  }

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // BMI Category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
class NutritionAdvice {
  final List<String> dos;
  final List<String> donts;

  NutritionAdvice({
    required this.dos,
    required this.donts,
  });
}
