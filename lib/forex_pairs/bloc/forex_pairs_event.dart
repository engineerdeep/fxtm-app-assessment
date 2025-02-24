part of 'forex_pairs_bloc.dart';

class ForexPairsEvent extends Equatable {
  const ForexPairsEvent();

  @override
  List<Object> get props => [];
}

class ForexPairsSubscriptionRequested extends ForexPairsEvent {
  const ForexPairsSubscriptionRequested();
}

class ForexPairsQuoteReceived extends ForexPairsEvent {
  const ForexPairsQuoteReceived(this.quote);

  final ForexQuote quote;

  @override
  List<Object> get props => [quote];
}

class ForexPairsConnectionStateChanged extends ForexPairsEvent {
  final WebSocketConnectionState websocketConnectionState;

  const ForexPairsConnectionStateChanged(this.websocketConnectionState);

  @override
  List<Object> get props => [websocketConnectionState];
}
