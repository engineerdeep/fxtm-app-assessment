import 'package:finnhub_api/finnhub_api.dart';
import 'package:test/test.dart';

void main() {
  group('ForexQuote', () {
    group('fromJson', () {
      test('returns correct ForexQuote object', () {
        expect(
          ForexQuote.fromJson(<String, dynamic>{
            's': 'OANDA:USB30Y_USD',
            'p': 115.862,
            't': 1740175145160,
            'v': 0,
          }),
          isA<ForexQuote>()
              .having((w) => w.symbol, 's', 'OANDA:USB30Y_USD')
              .having((w) => w.price, 'p', 115.862)
              .having(
                (w) => w.timestamp,
                't',
                DateTime.fromMillisecondsSinceEpoch(1740175145160),
              )
              .having((w) => w.volume, 'v', 0),
        );
      });
    });
  });
}
