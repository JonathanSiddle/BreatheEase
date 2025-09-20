class DateTimeRepository {
  DateTimeRepository({DateTime Function()? dateProvider})
      : _dateProvider = dateProvider ?? (() => DateTime.now());

  final DateTime Function() _dateProvider;
  DateTime get now => _dateProvider();
}
