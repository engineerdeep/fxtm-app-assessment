part of 'historical_data_bloc.dart';

enum HistoricalDataStatus { initial, loading, success, failure }

class HistoricalDataState extends Equatable {
  const HistoricalDataState({
    this.status = HistoricalDataStatus.initial,
    this.historicalData = const [],
    this.resolution = '60',
  });

  final HistoricalDataStatus status;
  final List<Map<String, dynamic>> historicalData;
  final String resolution;

  HistoricalDataState copyWith({
    HistoricalDataStatus? status,
    List<Map<String, dynamic>>? historicalData,
    String? resolution,
  }) {
    return HistoricalDataState(
      status: status ?? this.status,
      historicalData: historicalData ?? this.historicalData,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  List<Object> get props => [status, historicalData, resolution];
}
