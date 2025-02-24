import 'dart:async';
import 'dart:convert';

import 'package:finnhub_api/finnhub_api.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class FinnhubWebSocketConnectionException implements Exception {}

class FinnhubStreamException implements Exception {}

class FinnhubApiException implements Exception {}

class FinnhubService {
  final FinnhubConfig _config;
  final http.Client _httpClient;

  final _quoteController = StreamController<ForexQuote>.broadcast();
  final Set<String> _subscribedSymbols = {};

  WebSocketChannel? _channel;

  final _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();
  Timer? _reconnectionTimer;
  static const _reconnectDelay = Duration(seconds: 2);
  static const _maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;
  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;

  FinnhubService({required config, http.Client? httpClient})
    : _config = config,
      _httpClient = httpClient ?? http.Client();

  Stream<ForexQuote> get quotes => _quoteController.stream;

  Stream<WebSocketConnectionState> get connectionState =>
      _connectionStateController.stream;

  Future<void> connect() async {
    if (_connectionState == WebSocketConnectionState.connected ||
        _connectionState == WebSocketConnectionState.connecting) {
      return;
    }

    try {
      _updateConnectionState(WebSocketConnectionState.connecting);
      final websocketUrl = '${_config.wsUrl}?token=${_config.apiKey}';
      _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'trade') {
            for (final trade in data['data'] as List) {
              final quote = ForexQuote.fromJson(trade as Map<String, dynamic>);
              _quoteController.add(quote);
            }
          }
        },
        onError: (error) {
          _quoteController.addError(FinnhubStreamException());
          _scheduleReconnection();
        },
        onDone: () {
          _scheduleReconnection();
        },
      );

      _updateConnectionState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;
    } catch (e) {
      _updateConnectionState(WebSocketConnectionState.error);
      throw FinnhubWebSocketConnectionException();
    }
  }

  void subscribe(String symbol) {
    if (_channel == null) return;

    if (_subscribedSymbols.add(symbol)) {
      _channel!.sink.add(jsonEncode({'type': 'subscribe', 'symbol': symbol}));
    }
  }

  void unsubscribe(String symbol) {
    if (_channel == null) return;

    if (_subscribedSymbols.remove(symbol)) {
      _channel!.sink.add(jsonEncode({'type': 'unsubscribe', 'symbol': symbol}));
    }
  }

  void disconnect() {
    // Unsubscribe to all symbols
    for (final symbol in _subscribedSymbols) {
      unsubscribe(symbol);
    }

    _subscribedSymbols.clear();
    _channel?.sink.close();
    _channel = null;
  }

  Future<List<ForexSymbol>> getAvailableSymbols() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '${_config.baseUrl}/forex/symbol?exchange=oanda&token=${_config.apiKey}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .take(20)
            .map(
              (item) => ForexSymbol(
                symbol: item['symbol'] as String,
                displaySymbol: item['displaySymbol'] as String,
              ),
            )
            .toList();
      } else {
        throw FinnhubApiException();
      }
    } catch (e) {
      throw FinnhubApiException();
    }
  }

  Future<List<Map<String, dynamic>>> getHistoricalData(
    String symbol, {
    required DateTime from,
    required DateTime to,
    required String resolution,
  }) async {
    try {
      // final response = await _httpClient.get(
      //   Uri.parse(
      //     '${_config.baseUrl}/forex/candle?symbol=$symbol&resolution=$resolution&token=${_config.apiKey}',
      //   ),
      // );

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock API response
      final mockResponse = {
        "s": "ok",
        "t": [
          1568667600,
          1568754000,
          1568840400,
          1568926800,
          1569013200,
          1569099600,
          1569186000,
          1569272400,
          1569358800,
          1569445200,
        ],
        "c": [
          1.10213,
          1.10288,
          1.10397,
          1.10282,
          1.10397,
          1.10345,
          1.10458,
          1.10412,
          1.10375,
          1.10487,
        ],
        "o": [
          1.10160,
          1.10170,
          1.10269,
          1.10298,
          1.10182,
          1.10297,
          1.10345,
          1.10358,
          1.10312,
          1.10375,
        ],
        "h": [
          1.10340,
          1.10351,
          1.10429,
          1.10395,
          1.10412,
          1.10423,
          1.10487,
          1.10445,
          1.10483,
          1.10489,
        ],
        "l": [
          1.10097,
          1.10130,
          1.10223,
          1.10201,
          1.10156,
          1.10267,
          1.10289,
          1.10278,
          1.10289,
          1.10345,
        ],
        "v": [
          75789,
          75883,
          73485,
          71234,
          72456,
          74123,
          73890,
          75012,
          74567,
          73456,
        ],
      };

      if (mockResponse['s'] == 'ok') {
        final List<Map<String, dynamic>> candles = [];
        final timestamps = mockResponse['t'] as List;
        final closes = mockResponse['c'] as List;
        final opens = mockResponse['o'] as List;
        final highs = mockResponse['h'] as List;
        final lows = mockResponse['l'] as List;

        for (var i = 0; i < timestamps.length; i++) {
          candles.add({
            'timestamp': DateTime.fromMillisecondsSinceEpoch(
              timestamps[i] * 1000,
            ),
            'close': closes[i],
            'open': opens[i],
            'high': highs[i],
            'low': lows[i],
          });
        }
        return candles;
      }
      throw FinnhubApiException();
    } catch (e) {
      throw FinnhubApiException();
    }
  }

  void dispose() {
    _reconnectionTimer?.cancel();
    _connectionStateController.close();
    disconnect();
    _quoteController.close();
  }

  void _updateConnectionState(WebSocketConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _scheduleReconnection() {
    // Stop reconnection if reconnection attempts exceed max attempts.
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _updateConnectionState(WebSocketConnectionState.error);
      disconnect();
      return;
    }

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      _updateConnectionState(WebSocketConnectionState.reconnecting);
      connect();
    });
  }
}
