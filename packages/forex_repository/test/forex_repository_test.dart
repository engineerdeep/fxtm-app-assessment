import 'package:finnhub_api/finnhub_api.dart';
import 'package:forex_repository/forex_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFinnhubService extends Mock implements FinnhubService {}

class MockForexQuote extends Mock implements ForexQuote {}

void main() {
  group('ForexRepository', () {
    late FinnhubService finnhubService;
    late ForexRepository repository;

    setUp(() {
      finnhubService = MockFinnhubService();
      repository = ForexRepository(finnhubService);
    });

    test('can be instantiated', () {
      expect(ForexRepository(MockFinnhubService()), isNotNull);
    });

    group('quotes', () {
      test('returns stream from finnhub service', () {
        final quotesStream = Stream<ForexQuote>.empty();
        when(() => finnhubService.quotes).thenAnswer((_) => quotesStream);

        expect(repository.quotes, equals(quotesStream));
        verify(() => finnhubService.quotes).called(1);
      });
    });

    group('connectionState', () {
      test('returns connection state stream from finnhub service', () {
        final stateStream = Stream<WebSocketConnectionState>.empty();
        when(
          () => finnhubService.connectionState,
        ).thenAnswer((_) => stateStream);

        expect(repository.connectionState, equals(stateStream));
        verify(() => finnhubService.connectionState).called(1);
      });
    });

    group('connect', () {
      test('calls connect on finnhub service', () async {
        when(() => finnhubService.connect()).thenAnswer((_) async {});

        await repository.connect();
        verify(() => finnhubService.connect()).called(1);
      });
    });

    group('disconnect', () {
      test('calls disconnect on finnhub service', () {
        when(() => finnhubService.disconnect()).thenReturn(null);

        repository.disconnect();
        verify(() => finnhubService.disconnect()).called(1);
      });
    });

    group('getAvailableSymbols', () {
      test('returns list of forex symbols from finnhub service', () async {
        final symbols = [
          const ForexSymbol(symbol: 'IC MARKETS:1', displaySymbol: 'EUR/USD'),
        ];
        when(
          () => finnhubService.getAvailableSymbols(),
        ).thenAnswer((_) async => symbols);

        final result = await repository.getAvailableSymbols();
        expect(result, equals(symbols));
        verify(() => finnhubService.getAvailableSymbols()).called(1);
      });
    });

    group('getHistoricalData', () {
      test('returns historical data from finnhub service', () async {
        final historicalData = [
          {
            'timestamp': DateTime(2024, 1, 1),
            'close': 1.1234,
            'open': 1.1200,
            'high': 1.1300,
            'low': 1.1100,
          },
        ];
        when(
          () => finnhubService.getHistoricalData(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
            resolution: any(named: 'resolution'),
          ),
        ).thenAnswer((_) async => historicalData);

        final result = await repository.getHistoricalData(
          'OANDA:EUR_USD',
          from: DateTime(2024, 1, 1),
          to: DateTime(2024, 1, 7),
          resolution: '60',
        );

        expect(result, equals(historicalData));
        verify(
          () => finnhubService.getHistoricalData(
            'OANDA:EUR_USD',
            from: DateTime(2024, 1, 1),
            to: DateTime(2024, 1, 7),
            resolution: '60',
          ),
        ).called(1);
      });
    });

    group('dispose', () {
      test('calls dispose on finnhub service', () {
        when(() => finnhubService.dispose()).thenReturn(null);

        repository.dispose();
        verify(() => finnhubService.dispose()).called(1);
      });
    });
  });
}
