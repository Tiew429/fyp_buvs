import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBarChart extends StatefulWidget {
  final List<String> xAxisList;
  final String xAxisName;
  final List<double> yAxisList;
  final String yAxisName;
  final double interval;

  const CustomBarChart(
      {super.key,
      required this.xAxisList,
      required this.yAxisList,
      required this.xAxisName,
      required this.yAxisName,
      required this.interval});

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  late List<String> xAxisList;
  late List<double> yAxisList;
  late String xAxisName;
  late String yAxisName;
  late double interval;

  @override
  void initState() {
    super.initState();
    xAxisList = widget.xAxisList;
    yAxisList = widget.yAxisList;
    xAxisName = widget.xAxisName;
    yAxisName = widget.yAxisName;
    interval = widget.interval;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Find maximum value in the y-axis data
    double maxY = yAxisList.isEmpty ? 1.0 : yAxisList.reduce((a, b) => a > b ? a : b);
    
    // Set minimum max value to 3 to ensure small values like 1 are visible
    maxY = maxY < 3 ? 3.0 : maxY;

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              xAxisName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => bottomTitles(value, meta, xAxisList, context),
              reservedSize: 42,
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              yAxisName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: 1, // Set interval to 1 for small values
              getTitlesWidget: (value, meta) => leftTitles(value, meta, context),
            ),
          ),
        ),
        borderData: FlBorderData(
          border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          ),
        ),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(
          xAxisList.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: yAxisList[index] > 0 ? yAxisList[index] : 0.2,
                width: xAxisList.length <= 3 ? 60 : 50,
                color: colorScheme.secondary,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.7),
                    colorScheme.secondary,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
            ],
          ),
        ).toList(),
      ),
    );
  }
}

Widget bottomTitles(double value, TitleMeta meta, List<String> bottomTilesData, BuildContext context) {
  final Widget text = Text(
    bottomTilesData[value.toInt()],
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  );

  return SideTitleWidget(
    meta: meta,
    space: 16, 
    child: text,
  );
}

Widget leftTitles(double value, TitleMeta meta, BuildContext context) {
  final formattedValue = (value).toStringAsFixed(0);
  final Widget text = Text(
    formattedValue,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  );

  return SideTitleWidget(
    meta: meta,
    space: 16, 
    child: text,
  );
}