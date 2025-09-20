import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class WeekOverviewGraph extends StatefulWidget {
  const WeekOverviewGraph(
      {super.key, required this.daysAndSummary, required Logger logger})
      : _log = logger;

  final Map<int, int> daysAndSummary;
  final Logger _log;

  @override
  State<WeekOverviewGraph> createState() => _WeekOverviewGraphState();
}

class _WeekOverviewGraphState extends State<WeekOverviewGraph> {
  @override
  Widget build(BuildContext context) {
    final textColour =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    final List<Color> gradientColors = [textColour, textColour];

    final List<FlSpot> data = [];
    int index = 0;

    final keys = widget.daysAndSummary.keys.toList().reversed.toList();
    for (final k in keys) {
      data.add(
          FlSpot(index.toDouble(), scaleToRange(widget.daysAndSummary[k]!)));
      index += 1;
    }

    if (index < 7) {
      while (index < 7) {
        data.add(FlSpot(index.toDouble(), 0));
        index += 1;
      }
    }

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              mainData(data, gradientColors),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    final keyList = widget.daysAndSummary.keys.toList().reversed.toList();
    final index = value.toInt();
    var displayText = '';

    if (index < keyList.length) {
      displayText = keyList[index].toString();
    }

    final text = Text(
      displayText,
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '100';
      case 3:
        text = '500';
      case 6:
        text = '1000';
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData(List<FlSpot> data, List<Color> gradientColors) {
    return LineChartData(
        gridData: FlGridData(
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: gradientColors[0],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: gradientColors[0],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors
                    .map((color) => color.withValues(alpha: 0.3))
                    .toList(),
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: ZensokuTheme.primaryColor,
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (List<LineBarSpot> graphSpots) {
            widget._log.i('graphSpots: ${graphSpots.length}');
            return graphSpots.map((spot) {
              return LineTooltipItem(
                '${widget.daysAndSummary.values.toList().reversed.toList()[spot.x.toInt()]}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
            // List<LineTooltipItem> items = [];
            // final values = widget.daysAndSummary.values.toList();
            //
            // for (int x = 0; x <= graphSpots.length; x++) {
            //   items.add(LineTooltipItem(values[x].toString(), const TextStyle(color: Colors.white, fontSize: 1)));
            // }
            //
            // return items;
          },
        )));
  }

  double scaleToRange(int value) {
    if (value <= 0) {
      return 0;
    }

    if (value >= 1000) {
      return 5;
    }

    return value / (1000 / 6);
  }
}
