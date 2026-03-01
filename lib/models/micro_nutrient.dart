class MicroNutrient {
  final String name;
  final String unit;
  final double dailyTarget;
  double consumed;

  MicroNutrient({required this.name, required this.unit, required this.dailyTarget, this.consumed = 0});

  double get percentage => dailyTarget > 0 ? (consumed / dailyTarget * 100).clamp(0, 200) : 0;
  bool get isLow => percentage < 50;
  bool get isGood => percentage >= 80 && percentage <= 120;
  bool get isExcess => percentage > 150;

  Map<String, dynamic> toJson() => {'name': name, 'unit': unit, 'dailyTarget': dailyTarget, 'consumed': consumed};

  factory MicroNutrient.fromJson(Map<String, dynamic> j) => MicroNutrient(
    name: j['name'], unit: j['unit'],
    dailyTarget: (j['dailyTarget'] as num).toDouble(),
    consumed: (j['consumed'] as num?)?.toDouble() ?? 0,
  );
}

class MicroNutrientDefaults {
  static List<MicroNutrient> getDefaults() => [
    MicroNutrient(name: 'Fiber', unit: 'g', dailyTarget: 25),
    MicroNutrient(name: 'Sugar', unit: 'g', dailyTarget: 50),
    MicroNutrient(name: 'Sodium', unit: 'mg', dailyTarget: 2300),
    MicroNutrient(name: 'Vitamin C', unit: 'mg', dailyTarget: 90),
    MicroNutrient(name: 'Calcium', unit: 'mg', dailyTarget: 1000),
    MicroNutrient(name: 'Iron', unit: 'mg', dailyTarget: 18),
    MicroNutrient(name: 'Potassium', unit: 'mg', dailyTarget: 2600),
    MicroNutrient(name: 'Vitamin D', unit: 'mcg', dailyTarget: 15),
    MicroNutrient(name: 'Vitamin B12', unit: 'mcg', dailyTarget: 2.4),
    MicroNutrient(name: 'Zinc', unit: 'mg', dailyTarget: 11),
  ];
}
