part of 'peak_flow_reading_overview_bloc.dart';

final class PeakFlowReadingOverviewEvent extends Equatable {
  const PeakFlowReadingOverviewEvent();

  @override
  List<Object?> get props => [];
}

final class PeakFlowReadingOverviewSubscriptionRequested
    extends PeakFlowReadingOverviewEvent {
  const PeakFlowReadingOverviewSubscriptionRequested();
}

final class PeakFLowReadingOverviewLogoutRequested
    extends PeakFlowReadingOverviewEvent {
  const PeakFLowReadingOverviewLogoutRequested();
}

final class PeakFlowReadingOverviewIncrementRelieverUse
    extends PeakFlowReadingOverviewEvent {
  const PeakFlowReadingOverviewIncrementRelieverUse();

  @override
  List<Object?> get props => [];
}

final class PeakFlowReadingOverviewIncrementPreventerUse
    extends PeakFlowReadingOverviewEvent {
  const PeakFlowReadingOverviewIncrementPreventerUse();

  @override
  List<Object?> get props => [];
}

final class PeakFlowReadingOverviewDeleteReading
    extends PeakFlowReadingOverviewEvent {
  const PeakFlowReadingOverviewDeleteReading(this.readingToDelete);

  final PeakFlowReading readingToDelete;

  @override
  List<Object?> get props => [readingToDelete];
}

final class PeakFlowReadingOverviewDeleteReadingConfirmed
    extends PeakFlowReadingOverviewEvent {
  const PeakFlowReadingOverviewDeleteReadingConfirmed();
}

final class PeakFlowReadingOverviewDeleteReadingCancelled
    extends PeakFlowReadingOverviewEvent {
  const PeakFlowReadingOverviewDeleteReadingCancelled();
}

final class PeakFlowReadingOverviewRequestShowAllReadings
    extends PeakFlowReadingOverviewEvent {
  const PeakFlowReadingOverviewRequestShowAllReadings();
}
