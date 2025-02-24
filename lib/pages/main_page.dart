import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forex_repository/forex_repository.dart';
import 'package:fxtm/forex_pairs/forex_pairs.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForexPairsBloc(
        repository: context.read<ForexRepository>(),
      )..add(const ForexPairsSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FXTM Forex Tracker'),
        ),
        body: const ForexPairsPage(),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Markets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: 0,
          onTap: (index) {
            if (index != 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This menu item is disabled')),
              );
            }
          },
        ),
      ),
    );
  }
}
