part of 'reading_day_bloc.dart';

final class ReadingDayEvent extends Equatable {
  const ReadingDayEvent();

  @override
  List<Object?> get props => [];
}

final class ReadingDaySubscriptionRequested extends ReadingDayEvent {
  const ReadingDaySubscriptionRequested();
}

final class ReadingDayDeleteReading extends ReadingDayEvent {
  const ReadingDayDeleteReading(this.readingToDelete);

  final PeakFlowReading readingToDelete;

  @override
  List<Object?> get props => [readingToDelete];
}

final class ReadingDayDeleteReadingConfirmed extends ReadingDayEvent {
  const ReadingDayDeleteReadingConfirmed();
}

final class ReadingDayDeleteReadingCancelled extends ReadingDayEvent {
  const ReadingDayDeleteReadingCancelled();
}
