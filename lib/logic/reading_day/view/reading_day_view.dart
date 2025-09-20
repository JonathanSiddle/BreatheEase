import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:zensoku/logic/reading_day/bloc/reading_day_bloc.dart';
import 'package:zensoku/widgets/dialog_util.dart';

final timeFormat = DateFormat('HH:mm:ss');

class ReadingDayView extends StatelessWidget {
  ReadingDayView(
      {super.key, required this.currentDate, required Logger? logger})
      : _log = logger ?? Logger();

  final DateTime currentDate;
  final Logger _log;

  @override
  Widget build(BuildContext context) {
    final headingDateFormatter = DateFormat('dd MMM yy');

    return BlocConsumer<ReadingDayBloc, ReadingDayState>(
      listener: (context, state) async {
        if (state.status == ReadingDayStatus.deleteRequested) {
          _log.d(state.readingToDelete);
          showConfirmationDialog(context).then((delete) {
            _log.d('Delete: $delete');
            if (!context.mounted) return;
            if (delete) {
              context
                  .read<ReadingDayBloc>()
                  .add(const ReadingDayDeleteReadingConfirmed());
            } else {
              context
                  .read<ReadingDayBloc>()
                  .add(const ReadingDayDeleteReadingCancelled());
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              headingDateFormatter.format(currentDate),
            ),
          ),
          body: state.status == ReadingDayStatus.loading
              ? const CircularProgressIndicator()
              : state.status == ReadingDayStatus.failure
                  ? Text(state.errorMessage)
                  : state.readings.isNotEmpty
                      ? ListView.builder(
                          itemCount: state.readings.length,
                          itemBuilder: (context, index) {
                            final reading = state.readings[index];
                            return Card(
                              color: HexColor('#94a1b2'),
                              elevation: 4,
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                title: Text(timeFormat.format(reading.date)),
                                subtitle: Text('${reading.reading} l/min'),
                                trailing: IconButton(
                                    icon: const Icon(FontAwesomeIcons.trash),
                                    onPressed: () => context
                                        .read<ReadingDayBloc>()
                                        .add(ReadingDayDeleteReading(reading))),
                              ),
                            );
                          })
                      : const Center(
                          child: Text('Looks like there is nothing here!')),
        );
      },
    );
  }
}
