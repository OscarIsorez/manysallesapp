import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:manysallesappCrimson/injection_container.dart';

import '../../domain/entities/daily_aggregate.dart';
import '../../domain/usecases/progress_usecases.dart';

class ProgressChartPage extends StatefulWidget {
  final String gymId;
  final String exerciseId;

  const ProgressChartPage({
    super.key,
    required this.gymId,
    required this.exerciseId,
  });

  @override
  State<ProgressChartPage> createState() => _ProgressChartPageState();
}

class _ProgressChartPageState extends State<ProgressChartPage> {
  late Future<List<DailyAggregate>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<DailyAggregate>> _loadData() async {
    final usecase = sl<GetDailyAggregatedLogs>();
    final res = await usecase.call(
      GetDailyParams(gymId: widget.gymId, exerciseId: widget.exerciseId),
    );
    return res.match((l) => throw Exception(l.message), (r) => r);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: FutureBuilder<List<DailyAggregate>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: Text('No data'));

          final spots = <FlSpot>[];
          for (var i = 0; i < data.length; i++) {
            spots.add(FlSpot(i.toDouble(), data[i].maxWeight));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double v, TitleMeta meta) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= data.length)
                                return const SizedBox();
                              final date = data[idx].date;
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(DateFormat.Md().format(date)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: false,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final d = data[index];
                      return ListTile(
                        title: Text('${d.maxWeight} kg'),
                        subtitle: Text(
                          '${d.totalSets} sets · ${d.totalReps} reps · ${DateFormat.yMMMd().format(d.date)}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
