part of 'add_peak_flow_reading_bloc.dart';

enum AddPeakFlowReadingStatus { initial, readingUpdated, save, saving, success, failure }

final class AddPeakFlowReadingState extends Equatable {
  const AddPeakFlowReadingState(
      {this.status = AddPeakFlowReadingStatus.initial,
      this.currentReading = 400});

  final AddPeakFlowReadingStatus status;
  final int currentReading;

  AddPeakFlowReadingState copyWith(
      {AddPeakFlowReadingStatus Function()? status, int Function()? currentReading}) {
    return AddPeakFlowReadingState(
        status: status != null ? status() : this.status,
        currentReading: currentReading != null ? currentReading() : this.currentReading);
  }

  @override
  List<Object?> get props => [status, currentReading];
}
