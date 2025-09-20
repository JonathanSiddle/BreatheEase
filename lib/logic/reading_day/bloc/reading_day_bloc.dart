import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:zensoku/models/models.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';

part 'reading_day_event.dart';
part 'reading_day_state.dart';

class ReadingDayBloc extends Bloc<ReadingDayEvent, ReadingDayState> {
  ReadingDayBloc(
      {required PeakFlowReadingsRepository peakFlowReadingsRepository,
      required DateTime currentDate,
      required Logger? logger})
      : _peakFlowReadingsRepository = peakFlowReadingsRepository,
        _currentDate = currentDate,
        _log = logger ?? Logger(),
        super(const ReadingDayState()) {
    on<ReadingDaySubscriptionRequested>(_onSubscriptionRequested);
    on<ReadingDayDeleteReading>(_onDeletedReadingRequested);
    on<ReadingDayDeleteReadingCancelled>(_onDeletedReadingCancelled);
    on<ReadingDayDeleteReadingConfirmed>(_onDeletedReadingConfirmed);
  }

  final PeakFlowReadingsRepository _peakFlowReadingsRepository;
  final DateTime _currentDate;
  final Logger _log;

  FutureOr<void> _onSubscriptionRequested(ReadingDaySubscriptionRequested event,
      Emitter<ReadingDayState> emit) async {
    emit(state.copyWith(status: () => ReadingDayStatus.loading));

    await emit.forEach<List<PeakFlowReading>>(
        _peakFlowReadingsRepository.getPeakFlowReadingsForDate(_currentDate),
        onData: (peakFlowReadings) {
      return state.copyWith(
        status: () => ReadingDayStatus.success,
        readings: () => peakFlowReadings,
      );
    }, onError: (e, stack) {
      return state.copyWith(
          status: () => ReadingDayStatus.failure,
          errorMessage: () => e.toString());
    });
  }

  FutureOr<void> _onDeletedReadingRequested(
      ReadingDayDeleteReading event, Emitter<ReadingDayState> emit) async {
    emit(state.copyWith(
        status: () => ReadingDayStatus.deleteRequested,
        readingToDelete: () => event.readingToDelete));
  }

  FutureOr<void> _onDeletedReadingConfirmed(
      ReadingDayDeleteReadingConfirmed event,
      Emitter<ReadingDayState> emit) async {
    final readingToDelete = state.readingToDelete;
    if (readingToDelete == null) {
      _log.e('Reading to delete is null');
      return;
    }
    //TODO: May need some more error handling around this...
    _peakFlowReadingsRepository.deletePeakFlowReading(readingToDelete);

    emit(state.copyWith(
        status: () => ReadingDayStatus.deleteSuccess,
        readingToDelete: () => null));
  }

  FutureOr<void> _onDeletedReadingCancelled(
      ReadingDayDeleteReadingCancelled event,
      Emitter<ReadingDayState> emit) async {
    emit(state.copyWith(
        status: () => ReadingDayStatus.deleteCancelled,
        readingToDelete: () => null));
  }
}
