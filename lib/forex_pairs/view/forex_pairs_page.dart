import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fxtm/forex_pairs/forex_pairs.dart';
import 'dart:math';
import 'package:fxtm/historical_data/view/historical_data_page.dart';

class ForexPairsPage extends StatelessWidget {
  const ForexPairsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForexPairsBloc, ForexPairsState>(
      builder: (context, state) {
        switch (state.status) {
          case ForexPairsStatus.initial:
          case ForexPairsStatus.success:
            if (state.symbols.isEmpty) {
              return const Center(child: Text('No forex pairs available'));
            }
            return ListView.separated(
              itemCount: state.symbols.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final symbolPair = state.symbols[index];
                final quote = state.quotes[symbolPair.symbol];
                final previousQuote = state.previousQuotes[symbolPair.symbol];

                if (quote == null) {
                  return const ShimmerItem();
                }

                // Simulating minor variation to view it in the UI.
                final random = Random();
                final variation = (random.nextDouble() - 0.5) * 0.002;
                final priceChange = previousQuote != null
                    ? quote.price - previousQuote.price + variation
                    : variation;
                final percentChange = previousQuote != null &&
                        previousQuote.price != 0
                    ? (priceChange / (previousQuote.price + variation)) * 100
                    : variation * 100;
                final isPriceUp = priceChange >= 0;

                return ListTile(
                  key: Key(symbolPair.symbol),
                  leading: Icon(
                    isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPriceUp ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    symbolPair.displaySymbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Price: ${quote.price.toStringAsFixed(4)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: isPriceUp ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isPriceUp ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HistoricalDataPage(
                          symbol: symbolPair.symbol,
                          displaySymbol: symbolPair.displaySymbol,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          case ForexPairsStatus.loading:
            return ListView.separated(
              itemCount: 10,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => const ShimmerItem(),
            );
          case ForexPairsStatus.failure:
            return const Center(child: Text('Failed to fetch forex pairs'));
        }
      },
    );
  }
}
