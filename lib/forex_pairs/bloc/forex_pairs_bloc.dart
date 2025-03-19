import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:finnhub_api/finnhub_api.dart';
import 'package:forex_repository/forex_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'forex_pairs_event.dart';
part 'forex_pairs_state.dart';

class ForexPairsBloc extends HydratedBloc<ForexPairsEvent, ForexPairsState> {
  final ForexRepository _repository;
  StreamSubscription<ForexQuote>? _quoteSubscription;
  StreamSubscription<WebSocketConnectionState>? _connectionSubscription;

  ForexPairsBloc({required ForexRepository repository})
      : _repository = repository,
        super(const ForexPairsState()) {
    on<ForexPairsSubscriptionRequested>(_onSubscriptionRequested);
    on<ForexPairsQuoteReceived>(_onQuoteReceived);
    on<ForexPairsConnectionStateChanged>(_onConnectionStateChanged);

    _connectionSubscription = _repository.connectionState.listen(
      (state) => add(ForexPairsConnectionStateChanged(state)),
    );
  }

  @override
  ForexPairsState? fromJson(Map<String, dynamic> json) {
    try {
      final symbols = (json['symbols'] as List)
          .map((symbol) => ForexSymbol(
                symbol: symbol['symbol'] as String,
                displaySymbol: symbol['displaySymbol'] as String,
              ))
          .toList();

      final quotes = Map<String, ForexQuote>.from(
        (json['quotes'] as Map).map(
          (key, value) => MapEntry(
            key,
            ForexQuote(
              symbol: value['s'] as String,
              price: (value['p'] as num).toDouble(),
              volume: (value['v'] as num).toDouble(),
              timestamp: DateTime.parse(value['t'] as String),
            ),
          ),
        ),
      );

      final previousQuotes = Map<String, ForexQuote>.from(
        (json['previousQuotes'] as Map).map(
          (key, value) => MapEntry(
            key,
            ForexQuote(
              symbol: value['s'] as String,
              price: (value['p'] as num).toDouble(),
              volume: (value['v'] as num).toDouble(),
              timestamp: DateTime.parse(value['t'] as String),
            ),
          ),
        ),
      );

      return ForexPairsState(
        status: ForexPairsStatus.values[json['status'] as int],
        symbols: symbols,
        quotes: quotes,
        previousQuotes: previousQuotes,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ForexPairsState state) {
    try {
      return {
        'status': state.status.index,
        'symbols': state.symbols
            .map((symbol) => {
                  'symbol': symbol.symbol,
                  'displaySymbol': symbol.displaySymbol,
                })
            .toList(),
        'quotes':
            state.quotes.map((key, value) => MapEntry(key, value.toJson())),
        'previousQuotes': state.previousQuotes
            .map((key, value) => MapEntry(key, value.toJson())),
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _onSubscriptionRequested(ForexPairsSubscriptionRequested event,
      Emitter<ForexPairsState> emit) async {
    emit(state.copyWith(status: ForexPairsStatus.loading));

    try {
      await _repository.connect();
      final symbols = await _repository.getAvailableSymbols();

      for (final symbol in symbols) {
        _repository.subscribe(symbol.symbol);
      }

      _quoteSubscription = _repository.quotes
          .listen((quote) => add(ForexPairsQuoteReceived(quote)));

      emit(state.copyWith(
        status: ForexPairsStatus.success,
        symbols: symbols,
      ));
    } catch (e) {
      emit(state.copyWith(status: ForexPairsStatus.failure));
    }
  }

  void _onQuoteReceived(
      ForexPairsQuoteReceived event, Emitter<ForexPairsState> emit) {
    final quotes = Map<String, ForexQuote>.from(state.quotes);
    final previousQuotes = Map<String, ForexQuote>.from(state.previousQuotes);

    if (quotes.containsKey(event.quote.symbol)) {
      final previousQuote = quotes[event.quote.symbol];
      if (previousQuote != null) {
        previousQuotes[event.quote.symbol] = previousQuote;
      }
    }

    quotes[event.quote.symbol] = event.quote;
    emit(state.copyWith(quotes: quotes, previousQuotes: previousQuotes));
  }

  void _onConnectionStateChanged(
    ForexPairsConnectionStateChanged event,
    Emitter<ForexPairsState> emit,
  ) {
    if (event.websocketConnectionState == WebSocketConnectionState.connected &&
        state.symbols.isNotEmpty) {
      for (final symbol in state.symbols) {
        _repository.subscribe(symbol.symbol);
      }
    }
  }

  @override
  Future<void> close() {
    _quoteSubscription?.cancel();
    _connectionSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
