import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api.dart';
import 'screens/customer/home.dart';
import 'screens/login.dart';
import 'screens/worker/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.I.init();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  static AppState of(BuildContext c) => c.findAncestorStateOfType<AppState>()!;
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  void refresh() => setState(() {});

  Future<void> setLang(String l) async {
    await Api.I.setLang(l);
    refresh();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SahakarSeva',
        debugShowCheckedModeBanner: false,
        locale: Locale(Api.I.lang),
        supportedLocales: const [Locale('en'), Locale('hi'), Locale('mr')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(colorSchemeSeed: const Color(0xFF047857), useMaterial3: true),
        home: switch (Api.I.role) {
          'customer' => const CustomerHome(),
          'worker' => const WorkerHome(),
          _ => const LoginScreen(),
        },
      );
}
