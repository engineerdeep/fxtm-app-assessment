import 'package:finnhub_api/finnhub_api.dart';

class ForexRepository {
  ForexRepository(this._finnhubService);

  final FinnhubService _finnhubService;

  Stream<ForexQuote> get quotes => _finnhubService.quotes;

  Stream<WebSocketConnectionState> get connectionState =>
      _finnhubService.connectionState;

  Future<void> connect() async {
    await _finnhubService.connect();
  }

  void subscribe(String symbol) {
    _finnhubService.subscribe(symbol);
  }

  void unsubscribe(String symbol) {
    _finnhubService.unsubscribe(symbol);
  }

  void disconnect() {
    _finnhubService.disconnect();
  }

  Future<List<ForexSymbol>> getAvailableSymbols() {
    return _finnhubService.getAvailableSymbols();
  }

  Future<List<Map<String, dynamic>>> getHistoricalData(
    String symbol, {
    required DateTime from,
    required DateTime to,
    required String resolution,
  }) {
    return _finnhubService.getHistoricalData(
      symbol,
      from: from,
      to: to,
      resolution: resolution,
    );
  }

  void dispose() {
    _finnhubService.dispose();
  }
}
