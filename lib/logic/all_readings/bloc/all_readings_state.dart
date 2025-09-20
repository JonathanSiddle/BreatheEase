part of 'all_readings_bloc.dart';

enum AllReadingsStatus { initial, loading, success, failure }

class AllReadingsState extends Equatable {
  const AllReadingsState(
      {this.status = AllReadingsStatus.initial, this.dayData = const []});

  final AllReadingsStatus status;
  final List<DayData> dayData;

  AllReadingsState copyWith({
    AllReadingsStatus Function()? status,
    List<DayData> Function()? dayData,
  }) {
    return AllReadingsState(
        status: status != null ? status() : this.status,
        dayData: dayData != null ? dayData() : this.dayData);
  }

  @override
  List<Object?> get props => [status, dayData];
}
