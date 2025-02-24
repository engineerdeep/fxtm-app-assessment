part of 'forex_pairs_bloc.dart';

enum ForexPairsStatus { initial, loading, success, failure }

class ForexPairsState extends Equatable {
  const ForexPairsState({
    this.status = ForexPairsStatus.initial,
    this.symbols = const [],
    this.quotes = const {},
    this.previousQuotes = const {},
  });

  final ForexPairsStatus status;
  final List<ForexSymbol> symbols;
  final Map<String, ForexQuote> quotes;
  final Map<String, ForexQuote> previousQuotes;

  ForexPairsState copyWith({
    ForexPairsStatus? status,
    List<ForexSymbol>? symbols,
    Map<String, ForexQuote>? quotes,
    Map<String, ForexQuote>? previousQuotes,
  }) {
    return ForexPairsState(
      status: status ?? this.status,
      symbols: symbols ?? this.symbols,
      quotes: quotes ?? this.quotes,
      previousQuotes: previousQuotes ?? this.previousQuotes,
    );
  }

  @override
  List<Object> get props => [status, symbols, quotes, previousQuotes];
}

class ForexPairsInitial extends ForexPairsState {}
