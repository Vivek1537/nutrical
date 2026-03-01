class UserProfile {
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double? targetWeightKg;
  final String activityLevel;
  final String goal;
  final double dailyCalorieTarget;
  final double proteinTarget;
  final double carbsTarget;
  final double fatTarget;
  final double waterTargetMl;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.targetWeightKg,
    required this.activityLevel,
    required this.goal,
    required this.dailyCalorieTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.waterTargetMl,
  });

  Map<String, dynamic> toJson() => {
    'name': name, 'age': age, 'gender': gender, 'heightCm': heightCm,
    'weightKg': weightKg, 'targetWeightKg': targetWeightKg,
    'activityLevel': activityLevel, 'goal': goal,
    'dailyCalorieTarget': dailyCalorieTarget, 'proteinTarget': proteinTarget,
    'carbsTarget': carbsTarget, 'fatTarget': fatTarget, 'waterTargetMl': waterTargetMl,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'], age: json['age'], gender: json['gender'],
    heightCm: (json['heightCm'] as num).toDouble(),
    weightKg: (json['weightKg'] as num).toDouble(),
    targetWeightKg: json['targetWeightKg'] != null ? (json['targetWeightKg'] as num).toDouble() : null,
    activityLevel: json['activityLevel'], goal: json['goal'],
    dailyCalorieTarget: (json['dailyCalorieTarget'] as num).toDouble(),
    proteinTarget: (json['proteinTarget'] as num).toDouble(),
    carbsTarget: (json['carbsTarget'] as num).toDouble(),
    fatTarget: (json['fatTarget'] as num).toDouble(),
    waterTargetMl: (json['waterTargetMl'] as num).toDouble(),
  );
}
