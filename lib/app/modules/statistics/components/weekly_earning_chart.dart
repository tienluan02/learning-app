import 'package:eden_learning_app/app/data/constants/constants.dart';
import 'package:eden_learning_app/app/modules/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeeklyEarningChart extends StatefulWidget {
  const WeeklyEarningChart({super.key});

  @override
  State<WeeklyEarningChart> createState() => _WeeklyEarningChartState();
}

class _WeeklyEarningChartState extends State<WeeklyEarningChart> {
  final Color leftBarColor = AppColors.kPrimary;
  final Color rightBarColor = AppColors.kAccent1;

  late List<_ChartData> chartData;

  @override
  void initState() {
    super.initState();
    chartData = [
      _ChartData('M', 50, 60),
      _ChartData('T', 70, 40),
      _ChartData('W', 60, 50),
      _ChartData('T', 40, 70),
      _ChartData('F', 30, 30),
      _ChartData('S', 80, 50),
      _ChartData('S', 90, 40),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sales Earnings', style: AppTypography.kLight16),
        Row(
          children: [
            Text(r'$1,242.45', style: AppTypography.kLight30),
            SizedBox(width: AppSpacing.tenHorizontal),
            CustomIconButton(
              size: 30.h,
              color: AppColors.kPrimary.withOpacity(0.15),
              icon: AppAssets.kTriangleUp,
              onTap: () {},
            ),
            SizedBox(width: 9.w),
            Text(
              '+25%',
              style: AppTypography.kBold14.copyWith(color: AppColors.kPrimary),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        SizedBox(
          height: 205.h,
          width: double.maxFinite,
          child: SfCartesianChart(
            tooltipBehavior: TooltipBehavior(enable: true),
            primaryXAxis: CategoryAxis(),
            series: <ChartSeries<_ChartData, String>>[
              LineSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.day,
                yValueMapper: (_ChartData data, _) => data.sales,
                color: leftBarColor,
                width: 2,
                name: 'This Week',
                markerSettings: const MarkerSettings(isVisible: true),
              ),
              LineSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.day,
                yValueMapper: (_ChartData data, _) => data.previousSales,
                color: rightBarColor,
                width: 2,
                name: 'Last Week',
                markerSettings: const MarkerSettings(isVisible: true),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: AppSpacing.tenVertical,
              height: 10.w,
              decoration: const BoxDecoration(
                color: AppColors.kPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Sales this week'),
            const SizedBox(width: 16),
            Container(
              width: 10.01.w,
              height: 10.01.h,
              decoration: const BoxDecoration(
                color: AppColors.kAccent1,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Sales last week'),
          ],
        ),
      ],
    );
  }
}

class _ChartData {
  final String day;
  final double sales;
  final double previousSales;

  _ChartData(this.day, this.sales, this.previousSales);
}
