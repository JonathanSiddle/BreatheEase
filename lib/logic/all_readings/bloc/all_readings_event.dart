part of 'all_readings_bloc.dart';

class AllReadingsEvent extends Equatable {
  const AllReadingsEvent();

  @override
  List<Object?> get props => [];
}

final class AllReadingSubscriptionRequested extends AllReadingsEvent {
  const AllReadingSubscriptionRequested();
}
