import 'package:flutter_test/flutter_test.dart';
import 'package:zensoku/util.dart';

void main() {
  group('Rounding value tests', () {
    test('0 returns 0 ', () {
      const input = 0;
      const expected = 0;

      final actual = roundPeakFlowValueToBetween100(input);

      expect(expected, actual);
    });

    test('1000 returns 100 ', () {
      const input = 1000;
      const expected = 100;

      final actual = roundPeakFlowValueToBetween100(input);

      expect(expected, actual);
    });

    test('333 returns 33 ', () {
      const input = 333;
      const expected = 33;

      final actual = roundPeakFlowValueToBetween100(input);

      expect(expected, actual);
    });

    test('956 returns 96', () {
      const input = 956;
      const expected = 96;

      final actual = roundPeakFlowValueToBetween100(input);

      expect(expected, actual);
    });
  });
}
