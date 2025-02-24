import 'dart:convert';

import 'package:finnhub_api/finnhub_api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://finnhub.io'));
  });

  group('FinnhubService', () {
    late MockHttpClient httpClient;
    late FinnhubConfig config;
    late FinnhubService service;

    setUp(() {
      httpClient = MockHttpClient();
      config = const FinnhubConfig(
        apiKey: 'test_api_key',
        baseUrl: 'https://finnhub.io/api/v1',
        wsUrl: 'wss://ws.finnhub.io',
      );

      service = FinnhubService(config: config, httpClient: httpClient);
    });

    test('getAvailableSymbols returns list of ForexSymbol', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {'symbol': 'IC MARKETS:1', 'displaySymbol': 'EUR/USD'},
            {'symbol': 'IC MARKETS:5', 'displaySymbol': 'AUD/USD'},
          ]),
          200,
        ),
      );

      final symbols = await service.getAvailableSymbols();

      expect(symbols, hasLength(2));
      expect(symbols.first.symbol, equals('IC MARKETS:1'));
      expect(symbols.first.displaySymbol, equals('EUR/USD'));
    });

    test('getAvailableSymbols throws FinnhubApiException on error', () {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response('', 400));

      expect(
        () => service.getAvailableSymbols(),
        throwsA(isA<FinnhubApiException>()),
      );
    });

    test('getHistoricalData returns candle data', () async {
      final result = await service.getHistoricalData(
        'OANDA:EUR_USD',
        from: DateTime(2024, 1, 1),
        to: DateTime(2024, 1, 7),
        resolution: '60',
      );

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result, hasLength(10));
      expect(result.first, containsPair('timestamp', isA<DateTime>()));
      expect(result.first, containsPair('close', isA<double>()));
    });
  });
}
