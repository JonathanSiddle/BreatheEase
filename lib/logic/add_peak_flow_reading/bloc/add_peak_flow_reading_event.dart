part of 'add_peak_flow_reading_bloc.dart';

final class AddPeakFlowReadingEvent extends Equatable {
  const AddPeakFlowReadingEvent();

  @override
  List<Object?> get props => [];
}

final class AddPeakFlowReadingSuccess extends AddPeakFlowReadingEvent {
  const AddPeakFlowReadingSuccess();
}

final class AddPeakFlowReadingUpdated extends AddPeakFlowReadingEvent {
  const AddPeakFlowReadingUpdated(this.reading);

  final int reading;

  @override
  List<Object?> get props => [reading];
}

final class AddPeakFlowReadingSave extends AddPeakFlowReadingEvent {
  const AddPeakFlowReadingSave(this.reading);

  final int reading;

  @override
  List<Object?> get props => [reading];
}

final class IncreasePeakFlowValue extends AddPeakFlowReadingEvent {
  const IncreasePeakFlowValue(this.value);

  final int value;

  @override
  List<Object?> get props => [value];
}

final class DecreasePeakFlowValue extends AddPeakFlowReadingEvent {
  const DecreasePeakFlowValue(this.value);

  final int value;

  @override
  List<Object?> get props => [value];
}
