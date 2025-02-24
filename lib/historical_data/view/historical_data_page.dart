import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forex_repository/forex_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../bloc/historical_data_bloc.dart';

class HistoricalDataPage extends StatelessWidget {
  final String symbol;
  final String displaySymbol;

  const HistoricalDataPage({
    super.key,
    required this.symbol,
    required this.displaySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoricalDataBloc(
        repository: context.read<ForexRepository>(),
      )..add(HistoricalDataRequested(symbol: symbol)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('$displaySymbol History'),
          actions: [
            _ResolutionSelector(symbol: symbol),
          ],
        ),
        body: const _HistoricalDataView(),
      ),
    );
  }
}

class _ResolutionSelector extends StatelessWidget {
  final String symbol;

  const _ResolutionSelector({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        context.read<HistoricalDataBloc>().add(
              HistoricalDataResolutionChanged(
                resolution: value,
                symbol: symbol,
              ),
            );
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: '1', child: Text('1 Minute')),
        const PopupMenuItem(value: '5', child: Text('5 Minutes')),
        const PopupMenuItem(value: '15', child: Text('15 Minutes')),
        const PopupMenuItem(value: '60', child: Text('1 Hour')),
        const PopupMenuItem(value: 'D', child: Text('1 Day')),
      ],
    );
  }
}

class _HistoricalDataView extends StatelessWidget {
  const _HistoricalDataView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoricalDataBloc, HistoricalDataState>(
      builder: (context, state) {
        switch (state.status) {
          case HistoricalDataStatus.initial:
          case HistoricalDataStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case HistoricalDataStatus.failure:
            return const Center(child: Text('Failed to fetch historical data'));
          case HistoricalDataStatus.success:
            if (state.historicalData.isEmpty) {
              return const Center(child: Text('No historical data available'));
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                  value.toInt());
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  DateFormat('MM/dd').format(date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 0.1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: state.historicalData.map((data) {
                            final timestamp = (data['timestamp'] as DateTime)
                                .millisecondsSinceEpoch
                                .toDouble();
                            return FlSpot(
                              timestamp,
                              data['close'] as double,
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                      clipData: const FlClipData.all(),
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
