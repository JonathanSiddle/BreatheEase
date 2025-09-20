import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zensoku/widgets/peak_flow_reading_input_dialog.dart';

Future<void> showPeakFlowReadingInputDialog(BuildContext context,
    {required Logger? logger}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return PeakFlowReadingInputDialog(
        logger: logger,
      );
    },
  );
}

Future<bool> showConfirmationDialog(BuildContext context,
    {String? contentText,
    String? titleText,
    TextStyle? noStyle,
    TextStyle? yesStyle}) async {
  bool returnVal = false;

  final String title = titleText ?? 'Delete';
  final String dialogText =
      contentText ?? 'Are you sure, this can not be undone?';

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          dialogText,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Return false on No
            },
            child: Text(
              'No',
              style: noStyle,
            ),
          ),
          TextButton(
            onPressed: () {
              returnVal = true;
              Navigator.of(context).pop(); // Return true on Yes
            },
            child: Text('Yes', style: yesStyle),
          ),
        ],
      );
    },
  );

  return returnVal;
}
