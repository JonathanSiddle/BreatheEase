import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:zensoku/util.dart';

class GoodAverageBadBar extends StatelessWidget {
  const GoodAverageBadBar({
    super.key,
    required this.averageReading,
  });
  final int averageReading;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        constraints: const BoxConstraints(minHeight: 20),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      Row(
        children: [
          Flexible(
            flex: 330,
            child: Container(
              constraints: const BoxConstraints(minHeight: 20),
              decoration: BoxDecoration(
                color: HexColor('#d9376e'),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
              ),
            ),
          ),
          Flexible(
            flex: 110,
            child: Container(
              constraints: const BoxConstraints(minHeight: 20),
              decoration: BoxDecoration(
                color: HexColor('#f58436'),
              ),
            ),
          ),
          Flexible(
            flex: 560,
            child: Container(
              constraints: const BoxConstraints(minHeight: 20),
              decoration: BoxDecoration(
                color: HexColor('#afd9b4'),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
            ),
          )
        ],
      ),
      if (averageReading != 0) _buildLocationDotForValue(averageReading)
    ]);
  }

  Widget _buildLocationDotForValue(int value, {String labelText = ''}) {
    final roundedVal = roundPeakFlowValueToBetween100(value);

    return Row(
      children: [
        Flexible(flex: roundedVal, child: Container()),
        Stack(
          children: [
            Transform.translate(
              offset: Offset(0, labelText.trim() != '' ? -25 : -20),
              child: Column(
                children: [
                  if (labelText.trim() != '') Text(labelText) else Container(),
                  const Icon(
                    FontAwesomeIcons.locationDot,
                    color: Colors.white,
                    size: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
        Flexible(flex: 100 - roundedVal, child: Container()),
      ],
    );
  }
}
