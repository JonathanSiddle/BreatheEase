import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';

part 'all_readings_event.dart';
part 'all_readings_state.dart';

class AllReadingsBloc extends Bloc<AllReadingsEvent, AllReadingsState> {
  AllReadingsBloc(
      {required PeakFlowReadingsRepository peakFlowReadingsRepository})
      : _peakFlowReadingsRepository = peakFlowReadingsRepository,
        super(const AllReadingsState()) {
    on<AllReadingSubscriptionRequested>(_onSubscriptionRequested);
  }

  final PeakFlowReadingsRepository _peakFlowReadingsRepository;

  FutureOr<void> _onSubscriptionRequested(AllReadingSubscriptionRequested event,
      Emitter<AllReadingsState> emit) async {
    emit(state.copyWith(status: () => AllReadingsStatus.loading));

    //get peak flow readings...
    await emit.forEach<List<DayData>>(
        _peakFlowReadingsRepository.getAllPeakFlowReadings(),
        onData: (dayData) {
      return state.copyWith(
          status: () => AllReadingsStatus.success, dayData: () => dayData);
    }, onError: (e, stack) {
      return state.copyWith(status: () => AllReadingsStatus.failure);
    });
  }
}
