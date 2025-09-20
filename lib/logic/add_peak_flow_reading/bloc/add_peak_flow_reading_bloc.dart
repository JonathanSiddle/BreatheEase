import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';

part 'add_peak_flow_reading_event.dart';
part 'add_peak_flow_reading_state.dart';

final class AddPeakFlowReadingBloc
    extends Bloc<AddPeakFlowReadingEvent, AddPeakFlowReadingState> {
  AddPeakFlowReadingBloc({
    required PeakFlowReadingsRepository peakFlowReadingsRepository,
    required DateTimeRepository dateTimeRepository,
    required Logger? logger,
  })  : _dateTimeRepository = dateTimeRepository,
        _peakFlowReadingsRepository = peakFlowReadingsRepository,
        _logger = logger ?? Logger(),
        super(const AddPeakFlowReadingState()) {
    on<AddPeakFlowReadingUpdated>(_onReadingUpdated);
    on<AddPeakFlowReadingSave>(_onReadingSaved);
    on<IncreasePeakFlowValue>(_onIncreasePeakFlowValue);
    on<DecreasePeakFlowValue>(_onDecreasePeakFlowValue);
  }

  final PeakFlowReadingsRepository _peakFlowReadingsRepository;
  final DateTimeRepository _dateTimeRepository;
  final Logger _logger;

  FutureOr<void> _onReadingUpdated(
    AddPeakFlowReadingUpdated event,
    Emitter<AddPeakFlowReadingState> emit,
  ) async {
    emit(state.copyWith(
      currentReading: () => event.reading,
    ));
  }

  FutureOr<void> _onReadingSaved(
    AddPeakFlowReadingSave event,
    Emitter<AddPeakFlowReadingState> emit,
  ) async {
    _logger.i('Started saving reading');
    const uuid = Uuid();
    emit(state.copyWith(status: () => AddPeakFlowReadingStatus.saving));
    //TODO: Find away to handle errors here
    // await Future.delayed(const Duration(milliseconds: 500));
    var errorSavingReading = false;
    try {
      _peakFlowReadingsRepository.addPeakFlowReading(PeakFlowReading(
          id: uuid.v4(),
          date: _dateTimeRepository.now,
          reading: event.reading));
    } catch (e) {
      errorSavingReading = true;
    }
    if (!errorSavingReading) {
      emit(state.copyWith(
          status: () => AddPeakFlowReadingStatus.success,
          currentReading: () => event.reading));
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      emit(state.copyWith(
          status: () => AddPeakFlowReadingStatus.failure,
          currentReading: () => event.reading));
      await Future.delayed(const Duration(milliseconds: 2000));
    }

    //raise reset event
    emit(AddPeakFlowReadingState(currentReading: event.reading));
  }

  Future<void> _onIncreasePeakFlowValue(
    IncreasePeakFlowValue event,
    Emitter<AddPeakFlowReadingState> emit,
  ) async {
    emit(state.copyWith(currentReading: () => event.value));
  }

  Future<void> _onDecreasePeakFlowValue(
    DecreasePeakFlowValue event,
    Emitter<AddPeakFlowReadingState> emit,
  ) async {
    emit(state.copyWith(currentReading: () => event.value));
  }
}
