class PeakFlowReading {
  const PeakFlowReading({
    required this.id,
    required this.date,
    required this.reading,
  });

  factory PeakFlowReading.fromJson(Map<String, dynamic> json) {
    return PeakFlowReading(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      reading: json['reading_value'] as int,
    );
  }

  final String id;
  final DateTime date;
  final int reading;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'reading_value': reading,
    };
  }

  PeakFlowReading copyWith({
    String? id,
    DateTime? date,
    int? reading,
  }) {
    return PeakFlowReading(
      id: id ?? this.id,
      date: date ?? this.date,
      reading: reading ?? this.reading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeakFlowReading &&
        other.id == id &&
        other.date == date &&
        other.reading == reading;
  }

  @override
  int get hashCode {
    return Object.hash(id, date, reading);
  }

  @override
  String toString() {
    return 'PeakFlowReading(id: $id, date: $date, reading: $reading)';
  }
}

extension PeakFlowReadingSqliteExtensions on PeakFlowReading {
  // Custom factory method for deserializing from SQLite JSON
  static PeakFlowReading fromSqliteJson(Map<String, dynamic> json) {
    final timestamp = json['date'] as int;
    return PeakFlowReading(
      id: json['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      reading: json['reading_value'] as int,
    );
  }

  Map<String, dynamic> toSqliteJson() {
    return {
      'id': id,
      'reading_value': reading,
      'date': date.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
