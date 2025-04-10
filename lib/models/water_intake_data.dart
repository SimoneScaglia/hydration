class WaterIntakeData {
  final int id;
  final DateTime date;
  final DateTime createDateTime;

  WaterIntakeData({
    this.id = -1,
    required this.date,
    required this.createDateTime,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first,
      'createDateTime': createDateTime.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'WaterIntakeData(id: $id, date: $date, createDateTime: $createDateTime)';
  }

  factory WaterIntakeData.fromMap(Map<String, dynamic> map) {
    return WaterIntakeData(
      id: map['id'],
      date: DateTime.parse(map['date']),
      createDateTime: DateTime.parse(map['createDateTime']),
    );
  }
}
