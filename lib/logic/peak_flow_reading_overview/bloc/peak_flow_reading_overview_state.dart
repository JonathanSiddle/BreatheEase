part of 'peak_flow_reading_overview_bloc.dart';

enum PeakFlowReadingOverviewStatus {
  initial,
  loading,
  success,
  incrementingRelieverUse,
  incrementRelieverUseSuccess,
  incrementRelieverUseFailure,
  incrementingPreventerUse,
  incrementPreventerUseSuccess,
  incrementPreventerUseFailure,
  failure,
  logoutRequested,
  deleteRequested,
  deleteSuccess,
  deleteCancelled,
  processingReadings,
  showAllReadingsPage,
}

final class PeakFlowReadingOverviewState extends Equatable {
  const PeakFlowReadingOverviewState(
      {this.status = PeakFlowReadingOverviewStatus.initial,
      this.showMoreButton = false,
      this.dayData = const [],
      this.readingToDelete});

  final PeakFlowReadingOverviewStatus status;
  final List<DayData> dayData;
  final PeakFlowReading? readingToDelete;
  //should only show if more than 7 days of readings
  final bool showMoreButton;

  PeakFlowReadingOverviewState copyWith({
    PeakFlowReadingOverviewStatus Function()? status,
    bool Function()? isPremium,
    bool Function()? showMoreButton,
    List<DayData> Function()? dayData,
    PeakFlowReading? Function()? readingToDelete,
  }) {
    return PeakFlowReadingOverviewState(
        status: status != null ? status() : this.status,
        showMoreButton:
            showMoreButton != null ? showMoreButton() : this.showMoreButton,
        dayData: dayData != null ? dayData() : this.dayData,
        readingToDelete:
            readingToDelete != null ? readingToDelete() : this.readingToDelete);
  }

  @override
  List<Object?> get props => [status, dayData, showMoreButton];
}
