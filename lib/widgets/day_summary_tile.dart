import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:statistics/statistics.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/widgets/good_average_bad_bar.dart';
import 'package:zensoku/widgets/reading_day_page.dart';
import 'package:zensoku/zensoku_theme.dart';

class DaySummaryTile extends StatelessWidget {
  const DaySummaryTile({required DayData dayData, super.key})
      : _dayData = dayData;

  final DayData _dayData;

  @override
  Widget build(BuildContext context) {
    final headingDateFormatter = DateFormat('dd MMM yy');
    final readings = _dayData.peakFlowReadings;
    var average = 0;
    if (readings.isNotEmpty) {
      final readingList = readings.map((r) => r.reading).toList();
      average = readingList.median!.toInt();
    }

    // ignore: unused_local_variable
    const minMaxStyle = TextStyle(fontSize: 24);

    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      child: Card(
        color: ZensokuTheme.cardBackgroundColour,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            //*****Title Row */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headingDateFormatter.format(_dayData.date),
                  style: ZensokuTheme.darkHeading1Style,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/preventer.svg',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Text(
                        _dayData.totalPreventerUse.toString(),
                        style: ZensokuTheme.darkHeading1Style,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/reliever.svg',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Text(
                        _dayData.totalRelieverUse.toString(),
                        style: ZensokuTheme.darkHeading1Style,
                      ),
                    )
                  ],
                ),
              ],
            ),
            //additional icons
            //*****Middle content*/
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Row(
                children: [
                  Expanded(
                      child: GoodAverageBadBar(
                    averageReading: average,
                  ))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Icon(
                        FontAwesomeIcons.gaugeSimple,
                        size: 30,
                        color: HexColor('#1E3050'),
                      ),
                    ),
                    Text(
                      '$average l/m',
                      style: ZensokuTheme.darkHeading1Style,
                    ),
                  ],
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          ReadingDayPage.route(currentDate: _dayData.date));
                    },
                    child: Text(
                      'All (${readings.length})',
                      style: TextStyle(
                          color: HexColor('#6536f8'),
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
