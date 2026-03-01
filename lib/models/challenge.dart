class Challenge {
  final String id;
  final String title;
  final String description;
  final String type; // calories, water, streak, protein
  final double targetValue;
  final int durationDays;
  final DateTime startDate;
  double currentValue;
  bool isCompleted;

  Challenge({
    required this.id, required this.title, required this.description,
    required this.type, required this.targetValue, required this.durationDays,
    required this.startDate, this.currentValue = 0, this.isCompleted = false,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0, 1) : 0;
  int get daysLeft => durationDays - DateTime.now().difference(startDate).inDays;
  bool get isExpired => daysLeft <= 0;

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'type': type, 'targetValue': targetValue, 'durationDays': durationDays,
    'startDate': startDate.toIso8601String(), 'currentValue': currentValue,
    'isCompleted': isCompleted,
  };

  factory Challenge.fromJson(Map<String, dynamic> j) => Challenge(
    id: j['id'], title: j['title'], description: j['description'],
    type: j['type'], targetValue: (j['targetValue'] as num).toDouble(),
    durationDays: j['durationDays'], startDate: DateTime.parse(j['startDate']),
    currentValue: (j['currentValue'] as num?)?.toDouble() ?? 0,
    isCompleted: j['isCompleted'] ?? false,
  );
}

class ChallengeTemplates {
  static List<Challenge> getDefaults() {
    final now = DateTime.now();
    return [
      Challenge(id: 'c1', title: '7-Day Calorie Champion', description: 'Stay within your calorie target for 7 consecutive days',
        type: 'streak', targetValue: 7, durationDays: 7, startDate: now),
      Challenge(id: 'c2', title: 'Hydration Hero', description: 'Drink your daily water target for 5 days',
        type: 'water', targetValue: 5, durationDays: 7, startDate: now),
      Challenge(id: 'c3', title: 'Protein Power', description: 'Hit your protein target for 7 days',
        type: 'protein', targetValue: 7, durationDays: 10, startDate: now),
      Challenge(id: 'c4', title: 'Meal Logger', description: 'Log at least 3 meals every day for a week',
        type: 'streak', targetValue: 7, durationDays: 7, startDate: now),
      Challenge(id: 'c5', title: 'No Junk Week', description: 'Keep daily calories under target for 7 days straight',
        type: 'calories', targetValue: 7, durationDays: 7, startDate: now),
      Challenge(id: 'c6', title: '30-Day Transform', description: 'Log meals consistently for 30 days',
        type: 'streak', targetValue: 30, durationDays: 30, startDate: now),
    ];
  }
}
