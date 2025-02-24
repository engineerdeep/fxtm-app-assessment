import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:finnhub_api/finnhub_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forex_repository/forex_repository.dart';
import 'package:fxtm/core/config/env_config.dart';
import 'package:fxtm/pages/main_page.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.initialize();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  final config = FinnhubConfig(
    apiKey: EnvConfig.finnhubApiKey,
    baseUrl: EnvConfig.finnhubBaseUrl,
    wsUrl: EnvConfig.finnhubWsUrl,
  );

  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  final FinnhubConfig config;

  const MyApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ForexRepository(
        FinnhubService(config: config),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FXTM Forex Tracker',
        theme: ThemeData(
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        home: const MainPage(),
      ),
    );
  }
}
