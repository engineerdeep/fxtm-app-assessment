// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forex_quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForexQuote _$ForexQuoteFromJson(Map<String, dynamic> json) => ForexQuote(
  symbol: json['s'] as String,
  price: (json['p'] as num).toDouble(),
  volume: (json['v'] as num).toDouble(),
  timestamp: ForexQuote._timestampFromJson((json['t'] as num).toInt()),
);

Map<String, dynamic> _$ForexQuoteToJson(ForexQuote instance) =>
    <String, dynamic>{
      's': instance.symbol,
      'p': instance.price,
      'v': instance.volume,
      't': instance.timestamp.toIso8601String(),
    };
