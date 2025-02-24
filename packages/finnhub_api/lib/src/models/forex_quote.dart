import 'package:json_annotation/json_annotation.dart';

part 'forex_quote.g.dart';

@JsonSerializable()
class ForexQuote {
  @JsonKey(name: 's')
  final String symbol;
  @JsonKey(name: 'p')
  final double price;
  @JsonKey(name: 'v')
  final double volume;
  @JsonKey(name: 't', fromJson: _timestampFromJson)
  final DateTime timestamp;

  const ForexQuote({
    required this.symbol,
    required this.price,
    required this.volume,
    required this.timestamp,
  });

  factory ForexQuote.fromJson(Map<String, dynamic> json) =>
      _$ForexQuoteFromJson(json);

  Map<String, dynamic> toJson() => _$ForexQuoteToJson(this);

  static DateTime _timestampFromJson(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
}
