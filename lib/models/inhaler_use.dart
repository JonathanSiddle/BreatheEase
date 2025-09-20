import 'package:equatable/equatable.dart';

class InhalerUse extends Equatable {
  const InhalerUse({required this.id, required this.date});

  final String id;
  final DateTime date;

  @override
  List<Object?> get props => [id, date];
}

extension InhalerUseSqliteExtensions on InhalerUse {
  // Custom factory method for deserializing from SQLite JSON
  static InhalerUse fromSqliteJson(Map<String, dynamic> json) {
    final timestamp = json['date'] as int;
    return InhalerUse(
      id: json['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
    );
  }

  Map<String, dynamic> toSqliteJson() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
