part of 'reading_day_bloc.dart';

enum ReadingDayStatus {
  initial,
  loading,
  success,
  failure,
  deleteRequested,
  deleteSuccess,
  deleteCancelled
}

class ReadingDayState extends Equatable {
  const ReadingDayState(
      {this.status = ReadingDayStatus.initial,
      this.readings = const [],
      this.readingToDelete,
      this.errorMessage = ''});

  final ReadingDayStatus status;
  final List<PeakFlowReading> readings;
  final PeakFlowReading? readingToDelete;
  final String errorMessage;

  ReadingDayState copyWith({
    ReadingDayStatus Function()? status,
    DateTime Function()? date,
    List<PeakFlowReading> Function()? readings,
    PeakFlowReading? Function()? readingToDelete,
    String Function()? errorMessage,
  }) {
    return ReadingDayState(
        status: status != null ? status() : this.status,
        readings: readings != null ? readings() : this.readings,
        readingToDelete:
            readingToDelete != null ? readingToDelete() : this.readingToDelete,
        errorMessage:
            errorMessage != null ? errorMessage() : this.errorMessage);
  }

  @override
  List<Object?> get props => [status, readings, readingToDelete];
}
