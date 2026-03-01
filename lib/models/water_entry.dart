class WaterEntry {
  final String id;
  final double amountMl;
  final DateTime loggedAt;

  WaterEntry({required this.id, required this.amountMl, required this.loggedAt});

  Map<String, dynamic> toJson() => {
    'id': id, 'amountMl': amountMl, 'loggedAt': loggedAt.toIso8601String(),
  };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
    id: json['id'], amountMl: (json['amountMl'] as num).toDouble(),
    loggedAt: DateTime.parse(json['loggedAt']),
  );
}
