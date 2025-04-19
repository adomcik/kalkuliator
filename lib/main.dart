import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'calculator_screen.dart'; // Ensure this import is correct
import 'welcome_screen.dart'; // Ensure this import is correct

void main() {
  runApp(const Kalkuliator());
}

class Kalkuliator extends StatelessWidget {
  const Kalkuliator({super.key}); // Fix for the 'key' warning

  Future<Widget> getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final savedVersion = prefs.getString('lastVersion');

    if (savedVersion != currentVersion) {
      // First launch or after update
      await prefs.setString('lastVersion', currentVersion);
      return WelcomeScreen(); // Ensure WelcomeScreen is imported correctly
    } else {
      return CalculatorScreen(); // Ensure CalculatorScreen is imported correctly
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkuliator',  // Changed from CalcMate to Kalkuliator
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: ThemeMode.system, // Uses system setting (light/dark)

      home: FutureBuilder<Widget>(
        future: getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data!;  // Return the screen based on Future
          }
        },
      ),
    );
  }
}
