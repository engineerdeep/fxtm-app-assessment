part of 'historical_data_bloc.dart';

class HistoricalDataEvent extends Equatable {
  const HistoricalDataEvent();

  @override
  List<Object> get props => [];
}

class HistoricalDataRequested extends HistoricalDataEvent {
  const HistoricalDataRequested({required this.symbol});

  final String symbol;

  @override
  List<Object> get props => [symbol];
}

class HistoricalDataResolutionChanged extends HistoricalDataEvent {
  const HistoricalDataResolutionChanged({
    required this.resolution,
    required this.symbol,
  });

  final String resolution;
  final String symbol;

  @override
  List<Object> get props => [resolution, symbol];
}
