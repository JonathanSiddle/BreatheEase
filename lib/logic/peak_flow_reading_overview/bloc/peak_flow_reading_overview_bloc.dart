import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/models/inhaler_use.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/guid_id_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';

part 'peak_flow_reading_overview_event.dart';
part 'peak_flow_reading_overview_state.dart';

class PeakFlowReadingOverviewBloc
    extends Bloc<PeakFlowReadingOverviewEvent, PeakFlowReadingOverviewState> {
  PeakFlowReadingOverviewBloc({
    required PeakFlowReadingsRepository peakFlowReadingsRepository,
    required DateTimeRepository dateTimeRepository,
    required FeatureRegistory featureRegistory,
    required GuidRepository guidRepository,
  })  : _guidRepository = guidRepository,
        _dateTimeRepository = dateTimeRepository,
        _peakFlowReadingsRepository = peakFlowReadingsRepository,
        _log = Logger(),
        usingLocalStorage =
            featureRegistory.isEnabled(FeatureType.localStorage),
        super(const PeakFlowReadingOverviewState()) {
    on<PeakFlowReadingOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<PeakFlowReadingOverviewIncrementPreventerUse>(_onIncrementPreventer);
    on<PeakFlowReadingOverviewIncrementRelieverUse>(_onIncrementReliever);
    on<PeakFlowReadingOverviewRequestShowAllReadings>(
        _onRequestShowAllReadingsPage);
  }

  final Logger _log;
  final GuidRepository _guidRepository;
  final DateTimeRepository _dateTimeRepository;
  final PeakFlowReadingsRepository _peakFlowReadingsRepository;
  final bool usingLocalStorage;

  FutureOr<void> _onSubscriptionRequested(
      PeakFlowReadingOverviewSubscriptionRequested event,
      Emitter<PeakFlowReadingOverviewState> emit) async {
    emit(state.copyWith(status: () => PeakFlowReadingOverviewStatus.loading));

    await emit.forEach<List<DayData>>(
        _peakFlowReadingsRepository.getPeakFlowReadingsLastSevenDays(),
        onData: (dayData) {
      if (dayData.length > 7) {
        emit(state.copyWith(showMoreButton: () => true));
        while (dayData.length > 7) {
          dayData.removeLast();
        }
      }
      return state.copyWith(
          status: () => PeakFlowReadingOverviewStatus.success,
          dayData: () => dayData);
    }, onError: (e, stack) {
      return state.copyWith(
          status: () => PeakFlowReadingOverviewStatus.failure);
    });
  }

  FutureOr<void> _onIncrementPreventer(
    PeakFlowReadingOverviewIncrementPreventerUse event,
    Emitter<PeakFlowReadingOverviewState> emit,
  ) async {
    _log.i('starting to increment preventer use event');
    emit(state.copyWith(
        status: () => PeakFlowReadingOverviewStatus.incrementingPreventerUse));

    var errorIncrementing = false;
    try {
      _peakFlowReadingsRepository.incrementPreventerUse(
          InhalerUse(id: _guidRepository.guid, date: _dateTimeRepository.now));
    } catch (e) {
      errorIncrementing = true;
    }

    if (!errorIncrementing) {
      emit(state.copyWith(
          status: () =>
              PeakFlowReadingOverviewStatus.incrementPreventerUseSuccess));
    } else {
      emit(state.copyWith(
          status: () =>
              PeakFlowReadingOverviewStatus.incrementPreventerUseFailure));
    }
  }

  FutureOr<void> _onIncrementReliever(
    PeakFlowReadingOverviewIncrementRelieverUse event,
    Emitter<PeakFlowReadingOverviewState> emit,
  ) async {
    _log.i('starting to increment preventer use event');
    emit(state.copyWith(
        status: () => PeakFlowReadingOverviewStatus.incrementingPreventerUse));

    var errorIncrementing = false;
    try {
      _peakFlowReadingsRepository.incrementRelieverUse(
          InhalerUse(id: _guidRepository.guid, date: _dateTimeRepository.now));
    } catch (e) {
      errorIncrementing = true;
    }

    if (!errorIncrementing) {
      emit(state.copyWith(
          status: () =>
              PeakFlowReadingOverviewStatus.incrementPreventerUseSuccess));
    } else {
      emit(state.copyWith(
          status: () =>
              PeakFlowReadingOverviewStatus.incrementPreventerUseFailure));
    }
  }

  // //TODO: potentially need to duplicate states for premium check
  // //to be able to distinguish between the two
  Future<void> _onRequestShowAllReadingsPage(
      PeakFlowReadingOverviewRequestShowAllReadings event,
      Emitter<PeakFlowReadingOverviewState> emit) async {
    _log.f('started _onRequestShowAllReadingsPage');
    emit(state.copyWith(
        status: () => PeakFlowReadingOverviewStatus.showAllReadingsPage));
  }
}
