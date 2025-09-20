import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zensoku/logic/reading_day/bloc/reading_day_bloc.dart';
import 'package:zensoku/logic/reading_day/view/reading_day_view.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/util/log_util.dart';

class ReadingDayPage extends StatelessWidget {
  const ReadingDayPage({super.key, required this.currentDate});

  static Page<void> page({required DateTime currentDate}) => MaterialPage<void>(
          child: ReadingDayPage(
        currentDate: currentDate,
      ));

  static Route<void> route({required DateTime currentDate}) {
    return MaterialPageRoute<void>(
        builder: (_) => ReadingDayPage(
              currentDate: currentDate,
            ));
  }

  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadingDayBloc(
        currentDate: currentDate,
        peakFlowReadingsRepository: context.read<PeakFlowReadingsRepository>(),
        logger: context.read<LoggingFactory>().getLogger('ReadingDayBloc'),
      )..add(const ReadingDaySubscriptionRequested()),
      child: ReadingDayView(
        currentDate: currentDate,
        logger: context.read<LoggingFactory>().getLogger('ReadingDayPage'),
      ),
    );
  }
}
