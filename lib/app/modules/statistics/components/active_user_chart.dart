import 'package:mentor_mesh_hub/app/data/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActiveUserChart extends StatefulWidget {
  const ActiveUserChart({super.key});

  @override
  _ActiveUserChartState createState() => _ActiveUserChartState();
}

class _ActiveUserChartState extends State<ActiveUserChart> {
  List<_ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    chartData = [
      _ChartData('M', 5, 12),
      _ChartData('T', 16, 12),
      _ChartData('W', 18, 5),
      _ChartData('T', 20, 16),
      _ChartData('F', 17, 6),
      _ChartData('S', 19, 1.5),
      _ChartData('S', 10, 1.5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      legend: Legend(isVisible: true),
      series: <CartesianSeries<_ChartData, String>>[
        ColumnSeries<_ChartData, String>(
          name: 'Sales',
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.day,
          yValueMapper: (_ChartData data, _) => data.sales,
          color: AppColors.kPrimary,
        ),
        ColumnSeries<_ChartData, String>(
          name: 'Visitors',
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.day,
          yValueMapper: (_ChartData data, _) => data.visitors,
          color: AppColors.kAccent2,
        ),
      ],
    );
  }
}

class _ChartData {
  final String day;
  final double sales;
  final double visitors;

  _ChartData(this.day, this.sales, this.visitors);
}
