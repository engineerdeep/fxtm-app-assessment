import 'package:equatable/equatable.dart';
import 'package:forex_repository/forex_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'historical_data_event.dart';
part 'historical_data_state.dart';

class HistoricalDataBloc
    extends HydratedBloc<HistoricalDataEvent, HistoricalDataState> {
  final ForexRepository _repository;

  HistoricalDataBloc({required ForexRepository repository})
      : _repository = repository,
        super(const HistoricalDataState()) {
    on<HistoricalDataRequested>(_onHistoricalDataRequested);
    on<HistoricalDataResolutionChanged>(_onResolutionChanged);
  }

  @override
  HistoricalDataState? fromJson(Map<String, dynamic> json) {
    try {
      return HistoricalDataState(
        status: HistoricalDataStatus.values[json['status'] as int],
        historicalData: (json['historicalData'] as List).map((data) {
          final Map<String, dynamic> deserializedData = Map.from(data);
          deserializedData['timestamp'] =
              DateTime.parse(data['timestamp'] as String);
          return deserializedData;
        }).toList(),
        resolution: json['resolution'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(HistoricalDataState state) {
    try {
      return {
        'status': state.status.index,
        'historicalData': state.historicalData.map((data) {
          final Map<String, dynamic> serializedData = Map.from(data);
          serializedData['timestamp'] =
              (data['timestamp'] as DateTime).toIso8601String();
          return serializedData;
        }).toList(),
        'resolution': state.resolution,
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _onHistoricalDataRequested(
    HistoricalDataRequested event,
    Emitter<HistoricalDataState> emit,
  ) async {
    emit(state.copyWith(status: HistoricalDataStatus.loading));

    try {
      final to = DateTime.now();
      final from = to.subtract(const Duration(days: 7));

      final data = await _repository.getHistoricalData(
        event.symbol,
        from: from,
        to: to,
        resolution: state.resolution,
      );

      emit(state.copyWith(
        status: HistoricalDataStatus.success,
        historicalData: data,
      ));
    } catch (e) {
      emit(state.copyWith(status: HistoricalDataStatus.failure));
    }
  }

  void _onResolutionChanged(
    HistoricalDataResolutionChanged event,
    Emitter<HistoricalDataState> emit,
  ) {
    emit(state.copyWith(resolution: event.resolution));
    add(HistoricalDataRequested(symbol: event.symbol));
  }
}
