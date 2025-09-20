import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zensoku/logic/add_peak_flow_reading/view/add_peak_flow_reading_view.dart';

class PeakFlowReadingInputDialog extends StatelessWidget {
  PeakFlowReadingInputDialog({super.key, required Logger? logger})
      : _log = logger ?? Logger();

  final Logger _log;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: AddPeakFlowReading(
      logger: _log,
    ));
  }
}
