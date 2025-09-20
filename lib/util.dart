int roundPeakFlowValueToBetween100(int value) {
  //make sure between 0-1000
  final int val = value < 0
      ? 0
      : value > 1000
          ? 1000
          : value;

  return (val / 10).round();
}
