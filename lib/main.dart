import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'calculator_screen.dart';
import 'welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const Kalkuliator());
}

class Kalkuliator extends StatefulWidget {
  const Kalkuliator({super.key});

  @override
  _KalkuliatorState createState() => _KalkuliatorState();
}

class _KalkuliatorState extends State<Kalkuliator> {
  ThemeMode _themeMode = ThemeMode.system;
  late Future<Widget> _initialScreen;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final savedVersion = prefs.getString('lastVersion');

    if (savedVersion != currentVersion) {
      await prefs.setString('lastVersion', currentVersion);
      return WelcomeScreen(
        themeMode: _themeMode,
        onThemeChanged: _setThemeMode,
        onContinue: _onWelcomeContinue,
      );
    }

    return _buildCalculatorScreen();
  }

  void _onWelcomeContinue() {
    setState(() {
      _initialScreen = Future.value(_buildCalculatorScreen());
    });
  }

  CalculatorScreen _buildCalculatorScreen() {
    return CalculatorScreen(
      themeMode: _themeMode,
      onThemeChanged: _setThemeMode,
    );
  }

  @override
  void initState() {
    super.initState();
    _initialScreen = _getInitialScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkuliator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: _themeMode,
      home: FutureBuilder<Widget>(
        future: _initialScreen,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Error loading screen')),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
