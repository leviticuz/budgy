import 'package:fl_chart/fl_chart.dart';
import'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final double? maxY;
  final double janAmount;
  final double febAmount;
  final double marAmount;
  final double aprAmount;
  final double mayAmount;
  final double junAmount;
  final double julAmount;
  final double augAmount;
  final double septAmount;
  final double octAmount;
  final double novAmount;
  final double decAmount;

  const BarGraph({
    super.key,
    required this.maxY,
    required this.janAmount,
    required this.febAmount,
    required this.marAmount,
    required this.aprAmount,
    required this.mayAmount,
    required this.junAmount,
    required this.julAmount,
    required this.augAmount,
    required this.septAmount,
    required this.octAmount,
    required this.novAmount,
    required this.decAmount,
  });

  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(
      janAmount : janAmount,
      febAmount : febAmount,
      marAmount : marAmount,
      aprAmount : aprAmount,
      mayAmount : mayAmount,
      junAmount : junAmount,
      julAmount : julAmount,
      augAmount : augAmount,
      septAmount : septAmount,
      octAmount : octAmount,
      novAmount : novAmount,
    );
   myBarData.initializeBarData();

    return BarChart(BarChartData(
        maxY: 100,
        minY: 0,
        barGroups: myBarData.barData
          .map((data) => BarChartGroupData(
          x: data.x,
         barRods: [
           BarChartRodData(toY: data.y,
           ),
         ],
        ),
      ).toList(),
    ));
  }
}


