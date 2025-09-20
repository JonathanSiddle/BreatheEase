import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:zensoku/logic/add_peak_flow_reading/bloc/add_peak_flow_reading_bloc.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/util/log_util.dart';
import 'package:zensoku/zensoku_theme.dart';

class AddPeakFlowReading extends StatelessWidget {
  AddPeakFlowReading({super.key, required Logger? logger})
      : _log = logger ?? Logger();

  final Logger _log;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddPeakFlowReadingBloc(
          dateTimeRepository: context.read<DateTimeRepository>(),
          peakFlowReadingsRepository:
              context.read<PeakFlowReadingsRepository>(),
          logger: context
              .read<LoggingFactory>()
              .getLogger('AddPeakFlowReadingBloc')),
      child: _PeakFlowReadingView(
        logger: _log,
      ),
    );
  }
}

class _PeakFlowReadingView extends StatefulWidget {
  _PeakFlowReadingView({required Logger? logger}) : _log = logger ?? Logger();

  final Logger _log;

  @override
  State<_PeakFlowReadingView> createState() => _PeakFlowReadingViewState();
}

class _PeakFlowReadingViewState extends State<_PeakFlowReadingView> {
  final _readingController = TextEditingController(text: '400');

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(maxHeight: 250, maxWidth: 400, minWidth: 350),
      child: BlocBuilder<AddPeakFlowReadingBloc, AddPeakFlowReadingState>(
        builder: (context, state) {
          if (state.status == AddPeakFlowReadingStatus.saving) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            );
          } else if (state.status == AddPeakFlowReadingStatus.success) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Saved Reading!')],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ZensokuTheme.secondaryColor,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          widget._log.i('Tapped on add!');
                          context.read<AddPeakFlowReadingBloc>().add(
                              AddPeakFlowReadingSave(state.currentReading));
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(fontSize: 18),
                        )),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 18),
                        onChanged: (value) {
                          context
                              .read<AddPeakFlowReadingBloc>()
                              .add(AddPeakFlowReadingUpdated(int.parse(value)));
                        },
                        textDirection: TextDirection.rtl,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        controller: _readingController,
                        decoration: const InputDecoration(
                            label: Text('Reading'), hintText: 'l/min'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                      child: Text(
                        'l/min',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.minus),
                    onPressed: () {
                      final newValue = state.currentReading - 10;
                      _readingController.text = newValue.toString();
                      context
                          .read<AddPeakFlowReadingBloc>()
                          .add(DecreasePeakFlowValue(newValue));
                    },
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.plus),
                    onPressed: () {
                      final newValue = state.currentReading + 10;
                      _readingController.text = newValue.toString();
                      context.read<AddPeakFlowReadingBloc>().add(
                          IncreasePeakFlowValue(state.currentReading + 10));
                    },
                  )
                ],
              ),
              Slider(
                  max: 1000,
                  value: int.parse(_readingController.value.text).toDouble(),
                  onChanged: (value) {
                    final rounded = (value / 10).round() * 10;
                    _readingController.text = rounded.toString();
                    context
                        .read<AddPeakFlowReadingBloc>()
                        .add(AddPeakFlowReadingUpdated(rounded));
                  })
            ],
          );
        },
      ),
    );
  }
}
